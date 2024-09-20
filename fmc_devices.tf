##########################################################
###    Content of the file:
##########################################################
#
###
#  Resources
####
# resource "fmc_device_ipv4_static_route" "ipv4_static_route"
#
###  
#  Local variables
###
# local.help_device_vrfs            => map with the list of all vrfs per device/domain
# local.resource_ipv4staticroute    => for building dynamic resource - single resource
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



###
# DEVICE - to be modified
###

locals {
  res_devices = []
}

resource "fmc_device" "device" {
  for_each = { for device in local.res_devices : device.name => device }
  name                 = "device1"
  host_name            = "10.0.0.1"
  license_capabilities = ["BASE"]
  registration_key     = "key1"
  access_policy_id     = "76d24097-41c4-4558-a4d0-a8c07ac08470"
  performance_tier     = "FTDv50"
}

##########################################################
###    IPv4 STATIC ROUTES
##########################################################
locals {

  help_device_vrfs = {
    for domain in local.domains : domain.name => {
      for device, device in try(domain.devices.devices, []) : device.name => distinct([
        for ipv4staticroute in try(device.ipv4_static_routes, []) : try(ipv4staticroute.vrf, "Global") 
      ])
    }
  }

  resource_ipv4_static_route = {
    for item in flatten([
    for domain in local.domains : [
      for device in try(domain.devices.devices, []) : [
        for vrf in local.help_device_vrfs[domain.name][device.name] : flatten([
          for ipv4staticroute in try(device.ipv4_static_routes, []) :  merge(ipv4staticroute, 
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
### map_devices - to be modified
######
locals {

  map_devices = merge({
    for device in local.res_devices :
    device.name => {
      id   = fmc_device.device[device.name].id
      type = fmc_device.device[device.name].type
    }
    },
    {
      for device in local.data_devices :
      device.name => {
        id   = data.fmc_device.device[device.name].id
        type = data.fmc_device.device[device.name].type
      }
    }
  )

######
### map_devices - to be modified
######

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