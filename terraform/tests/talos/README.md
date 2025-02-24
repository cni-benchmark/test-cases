# manager

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | <2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | <6.0.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | <2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | <2.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data"></a> [data](#module\_data) | ../../modules/data | n/a |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ../../modules/ec2-instance | n/a |
| <a name="module_talos"></a> [talos](#module\_talos) | ../../providers/talos | n/a |

## Resources

| Name | Type |
|------|------|
| [kubectl_kustomize_documents.cni](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/kustomize_documents) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_url"></a> [database\_url](#input\_database\_url) | Manager IP address to use | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name prefix | `string` | n/a | yes |
| <a name="input_test_duration"></a> [test\_duration](#input\_test\_duration) | Test duration in seconds | `number` | `120` | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | VPC public subnets IDs | `list(string)` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | Extra security groups to use | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2"></a> [ec2](#output\_ec2) | EC2 instance outputs |
| <a name="output_talos"></a> [talos](#output\_talos) | Cluster kubeconfig |
<!-- END_TF_DOCS -->
