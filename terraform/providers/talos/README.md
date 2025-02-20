# talos

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | <2.0.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | <1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_talos"></a> [talos](#provider\_talos) | <1.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data"></a> [data](#module\_data) | ../../modules/data | n/a |

## Resources

| Name | Type |
|------|------|
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster_kubeconfig) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets) | resource |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/client_configuration) | data source |
| [talos_machine_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_patches"></a> [config\_patches](#input\_config\_patches) | List of valid YAMLs patches for machine configuration | `list(string)` | `[]` | no |
| <a name="input_ec2"></a> [ec2](#input\_ec2) | EC2 module outputs | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name prefix | `string` | n/a | yes |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | Cluster Pod CIDR | `string` | `"10.244.0.0/16"` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | Cluster Service CIDR | `string` | `"10.96.0.0/12"` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos version | `string` | `"1.9.4"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_ip"></a> [dns\_ip](#output\_dns\_ip) | kube-dns service IP |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Cluster kubeconfig |
| <a name="output_machine_configuration"></a> [machine\_configuration](#output\_machine\_configuration) | Talos machine configuration |
| <a name="output_pod_cidr"></a> [pod\_cidr](#output\_pod\_cidr) | var.pod\_cidr |
| <a name="output_service_cidr"></a> [service\_cidr](#output\_service\_cidr) | var.service\_cidr |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | Cluster talosconfig |
<!-- END_TF_DOCS -->
