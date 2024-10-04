##########################################################
###    Content of the file:
##########################################################
#
###
#  Resources
####
# resource "fmc_host" "host"
# resource "fmc_network" "network" 
# resource "fmc_network_groups" "network_groups"
#
###  
#  Local variables
###
# local.resource_host               => for building dynamic resource - for single resource
# local.resource_hosts              => for building dynamic resource - for bulk resource
# local.resource_network            => for building dynamic resource - for single resource
# local.resource_networks           => for building dynamic resource - for bulk resource
# local.resource_network_groups     => for building dynamic resource - for bulk resource
# local.map_network_objects         => to collect all network objects by name that can be used in Access Control Policy or IPv4 Static Route
# local.map_network_group_objects   => as per above - needs to be separate to avoid circular error 
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
###    HOST
##########################################################
locals {

  resource_host = { 
    for item in flatten([
      for domain in local.domains : [ 
        for item_value in try(domain.objects.hosts, []) : [ 
          merge(item_value, 
            {
              "domain_name" = domain.name
            })
        ]
      ]
      ]) : item.name => item if contains(keys(item), "name" ) && !contains(try(keys(local.data_host), []), item.name)
  }

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
#      ip    = item_value.ip 
      value    = item_value.ip 
      # Optional
      description = try(item_value.description, local.defaults.fmc.domains.objects.hosts.description, null)
    }
  }
  # Optional
  domain = try(each.key, null)
}

##########################################################
###    NETWORK
##########################################################
locals {

  resource_network = { 
    for item in flatten([
      for domain in local.domains : [ 
        for item_value in try(domain.objects.networks, []) : [ 
          merge(item_value, 
            {
              "domain_name" = domain.name
            })
        ]
      ]
      ]) : item.name => item if contains(keys(item), "name" ) && !contains(try(keys(local.data_network), []), item.name)
  }

  resource_networks = { 
    for domain in local.domains : domain.name => { 
      "items" = {
        for item in try(domain.objects.networks, []) : item.name => item if !contains(try(local.data_networks[domain.name].itmes, []), item.name)
      }
    } if length(try(domain.objects.networks, [])) > 0
  } 

}

####################
# Superseded by bulk
####################
resource "fmc_network" "network" {
  for_each = local.resource_network

  # Mandatory
  name  = each.key
  prefix = each.value.prefix

  # Optional
  domain = try(each.value.domain_name, null)
  description = try(each.value.description, local.defaults.fmc.domains.objects.networks.description, null)
}

#resource "fmc_networks" "networks" {
#  for_each =  local.resource_networks
#
#  items =   { for item_key, item_value in each.value.items : item_key => {
#      # Mandatory
#      ip    = item_value.ip 
#      # Optional
#      description = try(item_value.description, local.defaults.fmc.domains.objects.hosts.description, null)
#    }
#  }
#  # Optional
#  domain = try(each.key, null)
#}


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
            name = object_item
            } if contains(local.help_network_objects, object_item) ] 
          literals        = [ for literal_item in try(item.literals, []) : {
            value = literal_item
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
      objects = [ for object_item in try(item_value.objects, {}) : {
        id = local.map_network_objects[object_item.name].id
      }]
      literals = try(item_value.literals, [])
      network_groups = try(item_value.network_groups, [])
      # Optional
      description    = item_value.description
    }
  }

  domain = try(each.value.domain_name, null)
  depends_on = [ 
    data.fmc_host.host,
    fmc_hosts.hosts,
    data.fmc_network.network,
#    fmc_networks.networks,
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
        flatten([ for item_key, item_value in domain_value.items : { 
          name = item_key
          id   = try(fmc_hosts.hosts[domain_key].items[item_key].id, null)
          type = try(fmc_hosts.hosts[domain_key].items[item_key].type, null)
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },   
    {
      for item in flatten([
        for domain_key, domain_value in local.data_hosts : 
          flatten([ for item in keys(domain_value.items): {
          name        = item
          id          = data.fmc_host.host[item].id
          type        = data.fmc_host.host[item].type
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },
    {
    for item in flatten([
      for domain_key, domain_value in local.resource_networks : 
        flatten([ for item_key, item_value in domain_value.items : { 
          name = item_key
          id   = try(fmc_network.network[item_key].id, null)
          type = try(fmc_network.network[item_key].type, null)
#          id   = try(fmc_networks.networks[domain_key].items[item_key].id, null)
#          type = try(fmc_networks.networks[domain_key].items[item_key].type, null)
          domain_name = domain_key
        }])
      ]) : item.name => item if contains(keys(item), "name" )
    },     
    {
      for item in flatten([
        for domain_key, domain_value in local.data_networks : 
          flatten([ for item in keys(domain_value.items): {
          name        = item
          id          = data.fmc_network.network[item].id
          type        = data.fmc_network.network[item].type
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
            name = item_key
            id   = try(fmc_network_groups.network_groups[domain_key].items[item_key].id, null)
            type = "NetworkGroup"
            domain_name = domain_key
          }])
        ]) : item.name => item if contains(keys(item), "name" )
    },       
  )

}