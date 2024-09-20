#############################################################
# Define terraform data representation of objects that already exist on FMC
##########################################################
###    Content of the file:
##########################################################
#
###
#  Data sources
####
# data "fmc_host" "host"
# data "fmc_network" "network"
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
# local.map_interfaces              => to collect all interface objects by name that can be used later in the module
#
###
##########################################################
###    Example of created local variables
##########################################################

#  + data_host               = {
#      + Test = {
#          + domain_name = "Global"
#          + name        = "Test"
#        }
#    }

 # + data_hosts              = {
 #     + Global = {
 #         + items = [
 #             + "Test",
 #           ]
 #       }
 #   }

##########################################################
###    HOST
##########################################################
locals {

 data_host = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for item_value in try(domain.objects.hosts, {}) : {
          "name"        = item_value.name
          "domain_name" = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "domain_name" )
    } 

  data_hosts = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = flatten([ 
        for item_value in try(domain.objects.hosts, []) : item_value.name 
        ]  ) 
    } 
  }

}

data "fmc_host" "host" {
  for_each = local.data_host
  
  name    = each.key
  domain  = each.value.domain_name
}

##########################################################
###    NETWORK
##########################################################
locals {

 data_network = { 
    for item in flatten([
      for domain in try(local.data_existing.fmc.domains, {}) : [ 
        for item_value in try(domain.objects.networks, {}) : {
          "name"        = item_value.name
          "domain_name" = domain.name
        }
      ]
      ]) : item.name => item if contains(keys(item), "name" )
    } 

  data_networks = { 
    for domain in local.data_existing.fmc.domains : domain.name => { 
      "items" = flatten([ 
        for item_value in try(domain.objects.networks, []) : item_value.name 
        ]  ) 
    } 
  }

}

data "fmc_network" "network" {
  for_each = local.data_network
  
  name    = each.key
  domain  = each.value.domain_name
}

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

  name  = each.value.name
  domain = each.value.domain_name    
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
  data_accesspolicies = []
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