package iperf3

import (
	config "cni-benchmark/pkg/config"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"

	"github.com/docker/docker/pkg/parsers/kernel"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/push"
)

// WaitForServer attempts to establish a TCP connection to the server with a timeout
func WaitForServer(ctx context.Context, cfg *config.Config) error {
	if cfg.Mode != config.ModeClient {
		return nil
	}
	if len(cfg.Server) == 0 {
		return fmt.Errorf("server must be set in client mode")
	}
	address := fmt.Sprintf("%s:%d", cfg.Server, cfg.Port)
	log.Printf("Waiting for server at %s", address)

	for {
		select {
		case <-ctx.Done():
			return fmt.Errorf("timeout waiting for server at %s", address)
		default:
			conn, err := net.DialTimeout("tcp", address, 5*time.Second)
			if err == nil {
				conn.Close()
				log.Printf("Server is reachable at %s", address)
				return nil
			}
			log.Printf("Server not yet reachable: %v", err)
			time.Sleep(time.Second)
		}
	}
}

// BuildIperf3Command constructs the iperf3 command with appropriate arguments
func BuildIperf3Command(cfg *config.Config) (*exec.Cmd, error) {
	switch cfg.Mode {
	case config.ModeServer:
		cfg.Args["--server"] = ""
	case config.ModeClient:
		cfg.Args["--client"] = string(cfg.Server)
	}

	cfg.Args["--port"] = strconv.Itoa(int(cfg.Port))

	argsList := []string{}
	for key, value := range cfg.Args {
		argsList = append(argsList, strings.Trim(fmt.Sprintf("%s=%s", key, value), "="))
	}

	return exec.Command("iperf3", argsList...), nil
}

// Run iperf3 and get JSON output
func Run() (report *Report, err error) {
	var cfg *config.Config
	cfg, err = config.Build()
	if err != nil {
		return nil, fmt.Errorf("failed to build a config: %w", err)
	}

	if err = WaitForServer(context.Background(), cfg); err != nil {
		return nil, fmt.Errorf("failed waiting for server: %w", err)
	}

	// Build and execute iperf3 command
	cmd, err := BuildIperf3Command(cfg)
	if err != nil {
		return nil, fmt.Errorf("failed to build command: %w", err)
	}

	// Execute iperf3
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to execute iperf3: %w", err)
	}

	// Parse JSON output
	report = &Report{}
	if err := json.Unmarshal(output, report); err != nil {
		return nil, fmt.Errorf("failed to parse JSON output: %w", err)
	}

	// Get extra info
	kv, err := kernel.GetKernelVersion()
	if err != nil {
		return nil, fmt.Errorf("failed to get kernel info: %w", err)
	}

	report.System.KernelVersion = kv.String()
	report.System.Architecture = runtime.GOARCH
	return
}

// Analyze JSON output and push metrics to Prometheus PushGateway
func Analyze(cfg *config.Config, report *Report) error {
	// Create a Prometheus Pusher
	pusher := push.New(cfg.PushGateway.Url.String(), cfg.PushGateway.JobName)

	// Configure basic auth
	if password, isSet := cfg.PushGateway.Url.User.Password(); isSet {
		pusher.BasicAuth(cfg.PushGateway.Url.User.Username(), password)
	}

	// Create metrics
	type Metric struct {
		Help  string
		Value float64
	}

	gauges := map[string]map[string]Metric{
		"tx": {
			"bandwidth_bps_average": {
				Help:  "Average transmit bandwidth in bits per second",
				Value: report.End.Sent.BitsPerSecond,
			},
			"bytes_sent_total": {
				Help:  "Total bytes sent",
				Value: float64(report.End.Sent.Bytes),
			},
			"duration_seconds_total": {
				Help:  "Transmission duration in seconds",
				Value: report.End.Sent.DurationSeconds,
			},
			"retransmits_total": {
				Help:  "Number of retransmits",
				Value: float64(report.End.Sent.Retransmits),
			},
		},
		"rx": {
			"bandwidth_bps_average": {
				Help:  "Average receive bandwidth in bits per second",
				Value: report.End.Received.BitsPerSecond,
			},
			"bytes_received_total": {
				Help:  "Total bytes received",
				Value: float64(report.End.Received.Bytes),
			},
			"duration_seconds_total": {
				Help:  "Receive duration in seconds",
				Value: report.End.Received.DurationSeconds,
			},
		},
	}

	for direction, metrics := range gauges {
		for name, spec := range metrics {
			gauge := prometheus.NewGauge(prometheus.GaugeOpts{
				Name:      fmt.Sprintf("%s%s_%s", cfg.PushGateway.Prefix, direction, name),
				Help:      spec.Help,
				Namespace: cfg.PushGateway.Namespace,
			})
			gauge.Set(spec.Value)
			pusher.Collector(gauge)
		}
	}

	type IntervalMetric struct {
		Help      string
		ValueFunc func(Interval) float64
	}

	intervalGauges := map[string]map[string]IntervalMetric{
		"interval": {
			"bandwidth_bps": {
				Help:      "Transmit bandwidth in bits per second",
				ValueFunc: func(i Interval) float64 { return i.Sum.BitsPerSecond },
			},
			"bytes_sent": {
				Help:      "Bytes sent during the interval",
				ValueFunc: func(i Interval) float64 { return float64(i.Sum.Bytes) },
			},
			"duration_seconds": {
				Help:      "Interval duration in seconds",
				ValueFunc: func(i Interval) float64 { return i.Sum.DurationSeconds },
			},
			"retransmits": {
				Help:      "Number of retransmits during the interval",
				ValueFunc: func(i Interval) float64 { return float64(i.Sum.Retransmits) },
			},
		},
	}

	for _, interval := range report.Intervals {
		for direction, metrics := range intervalGauges {
			for name, spec := range metrics {
				gauge := prometheus.NewGauge(prometheus.GaugeOpts{
					Name:      fmt.Sprintf("%s%s_%s", cfg.PushGateway.Prefix, direction, name),
					Help:      spec.Help,
					Namespace: cfg.PushGateway.Namespace,
				})
				gauge.Set(spec.ValueFunc(interval)) // how to set timestamp?
				pusher.Collector(gauge)
			}
		}
	}

	// Add labels for additional context
	pusher.
		Grouping("iperf3_version", report.Start.Version).
		Grouping("kernel_arch", report.System.Architecture).
		Grouping("kernel_version", report.System.KernelVersion).
		Grouping("protocol", report.Start.Test.Protocol)

	// Add extra labels
	for key, value := range cfg.PushGateway.Labels {
		pusher.Grouping(key, value)
	}

	// Push metrics to PushGateway
	if err := pusher.Push(); err != nil {
		return fmt.Errorf("could not push metrics to PushGateway: %v", err)
	}

	log.Println("Metrics successfully pushed to Prometheus PushGateway")
	return nil
}
