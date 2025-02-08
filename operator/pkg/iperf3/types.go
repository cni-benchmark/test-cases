package iperf3

type Report struct {
	System struct {
		KernelVersion string `json:"kernel_version"`
		Architecture  string `json:"architecture"`
	} `json:"system"`
	Start struct {
		Version   string `json:"version"`
		Timestamp struct {
			Seconds uint `json:"timesecs"`
		} `json:"timestamp"`
		Test struct {
			Protocol string `json:"protocol"`
		} `json:"test_start"`
	} `json:"start"`
	End struct {
		Sent struct {
			ReportEndSum
			Retransmits uint64 `json:"retransmits"`
		} `json:"sum_sent"`
		Received ReportEndSum `json:"sum_received"`
	} `json:"end"`
}

type ReportEndSum struct {
	DurationSeconds float64 `json:"seconds"`
	Bytes           uint64  `json:"bytes"`
	BitsPerSecond   float64 `json:"bits_per_second"`
}
