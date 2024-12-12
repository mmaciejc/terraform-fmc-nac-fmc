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
      items = {
        for host in try(domain.objects.hosts, []) : host.name => {}
        } 
    } if length(try(domain.objects.hosts, [])) > 0
  }

}

data "fmc_hosts" "module" {
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
      items = {
        for network in try(domain.objects.networks, []) : network.name => {}
      }
    } if length(try(domain.objects.networks, [])) > 0
  }

}

#data "fmc_network" "network" {
#  for_each = local.data_network
  
#  name    = each.key
#  domain  = each.value.domain_name
#}

data "fmc_networks" "module" {
  for_each = local.data_networks
  
    items   = each.value.items
    domain  = each.key
}

locals {

  data_ranges = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      items = {
        for range in try(domain.objects.ranges, []) : range.name => {}
      }
    } if length(try(domain.objects.ranges, [])) > 0
  }

}

data "fmc_ranges" "module" {
  for_each = local.data_ranges
  
    items   = each.value.items
    domain  = each.key
}

locals {

  data_fqdns = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      items = {
        for fqdn in try(domain.objects.fqdns, []) : fqdn.name => {}
      }
    } if length(try(domain.objects.fqdns, [])) > 0
  }

}

data "fmc_fqdn_objects" "module" {
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
      items = {
        for port in try(domain.objects.ports, []) : port.name => {}
        }
    } if length(try(domain.objects.ports, [])) > 0
  }

}

data "fmc_ports" "module" {
  for_each = local.data_ports
  
    items   = each.value.items
    domain  = each.key
}

locals {

  data_icmpv4s = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      items = {
        for icmpv4 in try(domain.objects.icmpv4s, []) : icmpv4.name => {}
        }
    } if length(try(domain.objects.icmpv4s, [])) > 0
  }

}

data "fmc_icmpv4_objects" "module" {
  for_each = local.data_icmpv4s
  
    items   = each.value.items
    domain  = each.key
}

locals {

  data_port_groups = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      items = {
        for port_group in try(domain.objects.port_groups, []) : port_group.name => {}
        }
    } if length(try(domain.objects.port_groups, [])) > 0
  }

}

data "fmc_port_groups" "module" {
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
      items = {
        for dynamic_object in try(domain.objects.dynamic_objects, []) : dynamic_object.name => {}
        }
    } if length(try(domain.objects.dynamic_objects, [])) > 0
  }

}

data "fmc_dynamic_objects" "module" {
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
      items = {
        for url in try(domain.objects.urls, []) : url.name => {}
        }
    } if length(try(domain.objects.urls, [])) > 0
  }

}

data "fmc_urls" "module" {
  for_each = local.data_urls
  
    items   = each.value.items
    domain  = each.key
}

locals {

  data_url_groups = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      items = {
        for url_group in try(domain.objects.url_groups, []) : url_group.name => {}
        }
    } if length(try(domain.objects.url_groups, [])) > 0
  } 

}

data "fmc_url_groups" "module" {
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
      items = {
        for vlan_tag in try(domain.objects.vlan_tags, []) : vlan_tag.name => {}
        }
    } if length(try(domain.objects.vlan_tags, [])) > 0
  }

}

data "fmc_vlan_tags" "module" {
  for_each = local.data_vlan_tags
  
    items   = each.value.items
    domain  = each.key
}

locals {

  data_vlan_tag_groups = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      items = {
        for vlan_tag_group in try(domain.objects.vlan_tag_groups, []) : vlan_tag_group.name => {}
        }
    } if length(try(domain.objects.vlan_tag_groups, [])) > 0
  }

}

data "fmc_vlan_tag_groups" "module" {
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
      items = {
        for sgt in try(domain.objects.sgts, []) : sgt.name => {}
        }
    } if length(try(domain.objects.sgts, [])) > 0
  } 

}

#data "fmc_sgts" "module" {
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
      items = {
        for security_zone in try(domain.objects.security_zones, []) : security_zone.name => {}
        }
    } if length(try(domain.objects.security_zones, [])) > 0
  } 

}

data "fmc_security_zones" "module" {
  for_each = local.data_security_zones

    items   = each.value.items
    domain  = each.key
}

##########################################################
###    ACCESS POLICY - STANDARD + EXTENDED
##########################################################
locals {
  data_standard_acl = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for element in try(domain.objects.standard_acls, {}) : {
          name        = element.name
          domain_name = domain.name
        }
      ]
      ]) : "${item.domain_name}:${item.name}" => item if contains(keys(item), "name" )
    } 

}

