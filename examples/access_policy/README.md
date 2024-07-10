<!-- BEGIN_TF_DOCS -->
# FMC Network/Host Objects Example

This example will create a new `MyNetwork1`, `MyNetwork2`

Set environment variables pointing to FMC, create `terraform.tfvars`:

```bash
fmc_username = "admin"
fmc_password = "SecretPass123!"
```

To run this example you need to have terraform-provider-fmc version 2.0. If you have the copy of the new provider on your local disk, please execute:

```bash
$ terraform init -plugin-dir="bin"
$ terraform apply
```

The full path for the provider should be:
```
├── bin
│   └── registry.terraform.io
│       └── netascode
│           └── fmc
│               └── 0.0.666
│                   └── darwin_arm64
│                       └── terraform-provider-fmc
```
then you can use the provider as below:
```
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    fmc = {
      source = "netascode/fmc"
      version = "0.0.666"   #<<< should match folder from bin directory
    }
}
```
Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

#### `data/existing.yaml`

```yaml
---
existing:
  fmc:
    domains:
      - name: Global
        objects:
          networks:
            - name: any-ipv4
```

#### `data/fmc.yaml`

```yaml
---
fmc:
  name: MyFMCName1
  smart_license:
    registration_type: EVALUATION    
  domains:
    - name: Global        
      access_policies:
        - name: MyAccessPolicyName1
          categories: 
          - name: MyCategoryName1
            section: mandatory
          - name: MyCategoryName2
            section: mandatory   
          - name: MyCategoryName2.5            
            section: mandatory                   
          - name: MyCategoryName3
            section: default
          - name: MyCategoryName4          
          #default_action: "BLOCK"      
          access_rules:
            - name: MyAccessRuleNAme1
              action: ALLOW
              category: MyCategoryName1                 
              source_zones:
              - outside
              destination_zones:
              - inside
              source_networks:
              - Server_1
              destination_networks:
              - Server_2
              destination_ports:
              - HTTP
              ips_policy: MyIntrusionPolicyName1
              log_connection_begin: true
              log_connection_end: true
              log_files: false
              send_events_to_fmc: true                  
            - name: MyAccessRuleNAme1.5
              action: ALLOW
              category: MyCategoryName2              
              source_zones:
              - outside
              destination_zones:
              - inside
              source_networks:
              - Server_1
              destination_networks:
              - Server_2
              destination_ports:
              - HTTP
              ips_policy: MyIntrusionPolicyName1
              log_connection_begin: true
              log_connection_end: true
              log_files: false
              send_events_to_fmc: true           
            - name: MyAccessRuleNAme2.5
              action: TRUST
              category: MyCategoryName2.5     
              source_zones:
              - outside
              destination_zones:
              - inside
              source_networks:
              - LAN_1
              - 10.0.0.0/24
              - 6.6.6.6
              destination_networks:
              - LAN_1
              - LAN_2
              destination_ports:
              - HTTP
              ips_policy: MyIntrusionPolicyName1
              log_connection_begin: true
              log_connection_end: true
              log_files: false
              send_events_to_fmc: true                                  
            - name: MyAccessRuleNAme2
              action: TRUST
              category: MyCategoryName4         
              source_zones:
              - outside
              destination_zones:
              - inside
              source_networks:
              - LAN_1
              - 10.0.0.0/24
              - 6.6.6.6
              destination_networks:
              - LAN_1
              - LAN_2
              destination_ports:
              - HTTP
              ips_policy: MyIntrusionPolicyName1
              log_connection_begin: true
              log_connection_end: true
              log_files: false
              send_events_to_fmc: true               
      objects:
        hosts: 
          - name: Server_1
            ip: 10.62.100.101         
          - name: Server_2
            ip: 10.62.100.102
          - name: Server_3
            ip: 10.62.100.103          
        networks:
          - name: LAN_1
            prefix: 100.64.100.0/24
          - name: LAN_2
            prefix: 10.62.200.0/24
```

#### `main.tf`

```hcl
module "fmc" {
  source  = "netascode/nac-fmc/fmc"
  version = ">= 0.1.0"

  yaml_files = ["fmc.yaml", "existing.yaml"]
}
```
<!-- END_TF_DOCS -->