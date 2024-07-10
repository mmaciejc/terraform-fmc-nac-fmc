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
  name = each.value.name
  ip   = each.value.ip

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
  name   = each.value.name
  prefix = each.value.prefix

  # Optional
  description = try(each.value.description, local.defaults.fmc.domains.objects.networks.description, null)
}