data "fmc_standard_acl" "module" {
  for_each = local.data_standard_acl

    name    = each.value.name
    domain  = each.value.domain_name    
}

locals {
  data_extended_acl = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for element in try(domain.objects.extended_acls, {}) : {
          name        = element.name
          domain_name = domain.name
        }
      ]
      ]) : "${item.domain_name}:${item.name}" => item if contains(keys(item), "name" )
    } 

}

data "fmc_extended_acl" "module" {
  for_each = local.data_extended_acl

    name    = each.value.name
    domain  = each.value.domain_name    
}

##########################################################
##########################################################
###    Templates
##########################################################
##########################################################
##########################################################
###    BFD TEMPLATES
##########################################################
locals {

  data_bfd_template = {
    for item in flatten([
      for domain in local.data_existing.fmc.domains : [
        for bfd_template in try(domain.objects.bfd_templates, []) : [ 
            {
              name        = bfd_template.name
              domain_name = domain.name
            } ]
      ]
      ]) : "${item.domain_name}:${item.name}" => item if contains(keys(item), "name") #The device name is unique across the different domains.
  }

}
data "fmc_bfd_template" "module" {
  for_each = local.data_bfd_template

    name        = each.value.name
    domain      = each.value.domain_name

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
      for domain in try(local.data_existing.fmc.domains, {})  : domain.name => { 
          items = { 
            for snmp in try(domain.policies.alerts.snmps, {}) : snmp.name => {}
          } 
      } if length(try(domain.policies.alerts.snmps, [])) > 0
    } 

}

data "fmc_snmp_alerts" "module" {
  for_each = local.data_snmp_alerts
  
    items   = each.value.items
    domain  = each.key
}

##########################################################
###    Syslog Alert
##########################################################
locals {
  data_syslog_alerts = { 
      for domain in try(local.data_existing.fmc.domains, {})  : domain.name => { 
          items = { 
            for syslog in try(domain.policies.alerts.syslogs, {}) : syslog.name => {}
          } 
      } if length(try(domain.policies.alerts.syslogs, [])) > 0
    } 

}

data "fmc_syslog_alerts" "module" {
  for_each = local.data_syslog_alerts
  
    items   = each.value.items
    domain  = each.key
}

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
        for access_policy in try(domain.policies.access_policies, {}) : {
          name        = access_policy.name
          domain_name = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" )
    } 

}

data "fmc_access_control_policy" "module" {
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
        for ftd_nat_policy in try(domain.policies.ftd_nat_policies, {}) : {
          name        = ftd_nat_policy.name
          domain_name = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" )
    } 

}

data "fmc_ftd_nat_policy" "module" {
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
        for intrusion_policy in try(domain.policies.intrusion_policies, {}) : {
          name        = intrusion_policy.name
          domain_name = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" )
    } 

}

data "fmc_intrusion_policy" "module" {
  for_each = local.data_intrusion_policy

    name    = each.value.name
    domain  = each.value.domain_name    
}

##########################################################
###    DEVICE
##########################################################
locals {

 data_device = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for device in try(domain.devices.devices, {}) : {
          name        = try(device.name, null)
          domain_name = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" ) #The device name is unique across the different domains.
    } 

}

data "fmc_device" "module" {
  for_each = local.data_device

    name   = each.value.name  
    domain = each.value.domain_name
}

##########################################################
###    DEVICE HA
##########################################################
locals {

 data_device_ha_pair = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for ha_pair in try(domain.devices.ha_pairs, {}) : {
          name        = try(ha_pair.name, null)
          domain_name = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" ) #The device name is unique across the different domains.
    } 

}

data "fmc_device_ha_pair" "module" {
  for_each = local.data_device_ha_pair

    name   = each.value.name  
    domain = each.value.domain_name
}


##########################################################
###    Physical Interface
##########################################################

locals {

  data_physical_interface = {
    for item in flatten([
      for domain in local.data_existing.fmc.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : [ 
            for physical_interface in try(vrf.physical_interfaces, []) : [ 
                {
                  name        = physical_interface.name
                  device_name = device.name
                  device_id   = data.fmc_device.module[device.name].id
                  domain_name = domain.name
                } ]
          ]
        ]
      ]
    ]) : "${item.device_name}:${item.name}" => item if contains(keys(item), "name") #The device name is unique across the different domains.
  }

}

