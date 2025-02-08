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
		InfluxDB: InfluxDB{
			Bucket: "cni-benchmark",
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
			DecodeInfluxDBTags,
		),
	)); err != nil {
		return nil, fmt.Errorf("unable to unmarshal config into struct: %w", err)
	}

	// Check mandatory configuration fields are set
	for name, test := range map[string]struct {
		Value   any
		Compare any
	}{
		"InfluxDB URL":          {cfg.InfluxDB.Url, nil},
		"InfluxDB Token":        {cfg.InfluxDB.Token, ""},
		"InfluxDB Organization": {cfg.InfluxDB.Org, ""},
		"InfluxDB Bucket":       {cfg.InfluxDB.Bucket, ""},
	} {
		if test.Value == test.Compare {
			return nil, fmt.Errorf("%s is not set", name)
		}
	}

	// Return nil if everything went fine
	return cfg, nil
}

type envReplacer struct{}

func (r *envReplacer) Replace(s string) string {
	return strings.ToUpper(strings.NewReplacer(".", "_").Replace(s))
}
