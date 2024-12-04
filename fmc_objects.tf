##########################################################
###    Content of the file:
##########################################################
#
###
#  Resources
####
# resource "fmc_hosts" "hosts"
# resource "fmc_networks" "networks" 
# resource "fmc_ranges" "ranges" 
# resource "fmc_network_groups" "network_groups"
# resource "fmc_ports" "ports" {
# resource "fmc_icmpv4_objects"
# resource "fmc_security_zone" "security_zone" {
# resource "fmc_dynamic_objects" "dynamic_objects" {
#
###  
#  Local variables
###
# local.resource_hosts              => for building dynamic resource - for bulk resource
# local.resource_networks           => for building dynamic resource - for bulk resource
# local.resource_ranges           => for building dynamic resource - for bulk resource
# local.resource_network_groups     => for building dynamic resource - for bulk resource
# local.resource_ports              => for building dynamic resource - for bulk resource
# local.resource_icmpv4s            => for building dynamic resource - for bulk resource
# local.resource_security_zone      => for building dynamic resource - for single resource
# local.resource_dynamic_objects    => for building dynamic resource - for bulk resource
#
# Mappings 
#
# local.map_network_objects         => to collect all network objects by name that can be used in Access Control Policy or IPv4 Static Route
# local.map_network_group_objects   => as per above - needs to be separate to avoid circular error 
# local.map_dynamic_objects         => to collect all dynamic objects by name that can be used later in the module
# local.map_services                => to collect all port and icmpv4 objects by name that can be used later in the module
# local.map_security_zones          => to collect all security_zone objects by name that can be used later in the module
# 
###

##########################################################
###    Example of created local variables
##########################################################

#  + resource_host   = {
#      + "10.0.0.1"   = {
#          + description = " "
#          + domain_name = "Global"
#          + ip          = "10.0.0.1"
#          + name        = "10.0.0.1"
#        }
#    }

#  + resource_hosts = {
#      + Global = {
#          + items = {
#              + Test           = {
#                  + ip   = "1.1.1.1"
#                  + name = "Test"
#                }
#            }
#        }
#    }

# 
# + help_network_objects = [
#      + "Host_1",
#    ]

#  + map_network_group_objects = {
#     + DC_1   = {
#          + domain_name = "Global"
#          + id          = "005056B0-2ED4-0ed3-0000-004294968756"
#          + name        = "DC_1"
#          + type        = "NetworkGroup"
#        }
#    }

##########################################################
###    HOSTS
##########################################################
locals {

#  resource_host = { 
#    for item in flatten([
#      for domain in local.domains : [ 
#        for item_value in try(domain.objects.hosts, []) : [ 
#          merge(item_value, 
#            {
#              "domain_name" = domain.name
#            })
#        ]
#      ]
#      ]) : item.name => item if contains(keys(item), "name" ) && !contains(try(keys(local.data_host), []), item.name)
#  }

  resource_hosts = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.hosts, []) : item.name => item if !contains(try(keys(local.data_hosts[domain.name].items), []), item.name)
        } 
    } if length(try(domain.objects.hosts, [])) > 0
  }

}

####################
# Superseded by bulk
####################
#resource "fmc_host" "host" {
#  for_each = local.resource_host
#  # Mandatory
#  name  = each.key
#  ip    = each.value.ip
#
#  # Optional
#  domain = try(each.value.domain_name, null)
#  description = try(each.value.description, local.defaults.fmc.domains.objects.hosts.description, null)
#}

resource "fmc_hosts" "hosts" {
  for_each =  local.resource_hosts

  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
      ip            = item_value.ip 
      # Optional
      description   = try(item_value.description, local.defaults.fmc.domains.objects.hosts.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    NETWORKS
##########################################################
locals {

  resource_networks = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.networks, []) : item.name => item if !contains(try(local.data_networks[domain.name].itmes, []), item.name)
      }
    } if length(try(domain.objects.networks, [])) > 0
  } 

}

