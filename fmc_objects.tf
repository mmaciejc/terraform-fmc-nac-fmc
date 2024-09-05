###
# HOST
###
locals {
  res_hosts = flatten([
    for domains in local.domains : [
      for object in try(domains.objects.hosts, []) : object if !contains(local.data_hosts, object.name)
    ]
  ])
}

resource "fmc_host" "host" {
  for_each = { for host in local.res_hosts : host.name => host }

  # Mandatory
  name  = each.value.name
  ip = each.value.ip

  # Optional
  description = try(each.value.description, local.defaults.fmc.domains.objects.hosts.description, null)
}

###
# NETWORK
###
locals {
  res_networks = flatten([
    for domains in local.domains : [
      for object in try(domains.objects.networks, []) : object if !contains(local.data_networks, object.name)
    ]
  ])
}

resource "fmc_network" "network" {
  for_each = { for network in local.res_networks : network.name => network }

  # Mandatory
  name  = each.value.name
  prefix = each.value.prefix

  # Optional
  description = try(each.value.description, local.defaults.fmc.domains.objects.networks.description, null)
}

###
# NETWORK GROUPS
###

locals {

  hlp_networkobjects = concat(
    flatten([
      for objecthost1 in local.res_hosts : objecthost1.name
      ]),
    flatten([
      for objectnet1 in local.res_networks : objectnet1.name 
      ]),
    local.data_hosts,
    local.data_networks
    )
  

  res_network_groups = flatten([
    for domains in local.domains : [
      for object in try(domains.objects.network_groups, []) : {
        name            = object.name
        description     = try(object.description, null)
        objects         = [ for obj in try(object.objects, []) : {
          name = obj
          } if contains(local.hlp_networkobjects, obj) ] 
        literals        = [ for obj in try(object.objects, []) : {
          value = obj
          } if length(try(split(".", obj), null)) == 4 ]
        network_groups  = [ for obj in try(object.objects, []) : obj if !contains(local.hlp_networkobjects, obj) &&  length(try(split(".", obj), null)) == 1]
      }   
    ]
  ])
}

resource "fmc_network_groups" "network_group" {
  items = { for item in try(local.res_network_groups, {}) : item.name => {

      #description    = item.description
      objects = [ for obj in try(item.objects, {}) : {
        id = local.map_networkobjects[obj.name].id
      }]
      literals = try(item.literals, [])
      network_groups = try(item.network_groups, [])
    }
  }
}