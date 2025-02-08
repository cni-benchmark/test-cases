package config

import (
	"fmt"
	"strings"

	"github.com/mitchellh/mapstructure"
	"github.com/spf13/viper"
)

// Build initializes the Config by loading from environment variables.
func Build() (*Config, error) {
	cfg := &Config{
		viper: viper.NewWithOptions(viper.EnvKeyReplacer(&envReplacer{})),
		Port:  5201,
		Lease: Lease{Namespace: "default", Name: "cni-benchmark"},
		Args:  Args{"--json": ""},
		PushGateway: PushGateway{
			JobName:   "cni-benchmark",
			Namespace: "cni_benchmark",
		},
	}

	// Automatically read environment variables
	cfg.viper.AutomaticEnv()

	// Unmarshal the configuration into the struct
	if err := cfg.viper.Unmarshal(cfg, viper.DecodeHook(
		mapstructure.ComposeDecodeHookFunc(
			DecodeArgs,
			DecodeMode,
			DecodeServer,
			DecodeURL,
			DecodeLabels,
		),
	)); err != nil {
		return nil, fmt.Errorf("unable to unmarshal config into struct: %w", err)
	}

	if cfg.PushGateway.Url == nil {
		return nil, fmt.Errorf("PushGateway URL is not set")
	}

	// Return nil if everything went fine
	return cfg, nil
}

type envReplacer struct{}

func (r *envReplacer) Replace(s string) string {
	return strings.ToUpper(strings.NewReplacer(".", "_").Replace(s))
}