resource "fmc_networks" "networks" {
  for_each =  local.resource_networks

  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
      prefix        = item_value.prefix 
      # Optional
      description   = try(item_value.description, local.defaults.fmc.domains.objects.networks.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    RANGES
##########################################################
locals {

  resource_ranges = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.ranges, []) : item.name => item if !contains(try(local.data_ranges[domain.name].itmes, []), item.name)
      }
    } if length(try(domain.objects.ranges, [])) > 0
  } 

}

resource "fmc_ranges" "ranges" {
  for_each =  local.resource_ranges

  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
      ip_range    = item_value.ip_range 
      # Optional
      description = try(item_value.description, local.defaults.fmc.domains.objects.ranges.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    FQDNS
##########################################################
locals {

  resource_fqdns = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.fqdns, []) : item.name => item if !contains(try(local.data_fqdns[domain.name].itmes, []), item.name)
      }
    } if length(try(domain.objects.fqdns, [])) > 0
  } 

}

resource "fmc_fqdn_objects" "fqdns" {
  for_each =  local.resource_fqdns

  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
      fqdn            = item_value.fqdn 
      # Optional
      dns_resolution  = try(item_value.dns_resolution, local.defaults.fmc.domains.objects.fqdns.dns_resolution, null)
      description     = try(item_value.description, local.defaults.fmc.domains.objects.fqdns.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    NETWORK GROUPS
##########################################################

locals {

  help_network_objects = flatten([ 
      for item in keys(local.map_network_objects) : item
    ])

  resource_network_groups = {
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.network_groups, {}) : item.name => {
          # Mandatory
          name            = item.name
          objects         = [ for object_item in try(item.objects, []) : {
            id      = local.map_network_objects[object_item].id
            } if contains(local.help_network_objects, object_item) ] 
          literals        = [ for literal_item in try(item.literals, []) : {
            value   = literal_item
            }] 
          network_groups  = [ for object_item in try(item.objects, []) : object_item if !contains(local.help_network_objects, object_item) ]         
          domain_name     = domain.name
          description     = try(item.description, null)
        }
      }
    } if length(try(domain.objects.network_groups, [])) > 0
  }

}

resource "fmc_network_groups" "network_groups" {
  for_each =  local.resource_network_groups 

  # Optional  
  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory - one from below
      objects         = try(item_value.objects, [])
      literals        = try(item_value.literals, [])
      network_groups  = try(item_value.network_groups, [])
      # Optional
      description     = item_value.description
    }
  }

  domain = try(each.value.domain_name, null)
  depends_on = [ 
    data.fmc_hosts.hosts,
    fmc_hosts.hosts,
    data.fmc_networks.networks,
    fmc_networks.networks,
    data.fmc_ranges.ranges,
    fmc_ranges.ranges,    
    #fmc_fqdn_objects.fqdns,
   ]
  lifecycle {   
    create_before_destroy = true
  }
}

##########################################################
###    PORTS
##########################################################
locals {

  resource_ports = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.ports, []) : item.name => item if !contains(try(keys(local.data_ports[domain.name].items), []), item.name)
        } 
    } if length(try(domain.objects.ports, [])) > 0
  }

}

resource "fmc_ports" "ports" {
  for_each =  local.resource_ports

  # Mandatory 
  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
      protocol    = item_value.protocol
      port        = item_value.port
      # Optional
      description = try(item_value.description, local.defaults.fmc.domains.objects.ports.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    ICMPv4s
##########################################################
locals {

  resource_icmpv4s = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.icmpv4s, []) : item.name => item if !contains(try(keys(local.data_icmpv4s[domain.name].items), []), item.name)
        } 
    } if length(try(domain.objects.icmpv4s, [])) > 0
  }

}

