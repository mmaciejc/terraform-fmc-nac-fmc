#############################################################
# Define terraform data representation of objects that already exist on FMC
##########################################################
###    Content of the file:
##########################################################
#
###
#  Data sources
####
# data "fmc_hosts" "hosts"
# data "fmc_networks" "networks"
# data "fmc_ranges" "ranges"
# data "fmc_ports" "ports"
# data "fmc_icmpv4_objects" "icmpv4s"
# data "fmc_security_zones" "security_zones"
# data "fmc_dynamic_objects"
# data "fmc_access_control_policy" "access_control_policy"
# data "fmc_device" "device"
# data "fmc_device_physical_interface" "physical_interface"
###  
#  Local variables
###
# local.data_devices                => for building dynamic data source
# local.data_access_control_policy  => for building dynamic data source
# local.data_hosts                  => for building dynamic data source
# local.data_networks               => for building dynamic data source
# local.data_ranges                 => for building dynamic data source
# locals data_security_zones        => for building dynamic data source
# local.data_dynamic_objects        => for building dynamic data source
# local.data_ports                  => for building dynamic data source
# local.data_icmpv4s                => for building dynamic data source
# local.map_interfaces              => to collect all interface objects by name that can be used later in the module
#
###
##########################################################
###    Example of created local variables
##########################################################

#  + data_hosts = {
#      + Global = {
#          + items = {
#              + Host_1 = {}
#            }
#        }
#    }

##########################################################
##########################################################
###    Objects
##########################################################
##########################################################

##########################################################
###    Hosts + Networks + Ranges + FQDNs
##########################################################
locals {

  data_hosts = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.hosts, []) : element.name => {}
        }
    } 
  }

}

data "fmc_hosts" "hosts" {
  for_each = local.data_hosts
  
  items   = each.value.items
  domain  = each.key
}

locals {

# data_network = { 
#    for item in flatten([
#      for domain in try(local.data_existing.fmc.domains, {}) : [ 
#        for element in try(domain.objects.networks, {}) : {
#          "name"        = element.name
#          "domain_name" = domain.name
#        }
#      ]
#      ]) : item.name => item if contains(keys(item), "name" )
#    } 

  data_networks = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.networks, []) : element.name => {}
      }
    } 
  }

}

#data "fmc_network" "network" {
#  for_each = local.data_network
  
#  name    = each.key
#  domain  = each.value.domain_name
#}

data "fmc_networks" "networks" {
  for_each = local.data_networks
  
  items   = each.value.items
  domain  = each.key
}

locals {

  data_ranges = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.ranges, []) : element.name => {}
      }
    } 
  }

}

data "fmc_ranges" "ranges" {
  for_each = local.data_ranges
  
  items   = each.value.items
  domain  = each.key
}

locals {

  data_fqdns = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.fqdns, []) : element.name => {}
      }
    } 
  }

}

data "fmc_fqdn_objects" "fqdns" {
  for_each = local.data_fqdns
  
  items   = each.value.items
  domain  = each.key
}

##########################################################
###    PORTS + ICMPv4s + Port_Groups
##########################################################
locals {

  data_ports = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.ports, []) : element.name => {}
        }
    } 
  }

}

data "fmc_ports" "ports" {
  for_each = local.data_ports
  
  items   = each.value.items
  domain  = each.key
}

locals {

  data_icmpv4s = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.icmpv4s, []) : element.name => {}
        }
    } 
  }

}

data "fmc_icmpv4_objects" "icmpv4s" {
  for_each = local.data_icmpv4s
  
  items   = each.value.items
  domain  = each.key
}

locals {

  data_port_groups = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.port_groups, []) : element.name => {}
        }
    } 
  }

}

data "fmc_port_groups" "port_groups" {
  for_each = local.data_port_groups
  
  items   = each.value.items
  domain  = each.key
}

##########################################################
###    DYNAMIC OBJECTS
##########################################################
locals {

  data_dynamic_objects = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.dynamic_objects, []) : element.name => {}
        }
    } 
  }

}

data "fmc_dynamic_objects" "dynamic_objects" {
  for_each = local.data_dynamic_objects
  
  items   = each.value.items
  domain  = each.key
}

##########################################################
###    URLs + URL_Groups
##########################################################
locals {

  data_urls = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.urls, []) : element.name => {}
        }
    } 
  }

}

data "fmc_urls" "urls" {
  for_each = local.data_urls
  
  items   = each.value.items
  domain  = each.key
}

locals {

  data_url_groups = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.url_groups, []) : element.name => {}
        }
    } 
  }

}

data "fmc_url_groups" "url_groups" {
  for_each = local.data_url_groups
  
  items   = each.value.items
  domain  = each.key
}

##########################################################
###    SGTs (VLAN Tags) + SGT Groups
##########################################################
locals {

  data_vlan_tags = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.vlan_tags, []) : element.name => {}
        }
    } 
  }

}

data "fmc_vlan_tags" "vlan_tags" {
  for_each = local.data_vlan_tags
  
  items   = each.value.items
  domain  = each.key
}

locals {

  data_vlan_tag_groups = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.vlan_tag_groups, []) : element.name => {}
        }
    } 
  }

}

data "fmc_vlan_tag_groups" "vlan_tag_groups" {
  for_each = local.data_vlan_tag_groups
  
  items   = each.value.items
  domain  = each.key
}

