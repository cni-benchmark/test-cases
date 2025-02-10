package main

import (
	"cni-benchmark/pkg/config"
	"cni-benchmark/pkg/iperf3"
	"context"
	"fmt"
	"log"
	"os"
	"time"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/tools/leaderelection"
	"k8s.io/client-go/tools/leaderelection/resourcelock"
)

func main() {
	cfg, err := config.Build()
	if err != nil {
		log.Fatalf("Failed to build a config: %v", err)
	}

	// Create kubernetes client
	config, err := clientcmd.BuildConfigFromFlags("", os.Getenv("KUBECONFIG"))
	if err != nil {
		log.Fatal(err)
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		log.Fatal(err)
	}

	// Create a unique identifier for this instance
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatalf("Failed to get the hostname: %v", err)
	}
	id := fmt.Sprintf("%s_%d", hostname, time.Now().Unix())

	// Configure the leader election
	lock := &resourcelock.LeaseLock{
		LeaseMeta: metav1.ObjectMeta{
			Name:      cfg.Lease.Name,
			Namespace: cfg.Lease.Namespace,
		},
		Client: clientset.CoordinationV1(),
		LockConfig: resourcelock.ResourceLockConfig{
			Identity: id,
		},
	}

	// Create leader election config
	leaderConfig := leaderelection.LeaderElectionConfig{
		Lock:            lock,
		ReleaseOnCancel: true,
		LeaseDuration:   5 * time.Second,
		RenewDeadline:   2 * time.Second,
		RetryPeriod:     time.Second,
		Callbacks: leaderelection.LeaderCallbacks{
			OnStartedLeading: func(ctx context.Context) {
				log.Printf("Got leadership, starting benchmark")
				var report *iperf3.Report
				if report, err = iperf3.Run(); err != nil {
					log.Fatalf("Error running iperf: %v", err)
				}
				if err = iperf3.Analyze(cfg, report); err != nil {
					log.Fatalf("Error analyzing iperf output: %v", err)
				}
				os.Exit(0)
			},
			OnStoppedLeading: func() {
				log.Fatalln("Leadership lost")
			},
			OnNewLeader: func(identity string) {
				if identity == id {
					return
				}
				log.Printf("Leadership is held by: %s", identity)
			},
		},
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Start the leader election
	log.Printf("Starting leader election")
	leaderelection.RunOrDie(ctx, leaderConfig)
}