resource "fmc_icmpv4_objects" "icmpv4s" {
  for_each =  local.resource_icmpv4s

  # Mandatory 
  items =   { for item_key, item_value in each.value.items : item_key => {
      # Optional
      icmp_type   = try(item_value.icmp_type, null)
      code        = try(item_value.code, null)
      description = try(item_value.description, local.defaults.fmc.domains.objects.icmpv4s.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    Port_Groups
##########################################################
locals {

  resource_port_groups = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.port_groups, {}) : item.name => {
          # Mandatory
          name            = item.name
          objects         = [ for object_item in try(item.objects, []) : {
            id      = local.map_services[object_item].id
            type    = local.map_services[object_item].type            
          } ] 

          domain_name     = domain.name
          description     = try(item.description, null)
        }
      }
    } if length(try(domain.objects.port_groups, [])) > 0
  }

}

resource "fmc_port_groups" "port_groups" {
  for_each =  local.resource_port_groups 

  # Mandatory 
  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory 
      description     = item_value.description
      objects         = item_value.objects
      # Optional
      description     = item_value.description
    }
  }

  domain = try(each.value.domain_name, null)
  depends_on = [ 
    data.fmc_ports.ports,
    fmc_ports.ports,
    data.fmc_icmpv4_objects.icmpv4s,
    fmc_icmpv4_objects.icmpv4s,
   ]
  lifecycle {   
    create_before_destroy = true
  }
}

##########################################################
###    DYNAMIC OBJECT
##########################################################
locals {

  resource_dynamic_objects = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.dynamic_objects, []) : item.name => item if !contains(try(keys(local.data_dynamic_objects[domain.name].items), []), item.name)
        } 
    } if length(try(domain.objects.dynamic_objects, [])) > 0
  }

}

resource "fmc_dynamic_objects" "dynamic_objects" {
  for_each =  local.resource_dynamic_objects

  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
      object_type     = item_value.type
      mappings        = try(item_value.mappings, [])
      # Optional
      description = try(item_value.description, local.defaults.fmc.domains.objects.dynamic_objects.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    URLs
##########################################################
locals {

  resource_urls = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.urls, []) : item.name => item if !contains(try(keys(local.data_urls[domain.name].items), []), item.name)
        } 
    } if length(try(domain.objects.urls, [])) > 0
  }

}

resource "fmc_urls" "urls" {
  for_each =  local.resource_urls

  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
      url           = item_value.url
      # Optional
      description   = try(item_value.description, local.defaults.fmc.domains.objects.urls.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    URL_Groups
##########################################################
locals {

  resource_url_groups = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.url_groups, {}) : item.name => {
          # Mandatory
          name            = item.name
          urls            = [ for url_item in try(item.urls, []) : {
            id            = local.map_urls[url_item].id
          } ]
          literals        = [ for literal_item in try(item.literals, []) : {
            url           = literal_item
          } ]

          domain_name     = domain.name
          description     = try(item.description, null)
        }
      }
    } if length(try(domain.objects.url_groups, [])) > 0
  }

}

resource "fmc_url_groups" "url_groups" {
  for_each =  local.resource_url_groups 

  # Mandatory 
  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory 
      urls            = item_value.urls
      literals        = item_value.literals
      # Optional
      description     = item_value.description
    }
  }

  domain = try(each.value.domain_name, null)
  depends_on = [ 
    data.fmc_urls.urls,
    fmc_urls.urls,
   ]
  lifecycle {   
    create_before_destroy = true
  }
}

##########################################################
###    VLAN Tags (SGTs)
##########################################################
locals {

  resource_vlan_tags = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.vlan_tags, []) : item.name => item if !contains(try(keys(local.data_vlan_tags[domain.name].items), []), item.name)
        } 
    } if length(try(domain.objects.vlan_tags, [])) > 0
  }

}