##########################################################
###    Security Group Tags
##########################################################
locals {

  data_sgts = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.sgts, []) : element.name => {}
        }
    } 
  }

}

#data "fmc_sgts" "sgts" {
#  for_each = local.data_sgts
  
#  items   = each.value.items
#  domain  = each.key
#}

##########################################################
###    SECURITY ZONE
##########################################################
locals {

  data_security_zones = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = {
        for element in try(domain.objects.security_zones, []) : element.name => {}
        }
    } 
  }

}

data "fmc_security_zones" "security_zones" {
  for_each = local.data_security_zones
  
  items   = each.value.items
  domain  = each.key
}
##########################################################
##########################################################
###    Alerts
##########################################################
##########################################################

##########################################################
###    SNMP Alert
##########################################################
locals {
  data_snmp_alerts = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for item_value in try(domain.policies.alerts.snmp, {}) : {
          "name"        = item_value.name
          "domain_name" = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" )
    } 

}

#data "fmc_snmp_alerts" "snmp_alerts" {
#  for_each = local.data_snmp_alerts
  
#  items   = each.value.items
#  domain  = each.key
#}

##########################################################
###    Syslog Alert
##########################################################
locals {
  data_syslog_alerts = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for item_value in try(domain.policies.alerts.syslog, {}) : {
          "name"        = item_value.name
          "domain_name" = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" )
    } 

}

#data "fmc_syslog_alert" "data_syslog_alerts" {
#  for_each = local.data_snmp_alerts
  
#  items   = each.value.items
#  domain  = each.key
#}

##########################################################
##########################################################
###    Policies
##########################################################
##########################################################

##########################################################
###    ACCESS CONTROL POLICY
##########################################################
locals {
  data_access_control_policy = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for item_value in try(domain.policies.access_policies, {}) : {
          "name"        = item_value.name
          "domain_name" = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" )
    } 

}

data "fmc_access_control_policy" "access_control_policy" {
  for_each = local.data_access_control_policy

  name    = each.value.name
  domain  = each.value.domain_name    
}

##########################################################
###    FTD NAT Policy
##########################################################
locals {
  data_ftd_nat_policy = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for item_value in try(domain.policies.ftd_nat_policies, {}) : {
          "name"        = item_value.name
          "domain_name" = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" )
    } 

}

data "fmc_ftd_nat_policy" "ftd_nat_policy" {
  for_each = local.data_ftd_nat_policy

  name    = each.value.name
  domain  = each.value.domain_name    
}

##########################################################
###    Intrusion (IPS) Policy
##########################################################
locals {
  data_intrusion_policy = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for item_value in try(domain.policies.intrusion_policies, {}) : {
          "name"        = item_value.name
          "domain_name" = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" )
    } 

}

data "fmc_intrusion_policy" "intrusion_policy" {
  for_each = local.data_intrusion_policy

  name    = each.value.name
  domain  = each.value.domain_name    
}

# Legacy part - to be modified

##########################################################
###    DEVICE
##########################################################
locals {

 data_device = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for item_value in try(domain.devices.devices, {}) : {
          "name"        = item_value.name
          "id"        = try(item_value.id, null)
          "domain_name" = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "domain_name" ) && contains(keys(item), "id") # name not supported in provider yet, then id can be removed
    } 

}

data "fmc_device" "device" {
  for_each = local.data_device

  id      = each.value.id
  #name   = each.value.name  # not supported in provider yet
  domain = each.value.domain_name
}

############################################################################################
# OLD code!

##########################################################
###    PHYSICAL INTERFACE - to be modified
##########################################################
locals {
  map_interfaces = merge(concat(
    flatten([
      for domain in local.domains : [
        for device in try(domain.devices.devices, []) : {
          for physicalinterface in try(device.physical_interfaces, []) : "${device.name}/${physicalinterface.interface}" => {
            key               = "${device.name}/${physicalinterface.interface}"
            device_id         = local.map_devices[device.name].id
            device_name       = device.name
            data              = physicalinterface
            physicalinterface = physicalinterface.interface
            #id                = fmc_device_physical_interface.physical_interface["${device.name}/${physicalinterface.interface}"].id
            resource          = true
          }
        }
      ]
    ]),
    flatten([
      for device in try(local.data_existing.fmc.domains[0].devices.devices, []) : {
        for physicalinterface in try(device.physical_interfaces, []) : "${device.name}/${physicalinterface.interface}" => {
          key               = "${device.name}/${physicalinterface.interface}"
          device_id         = local.map_devices[device.name].id
          physicalinterface = physicalinterface.interface
          resource          = false
        }
      }
    ]),
    flatten([
      for domain in local.domains : [
        for cluster in try(domain.devices.clusters, []) : {
          for device in try(cluster.devices, []) : "${device.name}/${cluster.ccl_interface}" => {
            key               = "${device.name}/${cluster.ccl_interface}"
            device_id         = local.map_devices[device.name].id
            physicalinterface = cluster.ccl_interface
            resource          = false
          }
        }
      ]
    ])
    )...
  )
}

data "fmc_device_physical_interface" "physical_interface" {
  for_each = local.map_interfaces

  device_id = each.value.device_id
  name      = each.value.physicalinterface

  depends_on = [
    fmc_device.device,
    data.fmc_device.device
  ]
}