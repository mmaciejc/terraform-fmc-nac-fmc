terraform {
  #required_version = ">= 1.3.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.2"
    }
  }
}


locals {
  data = {
    fmc = {
        domains = [
            {
                name = "global"
                objects = {
                    networks = [
                        {
                            name = "nazwa1"
                            objects = [ "1.1.1.1", "10.0.0.0/24", "20.0.0.0/24" ]
                        },
                        {
                            name = "nazwa2"
                            objects = [ "2.2.2.2" ]
                        }
                    ]
                }
            }
        ]
    }
  }


  resource_network_groups = {
    for domain in local.data.fmc.domains : domain.name => {
      items = {
        for item in try(domain.objects.networks, {}) : item.name => {
          # Mandatory
          name = item.name
          #objects = try(length(item.objects), 0) > 0 ? [for object in try(item.objects, []) : {
          #  ip = object
          #}  ] : null
          objects = length( [ for object in try(item.objects, []) : object  if can(regex("/", object)) ]) > 0 ? "host" : "network"
          #  ip = object
          #}  ] : null
    #can(regex("/", destination_network_literal)) ? "Network" : "Host"
          #network_groups = [for object_item in try(item.objects, []) : object_item if !contains(local.help_network_objects, object_item)]
        }
      }

      domain_name = domain.name
    } 
  }


}   



output "data" {
  value       = local.data 
}

output "resource_network_groups" {
  value       = local.resource_network_groups 
}