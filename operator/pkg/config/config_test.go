package config_test

import (
	"os"
	"testing"

	. "cni-benchmark/pkg/config"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"github.com/prometheus/client_golang/prometheus"
)

func TestConfig(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Config")
}

var _ = Describe("Configuration", func() {
	var cfg *Config
	var err error
	env := map[string]string{
		"MODE":                  "client",
		"SERVER":                "example.com",
		"PORT":                  "80",
		"LEASE_NAME":            "test",
		"LEASE_NAMESPACE":       "test",
		"PUSHGATEWAY_URL":       "http://username:password@example.com/path",
		"PUSHGATEWAY_JOB_NAME":  "test",
		"PUSHGATEWAY_PREFIX":    "test",
		"PUSHGATEWAY_NAMESPACE": "test",
		"PUSHGATEWAY_LABELS":    "some: label\nanother: one",
		"ARGS":                  "--help: ''\nkey: value",
	}

	BeforeEach(func() {
		for name, value := range env {
			Expect(os.Setenv(name, value)).To(Succeed())
		}
		cfg, err = Build()
		Expect(err).ToNot(HaveOccurred())
		Expect(cfg).ToNot(BeNil())
	})

	AfterEach(func() {
		for name := range env {
			Expect(os.Unsetenv(name)).To(Succeed())
		}
	})

	It("should parse all configuration fields from environment", func() {
		Expect(cfg.Mode).To(Equal(ModeClient))
		Expect(cfg.Server).To(Equal(Address("example.com")))
		Expect(cfg.Port).To(Equal(uint16(80)))
		Expect(cfg.Lease.Namespace).To(Equal("test"))
		Expect(cfg.Lease.Name).To(Equal("test"))
		Expect(cfg.PushGateway.Url.Scheme).To(Equal("http"))
		Expect(cfg.PushGateway.Url.Host).To(Equal("example.com"))
		Expect(cfg.PushGateway.Url.User.Username()).To(Equal("username"))
		password, set := cfg.PushGateway.Url.User.Password()
		Expect(password).To(Equal("password"))
		Expect(set).To(BeTrue())
		Expect(cfg.PushGateway.Url.Path).To(Equal("/path"))
		Expect(cfg.PushGateway.JobName).To(Equal("test"))
		Expect(cfg.PushGateway.Prefix).To(Equal("test"))
		Expect(cfg.PushGateway.Namespace).To(Equal("test"))
		Expect(cfg.PushGateway.Labels).To(Equal(prometheus.Labels{"some": "label", "another": "one"}))
		Expect(cfg.Args).To(Equal(Args{"--json": "", "--help": "", "key": "value"}))
	})
})
