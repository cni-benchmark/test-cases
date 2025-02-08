package config

import (
	"net/url"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/spf13/viper"
)

// Config holds the application configuration loaded from environment variables.
type Config struct {
	viper       *viper.Viper `json:"-" yaml:"-"`
	Lease       Lease        `mapstructure:"lease"`
	PushGateway PushGateway  `mapstructure:"pushgateway"`
	Server      Address      `mapstructure:"server"`
	Args        Args         `mapstructure:"args"`
	Port        uint16       `mapstructure:"port"`
	Mode        Mode         `mapstructure:"mode"`
}

type PushGateway struct {
	JobName   string            `mapstructure:"job_name"`
	Prefix    string            `mapstructure:"prefix"`
	Namespace string            `mapstructure:"namespace"`
	Url       *url.URL          `mapstructure:"url"`
	Labels    prometheus.Labels `mapstructure:"labels"`
}

type Lease struct {
	Namespace string `mapstructure:"namespace"`
	Name      string `mapstructure:"name"`
}

type Args map[string]string
type Port uint16
type Address string
type Mode uint8

const (
	ModeClient Mode = iota
	ModeServer
)