resource "fmc_vlan_tags" "vlan_tags" {
  for_each =  local.resource_vlan_tags

  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
      start_tag     = item_value.start_tag
      end_tag       = try(item_value.end_tag, item_value.start_tag)

      # Optional
      description   = try(item_value.description, local.defaults.fmc.domains.objects.vlan_tags.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    VLAN_Tag_Groups
##########################################################
locals {

  resource_vlan_tag_groups = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.vlan_tag_groups, {}) : item.name => {
          # Mandatory
          name              = item.name
          vlan_tags         = [ for vlan_tag_item in try(item.vlan_tags, []) : {
            id          = local.map_vlan_tags[vlan_tag_item].id
          } ]
          literals          = [ for literal_item in try(item.literals, {}) : {
            start_tag   = literal_item.start_tag
            end_tag     = try(literal_item.end_tag, literal_item.start_tag)
          } ]

          domain_name       = domain.name
          description       = try(item.description, null)
        }
      }
    } if length(try(domain.objects.vlan_tag_groups, [])) > 0
  }

}

resource "fmc_vlan_tag_groups" "vlan_tag_groups" {
  for_each =  local.resource_vlan_tag_groups 

  # Mandatory 
  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory 
      vlan_tags       = item_value.vlan_tags
      literals        = item_value.literals
      # Optional
      description     = item_value.description
    }
  }

  domain = try(each.value.domain_name, null)
  depends_on = [ 
    data.fmc_vlan_tags.vlan_tags,
    fmc_vlan_tags.vlan_tags,
   ]
  lifecycle {   
    create_before_destroy = true
  }
}

##########################################################
###    Security Group Tags
##########################################################
locals {

  resource_sgts = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.sgts, []) : item.name => item if !contains(try(keys(local.data_sgts[domain.name].items), []), item.name)
        } 
    } if length(try(domain.objects.sgts, [])) > 0
  }

}

#resource "fmc_sgts" "sgts" {
#  for_each = local.resource_sgts

#  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
#      interface_mode     = try(item_value.interface_type, local.defaults.fmc.domains.objects.security_zones.interface_type)
#    }
#  }

  # Optional
#  domain = try(each.value.domain_name, null)
#}

##########################################################
###    SECURITY ZONE
##########################################################
locals {

  resource_security_zones = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.security_zones, []) : item.name => item if !contains(try(keys(local.data_security_zones[domain.name].items), []), item.name)
        } 
    } if length(try(domain.objects.security_zones, [])) > 0
  }

}

resource "fmc_security_zones" "security_zones" {
  for_each = local.resource_security_zones

  items =   { for item_key, item_value in each.value.items : item_key => {
      # Mandatory
      interface_mode     = try(item_value.interface_type, local.defaults.fmc.domains.objects.security_zones.interface_type)
    }
  }

  # Optional
  domain = try(each.value.domain_name, null)
}

##########################################################
###    Create maps for combined set of _data and _resources network objects 
##########################################################
######
### map_network_objects
######

