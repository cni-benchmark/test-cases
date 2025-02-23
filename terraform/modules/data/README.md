# data

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | <2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | <6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | <6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami"></a> [ami](#output\_ami) | AMI for different OSes |
| <a name="output_available_azs"></a> [available\_azs](#output\_available\_azs) | Available AZs names in the region |
| <a name="output_region"></a> [region](#output\_region) | Current region name |
| <a name="output_tests_install_manifest_url"></a> [tests\_install\_manifest\_url](#output\_tests\_install\_manifest\_url) | URL to manifest with tests-installer job |
<!-- END_TF_DOCS -->
