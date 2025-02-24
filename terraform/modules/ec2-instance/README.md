# ec2-instance

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | <2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | <6.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | <5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | <6.0.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | <5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | terraform-aws-modules/ec2-instance/aws | <6.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | AMI ID | `string` | n/a | yes |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Works in private subnet as well | `bool` | `true` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM instance profile name | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance size | `string` | `"t4g.small"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix | `string` | n/a | yes |
| <a name="input_root_size"></a> [root\_size](#input\_root\_size) | Root device disk size | `number` | `10` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data script | `string` | `""` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | Security groups to connect to | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_id"></a> [vpc\_subnet\_id](#input\_vpc\_subnet\_id) | VPC Subnet ID to use | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_outputs"></a> [outputs](#output\_outputs) | EC2 instance module outputs |
<!-- END_TF_DOCS -->
