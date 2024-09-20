##########################################################
###    Content of the file:
##########################################################
#
###
#  Resources
####
# resource "fmc_host" "host"
# resource "fmc_network" "network" 
# resource "fmc_network_groups" "network_group"
#
###  
#  Local variables
###
# local.resource_hosts              => for building dynamic resource
# local.resource_networks           => for building dynamic resource
# local.resource_network_groups     => for building dynamic resource
# local.map_network_objects         => to collect all network objects by name that can be used in Access Control Policy or IPv4 Static Route
# local.map_network_group_objects   => as per above - needs to be separate to avoid circular error 
#
###

##########################################################
###    Example of created local variables
##########################################################

#  + resource_hosts = {
#      + Global = {
#          + Host_1 = {
#              + ip   = "192.168.0.15"
#              + name = "Host_1"
#            }
#        }
#    }

# for_each loop
#  + for_each_loop  = {
#      + Host_1 = {
#          + domain_name  = "Global"
#          + ip           = "192.168.0.15"
#          + name         = "Host_1"
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
###    HOST
##########################################################
locals {

  resource_hosts = {
    for domain in local.domains : domain.name => { 
        for item in try(domain.objects.hosts, {}) : item.name =>  item if !contains(try(local.data_hosts[domain.name], []), item.name)
      } 
    }

}

resource "fmc_host" "host" {
  for_each = { 
    for item_key in flatten([
      for domain_key, domain_value in local.resource_hosts : [ 
        for item_value in domain_value : 
          merge(item_value, {"domain_name" = domain_key})
      ]
      ]) : item_key.name => item_key
  }

  # Mandatory
  name  = each.value.name
  ip    = each.value.ip

  # Optional
  domain = try(each.value.domain_name, null)
  description = try(each.value.description, local.defaults.fmc.domains.objects.hosts.description, null)
}

##########################################################
###    NETWORK
##########################################################
locals {

  resource_networks = {
    for domain in local.domains : domain.name => { 
        for item in try(domain.objects.networks, {}) : item.name =>  item if !contains(try(local.data_networks[domain.name], []), item.name)
      } 
    }

}

resource "fmc_network" "network" {
  for_each = { 
    for item_key in flatten([
      for domain_key, domain_value in local.resource_networks : [ 
        for item_value in domain_value : 
          merge(item_value, { "domain_name" = domain_key })
      ]
      ]) : item_key.name => item_key
  }

  # Mandatory
  name  = each.value.name
  prefix = each.value.prefix

  # Optional
  domain = try(each.value.domain_name, null)
  description = try(each.value.description, local.defaults.fmc.domains.objects.networks.description, null)
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
      for item in try(domain.objects.network_groups, {}) : item.name => {
        name            = item.name
        domain_name     = domain.name
        description     = try(item.description, null)
        objects         = [ for object_item in try(item.objects, []) : {
          name = object_item
          } if contains(local.help_network_objects, object_item) ] 
        literals        = [ for literal_item in try(item.literals, []) : {
          value = literal_item
          }] 
        network_groups  = [ for object_item in try(item.objects, []) : object_item if !contains(local.help_network_objects, object_item) ]
      }   
    }
  }

}

resource "fmc_network_groups" "network_group" {
  for_each = { for item_key, item_value in local.resource_network_groups : item_key => item_value }

  # Optional  
  items =   { for item in each.value : item.name => {
  
      description    = item.description
      objects = [ for object_item in try(item.objects, {}) : {
        id = local.map_network_objects[object_item.name].id
      }]
      literals = try(item.literals, [])
      network_groups = try(item.network_groups, [])
    }
  }

  domain = try(each.value.domain_name, null)
  depends_on = [ 
    data.fmc_host.host,
    fmc_host.host,
    data.fmc_network.network,
    fmc_network.network
   ]
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
        flatten([ for key, value in domain_value : { 
          name = value.name
          id   = fmc_host.host[value.name].id
          type = fmc_host.host[value.name].type
          domain_name = domain_key
        }])
      ]) : item.name => item
    },
    {
      for item in flatten([
        for domain_key, domain_value in local.data_hosts : 
          flatten([ for value in domain_value: {
          name        = value
          id          = data.fmc_host.host[value].id
          type        = data.fmc_host.host[value].type
          domain_name = domain_key
        }])
      ]) : item.name => item
    },
    {
      for item in flatten([
        for domain_key, domain_value in local.resource_networks : 
          flatten([ for key, value in domain_value : { 
            name = value.name
            id   = fmc_network.network[value.name].id
            type = fmc_network.network[value.name].type
            domain_name = domain_key
          }])
        ]) : item.name => item
    },    
    {
      for item in flatten([
        for domain_key, domain_value in local.data_networks : 
          flatten([ for value in domain_value: {
          name        = value
          id          = data.fmc_network.network[value].id
          type        = data.fmc_network.network[value].type
          domain_name = domain_key
        }])
      ]) : item.name => item
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
          flatten([ for item_key, item_value in domain_value : { 
            name = item_value.name
            id   = try(fmc_network_groups.network_group[domain_key].items[item_value.name].id, null)
            type = "NetworkGroup"
            domain_name = domain_key
          }])
        ]) : item.name => item
    },       
  )
}