locals {
  map_network_objects = merge({
    for item in flatten([
      for domain_key, domain_value in local.resource_hosts : 
        flatten([ for item_key, item_value in domain_value.items : { 
          name        = item_key
          id          = fmc_hosts.hosts[domain_key].items[item_key].id
          type        = fmc_hosts.hosts[domain_key].items[item_key].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },   
    {
      for item in flatten([
        for domain_key, domain_value in local.data_hosts : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_hosts.hosts[domain_key].items[element].id
          type        = data.fmc_hosts.hosts[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },
    {
    for item in flatten([
      for domain_key, domain_value in local.resource_networks : 
        flatten([ for item_key, item_value in domain_value.items : { 
          name        = item_key
          id          = fmc_networks.networks[domain_key].items[item_key].id
          type        = fmc_networks.networks[domain_key].items[item_key].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },     
    {
      for item in flatten([
        for domain_key, domain_value in local.data_networks : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_networks.networks[domain_key].items[element].id
          type        = data.fmc_networks.networks[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },    
    {
    for item in flatten([
      for domain_key, domain_value in local.resource_ranges : 
        flatten([ for item_key, item_value in domain_value.items : { 
          name        = item_key
          id          = fmc_ranges.ranges[domain_key].items[item_key].id
          type        = fmc_ranges.ranges[domain_key].items[item_key].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },     
    {
      for item in flatten([
        for domain_key, domain_value in local.data_ranges : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_ranges.ranges[domain_key].items[element].id
          type        = data.fmc_ranges.ranges[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },
    {
    for item in flatten([
      for domain_key, domain_value in local.resource_fqdns : 
        flatten([ for item_key, item_value in domain_value.items : { 
          name        = item_key
          id          = fmc_fqdn_objects.fqdns[domain_key].items[item_key].id
          type        = fmc_fqdn_objects.fqdns[domain_key].items[item_key].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },     
    {
      for item in flatten([
        for domain_key, domain_value in local.data_fqdns : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_fqdn_objects.fqdns[domain_key].items[element].id
          type        = data.fmc_fqdn_objects.fqdns[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },        
  )
}

######
### map_dynamic_objects
######
locals {
  map_dynamic_objects = merge({
    for item in flatten([
      for domain_key, domain_value in local.resource_dynamic_objects : 
        flatten([ for item_key, item_value in domain_value.items : { 
          name        = item_key
          id          = fmc_dynamic_objects.dynamic_objects[domain_key].items[item_key].id
          type        = fmc_dynamic_objects.dynamic_objects[domain_key].items[item_key].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },   
    {
      for item in flatten([
        for domain_key, domain_value in local.data_dynamic_objects : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_dynamic_objects.dynamic_objects[domain_key].items[element].id
          type        = data.fmc_dynamic_objects.dynamic_objects[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },  
  )
}
######
### map_services - ports + icmpv4s
######
locals {
  map_services = merge({
      for item in flatten([
        for domain_key, domain_value in local.resource_ports : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = fmc_ports.ports[domain_key].items[item_key].id
            type        = fmc_ports.ports[domain_key].items[item_key].type
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },
    {
      for item in flatten([
        for domain_key, domain_value in local.data_ports : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_ports.ports[domain_key].items[element].id
          type        = data.fmc_ports.ports[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },
    {
      for item in flatten([
        for domain_key, domain_value in local.resource_icmpv4s : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = fmc_icmpv4_objects.icmpv4s[domain_key].items[item_key].id
            type        = fmc_icmpv4_objects.icmpv4s[domain_key].items[item_key].type
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },
    {
      for item in flatten([
        for domain_key, domain_value in local.data_icmpv4s : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_icmpv4_objects.icmpv4s[domain_key].items[element].id
          type        = data.fmc_icmpv4_objects.icmpv4s[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },    
  )

}
######
### map_service_groups
######
locals {
  map_service_groups = merge({
      for item in flatten([
        for domain_key, domain_value in local.resource_port_groups : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = try(fmc_port_groups.port_groups[domain_key].items[item_key].id, null)
            type        = try(fmc_port_groups.port_groups[domain_key].items[item_key].type, null)
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    }, 
    {
      for item in flatten([
        for domain_key, domain_value in local.data_port_groups : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = try(data.fmc_port_groups.port_groups[domain_key].items[item_key].id, null)
            type        = try(data.fmc_port_groups.port_groups[domain_key].items[item_key].type, null)
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },     
  )

}

######
### map_network_group_objects
######
locals {
  map_network_group_objects = merge({
      for item in flatten([
        for domain_key, domain_value in local.resource_network_groups : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = try(fmc_network_groups.network_groups[domain_key].items[item_key].id, null)
            type        = "NetworkGroup"
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },       
  )

}
######
### map_urls - urls data + resource
######
locals {
  map_urls = merge({
      for item in flatten([
        for domain_key, domain_value in local.resource_urls : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = fmc_urls.urls[domain_key].items[item_key].id
            #type = fmc_urls.urls[domain_key].items[item_key].type
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },    
    {
      for item in flatten([
        for domain_key, domain_value in local.data_urls : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_urls.urls[domain_key].items[element].id
          #type        = data.fmc_urls.urls[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },  
  )

  map_url_groups = merge({
      for item in flatten([
        for domain_key, domain_value in local.resource_url_groups : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = fmc_url_groups.url_groups[domain_key].items[item_key].id
            #type = fmc_urls.urls[domain_key].items[item_key].type
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },    
    {
      for item in flatten([
        for domain_key, domain_value in local.data_url_groups : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_url_groups.url_groups[domain_key].items[element].id
          #type        = data.fmc_urls.urls[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    }, 
  )


}
######
### map_vlan_tags - vlan_tags data + resource
######
locals {
  map_vlan_tags = merge({
      for item in flatten([
        for domain_key, domain_value in local.resource_vlan_tags : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = fmc_vlan_tags.vlan_tags[domain_key].items[item_key].id
            #type = fmc_vlan_tags.vlan_tags[domain_key].items[item_key].type
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },    
    {
      for item in flatten([
        for domain_key, domain_value in local.data_vlan_tags : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_vlan_tags.vlan_tags[domain_key].items[element].id
          #type        = data.fmc_vlan_tags.vlan_tags[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },
  )
  
  map_vlan_tag_groups = merge({
      for item in flatten([
        for domain_key, domain_value in local.resource_vlan_tag_groups : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = fmc_vlan_tag_groups.vlan_tag_groups[domain_key].items[item_key].id
            #type = fmc_vlan_tags.vlan_tags[domain_key].items[item_key].type
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },    
    {
      for item in flatten([
        for domain_key, domain_value in local.data_vlan_tag_groups : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_vlan_tag_groups.vlan_tag_groups[domain_key].items[element].id
          #type        = data.fmc_vlan_tags.vlan_tags[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },  
  )

}

######
### map_sgts - security group tags data + resource
######
#locals {
#  map_sgts = merge({
#      for item in flatten([
#        for domain_key, domain_value in local.resource_sgts : 
#          flatten([ for item_key, item_value in domain_value.items : { 
#            name        = item_key
#            id          = fmc_sgts.sgts[domain_key].items[item_key].id
#            type        = fmc_sgts.sgts[domain_key].items[item_key].type
#            domain_name = domain_key
#          }])
#        ]) : item.name => item if contains(keys(item), "name" )
#    },    
#    {
#      for item in flatten([
#        for domain_key, domain_value in local.data_sgts : 
#          flatten([ for element in keys(domain_value.items): {
#          name        = element
#          id          = data.fmc_sgts.sgts[domain_key].items[element].id
#          type        = data.fmc_sgts.sgts[domain_key].items[element].type
#          domain_name = domain_key
#        }])
#      ]) : item.name => item if contains(keys(item), "name" )
#    },  
#  )
#  
#}


######
### map_security_zones - security zones data + resource
######
locals {
  map_security_zones = merge({
      for item in flatten([
        for domain_key, domain_value in local.resource_security_zones : 
          flatten([ for item_key, item_value in domain_value.items : { 
            name        = item_key
            id          = fmc_security_zones.security_zones[domain_key].items[item_key].id
            type        = fmc_security_zones.security_zones[domain_key].items[item_key].type
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },    
    {
      for item in flatten([
        for domain_key, domain_value in local.data_security_zones : 
          flatten([ for element in keys(domain_value.items): {
          name        = element
          id          = data.fmc_security_zones.security_zones[domain_key].items[element].id
          type        = data.fmc_security_zones.security_zones[domain_key].items[element].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },  
  )
  
}


######
### FAKE - TODO
######

locals {
  map_url_categories = {}
  map_variable_sets = {}
  map_ipv6_dhcp_pools = {}
}