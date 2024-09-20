##########################################################
###    Content of the file:
##########################################################
#
###
#  Resources
####
# resource "fmc_device" "device" 
# resource "fmc_device_ipv4_static_route" "ipv4_static_route"
#
###  
#  Local variables
###
# local.resource_device             => for building dynamic resource - single resource
# local.resource_ipv4staticroute    => for building dynamic resource - single resource
# local.help_device_vrfs            => map with the list of all vrfs per device/domain
# local.map_devices                 => to collect all devices objects by name that can be used later in the module
#
###

##########################################################
###    Example of created local variables
##########################################################

#  + help_device_vrfs           = {
#      + Global = {
#          + MyDeviceName1 = [
#              + "Global",
#            ]
#        }
#    }

#  + resource_ipv4_static_route = {
#      + "Global/MyDeviceName1/Global/ipv4StaticRoute_0001"      = {
#          + device_name       = "MyDeviceName1"
#          + domain_name       = "Global"
#          + gateway           = {
#              + literal = "192.168.44.1"
#            }
#          + interface         = "outside"
#          + metric            = 1
#          + name              = "ipv4StaticRoute_0001"
#          + selected_networks = [
#              + "AZURE-VPN",
#            ]
#          + vrf               = "Global"
#        }
#    }
##########################################################
###    DEVICE
##########################################################

locals {
  res_devices = []

  resource_device = {
    for item in flatten([
      for domain in local.domains : [
        for item_value in try(domain.devices.devices, []) : [ 
          {
            "name"                      = try(item_value.name, null)
            "host_name"                 = try(item_value.host_name, null)
            "registration_key"          = try(item_value.registration_key, null)
            "access_policy"             = try(item_value.access_policy, null)
            "license_capabilities"      = try(item_value.licenses, [])
            "nat_id"                    = try(item_value.nat_id, null)
            "performance_tier"          = try(item_value.performance_tier, null)
            "prohibit_packet_transfer"  = try(item_value.prohibit_packet_transfer, null)
            "domain_name"               = domain.name            
          }
        ]
      ]
      ]) : item.name => item if contains(keys(item), "name") && !contains(try(keys(local.data_device), []), item.name)
  }
        
}
resource "fmc_device" "device" {
  for_each = local.resource_device

  #Required
    name                      = each.key
    host_name                 = each.value.host_name
    registration_key          = each.value.registration_key
    access_policy_id          = local.map_access_control_policy[each.value.access_policy].id
    license_capabilities      = each.value.license_capabilities

  #Optional
    nat_id                    = each.value.nat_id
    performance_tier          = each.value.performance_tier
    prohibit_packet_transfer  = each.value.prohibit_packet_transfer
    domain                    = each.value.domain_name     

  depends_on = [ 
    data.fmc_access_control_policy.access_control_policy,
    fmc_access_control_policy.access_control_policy,
   ]

}

##########################################################
###    IPv4 STATIC ROUTES
##########################################################
locals {

  help_device_vrfs = {
    for domain in local.domains : domain.name => {
      for device in try(domain.devices.devices, []) : device.name => distinct([
        for ipv4staticroute in try(device.ipv4_static_routes, []) : try(ipv4staticroute.vrf, "Global") 
      ])
    }
  }

  resource_ipv4_static_route = {
    for item in flatten([
    for domain in local.domains : [
      for device in try(domain.devices.devices, []) : [
        for vrf in local.help_device_vrfs[domain.name][device.name] : flatten([
          for ipv4staticroute in try(device.ipv4_static_routes, []) : merge(ipv4staticroute, 
          {
                  "domain_name" = domain.name
                  "device_name" = device.name
                  "vrf"    = try(ipv4staticroute.vrf, "Global")
          }) if vrf == try(ipv4staticroute.vrf, "Global")
        ]) 
        ]
      ]
    ]) : "${item.domain_name}/${item.device_name}/${item.vrf}/${item.name}" => item if contains(keys(item), "name" )
  }

}
resource "fmc_device_ipv4_static_route" "ipv4_static_route" {
  for_each = local.resource_ipv4_static_route

    device_id              = local.map_devices[each.value.device_name].id 
    interface_logical_name = each.value.interface
    interface_id           = local.map_ifnames["${each.value.device_name}/${each.value.interface}"].id
    destination_networks = [ for net in each.value.selected_networks : {
        id = try(local.map_network_objects[net].id, local.map_network_group_objects[net].id)
      }
    ]
    metric_value      = each.value.metric
    gateway_literal   = try(each.value.gateway.literal, null)
    gateway_object_id = try(local.map_network_objects[each.value.gateway.object].id, null)
   
  # Optional
    #domain = try(each.value.domain_name, null)
    #vrf_id = try(each.value.vrf, null)


  depends_on = [ 
    data.fmc_host.host,
    fmc_host.host,
    data.fmc_network.network,
    fmc_network.network,
    fmc_network_groups.network_groups,
    data.fmc_device.device,
    fmc_device.device,
    data.fmc_device_physical_interface.physical_interface,
   ]

}

##########################################################
###    Create maps for combined set of _data and _resources network objects 
##########################################################

######
### map_devices
######
locals {
  map_devices = merge({
      for item in flatten([
        for item_key, item_value in local.resource_device :  { 
            name = item_key
            id   = try(fmc_device.device[item_key].id, null)
            type = try(fmc_device.device[item_key].type, null)
            domain_name = item_value.domain_name
          }
        ]) : item.name => item if contains(keys(item), "name" )
    }, 
    {
      for item in flatten([
        for item_key, item_value in local.data_device : { 
            name = item_key
            id   = try(data.fmc_device.device[item_key].id, null)
            type = try(data.fmc_device.device[item_key].type, null)
            domain_name = item_value.domain_name
          }
        ]) : item.name => item if contains(keys(item), "name" )
    }, 
  )

}


############################################################################################
# OLD code!
######
### map_ifnames - to be modified
######
locals {
  map_ifnames = merge(concat(
    #flatten([
    #  for domain in local.domains : [
    #    for device in try(domain.devices.devices, []) : {
    #      for physicalinterface in try(device.physical_interfaces, []) : "${device.name}/${physicalinterface.name}" => {
    #        device_id         = local.map_devices[device.name].id
    #        device_name       = device.name
    #        id                = fmc_device_physical_interface.physical_interface["${device.name}/${physicalinterface.interface}"].id
    #      }
    #    }
    #  ]
    #]),
    flatten([
      for device in try(local.data_existing.fmc.domains[0].devices.devices, []) : {
        for physicalinterface in try(device.physical_interfaces, []) : "${device.name}/${physicalinterface.name}" => {
          device_id         = local.map_devices[device.name].id
          device_name       = device.name
          interface         = physicalinterface.interface
          id                = data.fmc_device_physical_interface.physical_interface["${device.name}/${physicalinterface.interface}"].id
        }
      }
    ])
    )...
  )


}