data "fmc_device_physical_interface" "module" {
  for_each = local.data_physical_interface

    name        = each.value.name
    device_id   = each.value.device_id
    domain      = each.value.domain_name

    depends_on = [ 
      data.fmc_device.module
    ]
}

##########################################################
###    Ether Channel Interface
##########################################################

locals {

  data_etherchannel_interface = {
    for item in flatten([
      for domain in local.data_existing.fmc.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : [ 
            for etherchannel_interface in try(vrf.etherchannel_interfaces, []) : [ 
                {
                  name        = etherchannel_interface.name
                  device_name = device.name
                  device_id   = data.fmc_device.module[device.name].id
                  domain_name = domain.name
                } ]
          ]
        ]
      ]
    ]) : "${item.device_name}:${item.name}" => item if contains(keys(item), "name") #The device name is unique across the different domains.
  }

}

data "fmc_device_etherchannel_interface" "module" {
  for_each = local.data_etherchannel_interface

    name          = each.value.name
    device_id     = each.value.device_id
    domain        = each.value.domain_name

    depends_on = [ 
      data.fmc_device.module
    ]
}

##########################################################
###    Sub-Interface
##########################################################

locals {
  data_sub_interface = { for item in flatten([
      for domain in local.data_existing.fmc.domains : [
        for device in try(domain.devices.devices, []) : [
          for vrf in try(device.vrfs, []) : [ 
            for sub_interface in try(vrf.sub_interfaces, []) : [ 
                {
                  name        = sub_interface.name
                  device_name = device.name
                  device_id   = data.fmc_device.module[device.name].id
                  domain_name = domain.name
                } ]
          ]
        ]
      ]
    ]) : "${item.device_name}:${item.name}" => item if contains(keys(item), "name") #The device name is unique across the different domains. We want to search by index=Sub-Interface_id
  }

}

data "fmc_device_subinterface" "module" {
  for_each = local.data_sub_interface

    name        = each.value.name
    device_id   = each.value.device_id
    domain      = each.value.domain_name

    depends_on = [ 
      data.fmc_device.module
    ]
}

##########################################################
###    VRF
##########################################################
locals {

  data_vrf = {
    for item in flatten([
      for domain in local.data_existing.fmc.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : [ 
              {
                name        = vrf.name
                device_name = device.name
                device_id   = data.fmc_device.module[device.name].id
                domain_name = domain.name
              } ]
        ]
      ]
      ]) : "${item.device_name}:${item.name}" => item if contains(keys(item), "name") #The device name is unique across the different domains.
  }

}

data "fmc_device_vrf" "module" {
  for_each = local.data_vrf

    name        = each.value.name
    device_id   = each.value.device_id
    domain      = each.value.domain_name

    depends_on = [ 
      data.fmc_device.module
    ]
}

##########################################################
###    BFD 
##########################################################

locals {

  data_bfd = {
    for item in flatten([
      for domain in local.data_existing.fmc.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for bfd in try(device.bfds, []) : [ 
              merge(bfd, 
                {
                  interface_logical_name  = bfd.interface_logical_name 
                  device_id               = data.fmc_device.module[device.name].id
                  domain_name             = domain.name
                })
            ]
        ]
      ]
      ]) : "${item.domain_name}:${item.interface_logical_name}" => item if contains(keys(item), "interface_logical_name") #The device name is unique across the different domains.
  }

}
data "fmc_device_bfd" "module" {
  for_each = local.data_bfd

    interface_logical_name  = each.value.interface_logical_name
    device_id               = each.value.device_id
    domain                  = each.value.domain_name

}


##########################################################
###    BGP - General Settings
##########################################################
locals {

  data_bgp_general_setting = {
    for item in flatten([
      for domain in local.data_existing.fmc.domains : [
        for device in try(domain.devices.devices, []) : [ 
            {
                as_number   = device.bgp_general_settings.as_number 
                device_name = device.name
                domain_name = domain.name
              }
        ] if contains(keys(device), "bgp_general_settings")
      ]
      ]) : "${item.device_name}:BGP" => item if contains(keys(item), "device_name") 
  }

}

data "fmc_device_bgp_general_settings" "module" {
  for_each = local.data_bgp_general_setting

    as_number       = each.value.as_number
    device_id       = data.fmc_device.module[each.value.device_name].id
    domain          = each.value.domain_name

    depends_on = [ 
      data.fmc_device.module
    ]
}

