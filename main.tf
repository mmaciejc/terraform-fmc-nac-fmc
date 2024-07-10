locals {
  fmc           = try(local.model.fmc, {})
  domains       = try(local.fmc.domains, {})
  data_existing = try(local.model.existing, {})

  #
  # Create maps for combined set of _data and _resources objects
  #
  map_networkobjects = merge({
    for objecthost1 in local.res_hosts :
    objecthost1.name => {
      id   = fmc_host.host[objecthost1.name].id
      type = fmc_host.host[objecthost1.name].type
    }
    },
    #{
    #  for objecthost2 in local.data_hosts :
    #  objecthost2 => {
    #    id   = data.fmc_host_objects.host[objecthost2].id
    #    type = data.fmc_host_objects.host[objecthost2].type
    #  }
    #},
    {
      for objectnet1 in local.res_networks :
      objectnet1.name => {
        id   = fmc_network.network[objectnet1.name].id
        type = fmc_network.network[objectnet1.name].type
      }
    },
    #{
    #  for objectnet2 in local.data_networks :
    #  objectnet2 => {
    #    id   = data.fmc_network_objects.network[objectnet2].id
    #    type = data.fmc_network_objects.network[objectnet2].type
    #  }
    #},
  )
}