<!-- BEGIN_TF_DOCS -->
# Terraform Network-as-Code Cisco FMC Module that is using a new Terraform FMC Provider

A Terraform module to configure Cisco FMC.

## Usage

This module supports an inventory driven approach, where a complete FMC configuration or parts of it are either modeled in one or more YAML files or natively using Terraform variables.

### Steps to compile a new terraform fmc module:
```
export GOPATH="<put your path here>"

git clone https://github.com/netascode/terraform-provider-fmc   

cd terraform-provider-fmc

go install

```
The bin file is compiled in $GOPATH so one folder up in above example - bin folder

```
% ls -la
total 8
drwxr-xr-x   6 mmaciejc  staff  192 Jun 13 12:02 .
drwxr-xr-x   8 mmaciejc  staff  256 Jun 13 12:03 ..
-rw-r--r--   1 mmaciejc  staff  184 Jun 13 14:17 README.md
drwxr-xr-x   3 mmaciejc  staff   96 Jun 13 12:02 bin    <<< here
drwxr-xr-x   4 mmaciejc  staff  128 Jun 13 12:02 pkg
```

copy terraform-provider-fmc to folders (make a structure):
```
├── bin
│   └── registry.terraform.io
│       └── netascode
│           └── fmc
│               └── 0.0.9999
│                   └── darwin_arm64
│                       └── terraform-provider-fmc
```
Use provider: usualy in versions.tf file: 
> you might need to copy there any other provider if in use

```
terraform {
  required_providers {
    fmc = {
      source = "netascode/fmc"
      version = "6.6.1"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 0.2.6"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }
}
```
You can now:
```
terraform init -plugin-dir="bin"
terraform apply
```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_fmc"></a> [fmc](#requirement\_fmc) | 6.6.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.3.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.2.6 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_fmc_password"></a> [fmc\_password](#input\_fmc\_password) | FMC Password | `string` | `""` | no |
| <a name="input_fmc_username"></a> [fmc\_username](#input\_fmc\_username) | FMC Username | `string` | `""` | no |
| <a name="input_manage_deployment"></a> [manage\_deployment](#input\_manage\_deployment) | Enables support for FTD deployments | `bool` | `true` | no |
| <a name="input_model"></a> [model](#input\_model) | As an alternative to YAML files, a native Terraform data structure can be provided as well. | `map(any)` | `{}` | no |
| <a name="input_write_default_values_file"></a> [write\_default\_values\_file](#input\_write\_default\_values\_file) | Write all default values to a YAML file. Value is a path pointing to the file to be created. | `string` | `""` | no |
| <a name="input_yaml_directories"></a> [yaml\_directories](#input\_yaml\_directories) | List of paths to YAML directories. | `list(string)` | <pre>[<br>  "data"<br>]</pre> | no |
| <a name="input_yaml_files"></a> [yaml\_files](#input\_yaml\_files) | List of paths to YAML files. | `list(string)` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acp"></a> [acp](#output\_acp) | ACP |
| <a name="output_default_values"></a> [default\_values](#output\_default\_values) | All default values. |
| <a name="output_model"></a> [model](#output\_model) | Full model. |
## Resources

| Name | Type |
|------|------|
| [fmc_access_control_policy.accesspolicy](https://registry.terraform.io/providers/netascode/fmc/6.6.1/docs/resources/access_control_policy) | resource |
| [fmc_host.host](https://registry.terraform.io/providers/netascode/fmc/6.6.1/docs/resources/host) | resource |
| [fmc_network.network](https://registry.terraform.io/providers/netascode/fmc/6.6.1/docs/resources/network) | resource |
| [local_sensitive_file.defaults](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [utils_yaml_merge.defaults](https://registry.terraform.io/providers/netascode/utils/latest/docs/data-sources/yaml_merge) | data source |
| [utils_yaml_merge.model](https://registry.terraform.io/providers/netascode/utils/latest/docs/data-sources/yaml_merge) | data source |
## Modules

No modules.
<!-- END_TF_DOCS -->