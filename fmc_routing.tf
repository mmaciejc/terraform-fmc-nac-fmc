##########################################################
###    Content of the file:
##########################################################
#
###
#  Resources
####
# resource "fmc_device_vrf" "module" {
# resource "fmc_device_ipv4_static_route" "module" {
# resource "fmc_device_vrf_ipv4_static_route" "module" {
# resource "fmc_device_bgp_general_settings" "module" {
# resource "fmc_device_bgp" "module" {
#
###  
#  Local variables
###
#  local.resource_vrf 
#  local.resource_ipv4_static_route 
#  local.resource_vrf_ipv4_static_route 
#  local.resource_bgp_global 
#
###




##########################################################
###    VRF
##########################################################
locals {

  resource_vrf = {
    for item in flatten([
      for domain in local.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : [ 
            {
              "device_name" = device.name
              "name"        = vrf.name
              "device_id"   = local.map_devices[device.name].id
              "domain_name" = domain.name              
              "description" = try(vrf.description, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].description, null)
              "interfaces"  = concat([ for interface in try(vrf.physical_interfaces, []) : {
                    "interface_id"            = try(fmc_device_physical_interface.module["${device.name}:${interface.name}"].id, data.fmc_device_physical_interface.module["${device.name}:${interface.name}"].id, null)
                    "interface_logical_name"  = try(interface.logical_name, data.fmc_device_physical_interface.module["${device.name}:${interface.name}"].logical_name, null)
                    "interface_name"          = interface.name
              }],
              [
                for interface in try(vrf.etherchannel_interfaces, []) : {
                    "interface_id"            = try(fmc_device_etherchannel_interface.module["${device.name}:${interface.name}"].id, data.fmc_device_etherchannel_interface.module["${device.name}:${interface.name}"].id, null)
                    "interface_logical_name"  = try(interface.logical_name, data.fmc_device_etherchannel_interface.module["${device.name}:${interface.name}"].logical_name, null)
                    "interface_name"          = interface.name
              }],
              [
                for interface in try(vrf.sub_interfaces, []) : {
                    "interface_id"            = try(fmc_device_subinterface.module["${device.name}:${interface.name}"].id, data.fmc_device_subinterface.module["${device.name}:${interface.name}"].id, null)
                    "interface_logical_name"  = try(interface.logical_name, data.fmc_device_subinterface.module["${device.name}:${interface.name}"].logical_name, null)
                    "interface_name"          = interface.name
              }],              
              ) # Checking all interfaces under this VRF and assigning reuired attributes
            }
          ]
        ]
      ]
      ]) : "${item.device_name}:${item.name}" => item if contains(keys(item), "name") && !contains(try(keys(local.data_vrf), []), "${item.device_name}:${item.name}") #The device name is unique across the different domains.
  }

}

resource "fmc_device_vrf" "module" {
  for_each = local.resource_vrf

  # Mandatory  
    device_id   = each.value.device_id
    name        = each.value.name

  # Optional
    description = each.value.description
    interfaces  = each.value.interfaces

  depends_on = [ 
    fmc_device.module,
    data.fmc_device.module,
    fmc_device_physical_interface.module,
    data.fmc_device_physical_interface.module,
    fmc_device_etherchannel_interface.module,
    data.fmc_device_etherchannel_interface.module,
    fmc_device_subinterface.module,
    data.fmc_device_subinterface.module
   ]

}

##########################################################
###    IPv4 STATIC ROUTES
##########################################################
locals {

  resource_ipv4_static_route = {
    for item in flatten([
    for domain in local.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : [ 
            for ipv4_static_route in try(vrf.ipv4_static_routes, []) : 
              {
                "device_name"             = device.name
                "device_id"               = local.map_devices[device.name].id
                "domain_name"             = domain.name
                "name"                    = ipv4_static_route.name
                "interface_logical_name"  = ipv4_static_route.interface_logical_name
                "interface_id"            = local.map_interface_logical_names["${device.name}:${ipv4_static_route.interface_logical_name}"].id
                "destination_networks"    = [ for destination_network in ipv4_static_route.selected_networks : {
                    "id"    = try(local.map_network_objects[destination_network].id, local.map_network_group_objects[destination_network].id)
                } ]
                "metric_value"            = ipv4_static_route.metric
                "gateway_literal"         = try(ipv4_static_route.gateway.literal, null)
                "gateway_object_id"       = try(local.map_network_objects[ipv4_static_route.gateway.object].id, local.map_network_group_objects[ipv4_static_route.gateway.object].id, null)
              } if vrf.name == "Global"
          ]
        ]
      ]
    ]) : "${item.device_name}:Global:${item.name}" => item if contains(keys(item), "name" )
  }

  resource_vrf_ipv4_static_route = {
    for item in flatten([
    for domain in local.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : [ 
            for ipv4_static_route in try(vrf.ipv4_static_routes, []) : 
              {
                "device_name"             = device.name
                "device_id"               = local.map_devices[device.name].id
                "vrf_id"                  = local.map_vrfs["${device.name}:${vrf.name}"].id
                "vrf_name"                = vrf.name
                "domain_name"             = domain.name
                "name"                    = ipv4_static_route.name
                "interface_logical_name"  = ipv4_static_route.interface_logical_name
                "interface_id"            = local.map_interface_logical_names["${device.name}:${ipv4_static_route.interface_logical_name}"].id
                "destination_networks"    = [ for destination_network in ipv4_static_route.selected_networks : {
                    "id"    = try(local.map_network_objects[destination_network].id, local.map_network_group_objects[destination_network].id)
                } ]
                "metric_value"            = ipv4_static_route.metric
                "gateway_literal"         = try(ipv4_static_route.gateway.literal, null)
                "gateway_object_id"       = try(local.map_network_objects[ipv4_static_route.gateway.object].id, local.map_network_group_objects[ipv4_static_route.gateway.object].id, null)
              } if vrf.name != "Global"
          ]
        ]
      ]
    ]) : "${item.device_name}:${item.vrf_name}:${item.name}" => item if contains(keys(item), "name" )
  }

}

resource "fmc_device_ipv4_static_route" "module" {
  for_each = local.resource_ipv4_static_route

  # Mandatory
    device_id               = each.value.device_id
    interface_logical_name  = each.value.interface_logical_name
    interface_id            = each.value.interface_id
    destination_networks    = each.value.destination_networks
    metric_value            = each.value.metric_value
    gateway_literal         = each.value.gateway_literal
    gateway_object_id       = each.value.gateway_object_id
   
  # Optional
    domain    = each.value.domain_name

  depends_on = [ 
    data.fmc_hosts.hosts,
    fmc_hosts.hosts,
    data.fmc_networks.networks,
    fmc_networks.networks,
    fmc_network_groups.network_groups,
    data.fmc_device.module,
    fmc_device.module,
    data.fmc_device_physical_interface.module,
   ]
}

resource "fmc_device_vrf_ipv4_static_route" "module" {
  for_each = local.resource_vrf_ipv4_static_route

  # Mandatory
    vrf_id                  = each.value.vrf_id
    device_id               = each.value.device_id
    interface_logical_name  = each.value.interface_logical_name
    interface_id            = each.value.interface_id
    destination_networks    = each.value.destination_networks
    metric_value            = each.value.metric_value
    gateway_literal         = each.value.gateway_literal
    gateway_object_id       = each.value.gateway_object_id
   
  # Optional
    domain    = each.value.domain_name

  depends_on = [ 
    data.fmc_hosts.hosts,
    fmc_hosts.hosts,
    data.fmc_networks.networks,
    fmc_networks.networks,
    fmc_network_groups.network_groups,
    data.fmc_device.module,
    fmc_device.module,
    data.fmc_device_physical_interface.module,
    fmc_device_vrf.module,
    data.fmc_device_vrf.module
   ]
}

##########################################################
###    BGP - General Settings
##########################################################
locals {

  bgp_general_setting = {
    for item in flatten([
        for domain in local.domains : [
            for device in try(domain.devices.devices, []) : {
                "device_name"   = device.name
                "device_id"     = local.map_devices[device.name].id
                #"name"          = bgp_general_settings.name
                "as_number"     = device.bgp_general_settings.as_number
                "router_id"     = try(device.bgp_general_settings.router_id, null)
                "domain_name"   = domain.name
            } if contains(keys(device), "bgp_general_settings")
        ]
    ]) : "${item.device_name}:BGP" => item if contains(keys(item), "device_name") && !contains(try(keys(local.data_bgp_general_setting), []), "${item.device_name}:BGP")
  }

}

resource "fmc_device_bgp_general_settings" "module" {
  for_each = local.bgp_general_setting    

  device_id     = each.value.device_id
  as_number     = each.value.as_number
  router_id     = each.value.router_id

    depends_on = [ 
        data.fmc_device.module,
        fmc_device.module,
    ]
}

##########################################################
###    BGP - Global
##########################################################
locals {

  resource_bgp_global = {
    for item in flatten([
    for domain in local.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : 
              {
              # Madatory
                "device_name"                       = device.name
                "device_id"                         = local.map_devices[device.name].id
              # Optional
                "ipv4_aggregate_addresses"  = [ for ipv4_aggregate_address in try(vrf.bgp.ipv4_aggregate_addresses, {}) : {
                    advertise_map_id  = null
                    attribute_map_id  = null
                    filter            = try(ipv4_aggregate_address.filter, null)
                    generate_as       = try(ipv4_aggregate_address.generate_as, null)
                    network_id        = try(local.map_network_objects[ipv4_aggregate_address.network].id, local.map_network_group_objects[ipv4_aggregate_address.network].id, null)
                    suppress_map_id   = null
                } ]
                "ipv4_auto_aummary"                 = try(vrf.bgp.ipv4_auto_aummary, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_auto_aummary, null)
                "ipv4_bgp_redistribute_internal"    = try(vrf.bgp.ipv4_bgp_redistribute_internal, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_bgp_redistribute_internal, null)
                "ipv4_bgp_supress_inactive"         = try(vrf.bgp.ipv4_bgp_supress_inactive, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_bgp_supress_inactive, null)
                "ipv4_default_information_orginate" = try(vrf.bgp.ipv4_default_information_orginate, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_default_information_orginate, null)
                "ipv4_external_distance"            = try(vrf.bgp.ipv4_external_distance, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_external_distance, null)
                "ipv4_filterings"           = [ for ipv4_filter in try(vrf.bgp.ipv4_filterings, {}) : {
                    "access_list_id"    = null
                    "network_direction" = try(ipv4_filter.network_direction, null)
                    "prorocol_process"  = try(ipv4_filter.prorocol_process, null)
                    "protocol"          = try(ipv4_filter.protocol, null)
                } ]
                "ipv4_forward_packets_over_multipath_ebgp"  = try(vrf.bgp.ipv4_forward_packets_over_multipath_ebgp, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_forward_packets_over_multipath_ebgp, null)
                "ipv4_forward_packets_over_multipath_ibgp"  = try(vrf.bgp.ipv4_forward_packets_over_multipath_ibgp, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_forward_packets_over_multipath_ibgp, null)
                "ipv4_internal_distance"                    = try(vrf.bgp.ipv4_internal_distance, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_internal_distance, null)
                "ipv4_learned_route_map_id"                 = null
                "ipv4_local_distance"                       = try(vrf.bgp.ipv4_local_distance, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_local_distance, null)
                "ipv4_neighbors"          = [ for ipv4_neighbor in try(vrf.bgp.ipv4_neighbors, {}) : {
                    "enable_address_family"                         = try(ipv4_neighbor.enable_address_family, null)
                    "neighbor_address"                              = try(ipv4_neighbor.neighbor_address, null)
                    "neighbor_authentication_password"              = try(ipv4_neighbor.neighbor_authentication_password, null)
                    "neighbor_bfd"                                  = try(ipv4_neighbor.neighbor_bfd, null)
                    "neighbor_customized_accept_both_as"            = try(ipv4_neighbor.neighbor_customized_accept_both_as, null)
                    "neighbor_customized_local_as_number"           = try(ipv4_neighbor.neighbor_customized_local_as_number, null)
                    "neighbor_customized_no_prepend"                = try(ipv4_neighbor.neighbor_customized_no_prepend, null)
                    "neighbor_customized_replace_as"                = try(ipv4_neighbor.neighbor_customized_replace_as, null)
                    "neighbor_description"                          = try(ipv4_neighbor.neighbor_description, null)
                    "neighbor_disable_connection_verification"      = try(ipv4_neighbor.neighbor_disable_connection_verification, null)
                    "neighbor_filter_access_lists"        = [ for neighbor_filter_access_list in try(vrf.bgp.neighbor_filter_access_lists, {}) : {
                          "access_list_id"    = null
                          "update_direction"  = try(neighbor_filter_access_list.update_direction, null)
                    } ]
                    "neighbor_filter_as_path_lists"       = [ for neighbor_filter_as_path_list in try(vrf.bgp.neighbor_filter_as_path_lists, {}) : {
                          "as_path_id"        = null
                          "update_direction"  = try(neighbor_filter_as_path_list.update_direction, null)
                    } ]
                    "neighbor_filter_max_prefix"                    = try(ipv4_neighbor.neighbor_filter_max_prefix, null)
                    "neighbor_filter_prefix_lists"        = [ for neighbor_filter_prefix_list in try(vrf.bgp.neighbor_filter_prefix_lists, {}) : {
                          "prefix_list_id"    = null
                          "update_direction"  = try(neighbor_filter_prefix_list.update_direction, null)
                    } ]
                    "neighbor_filter_restart_interval"              = try(ipv4_neighbor.neighbor_filter_restart_interval, null)
                    "neighbor_filter_route_map_lists"   = [ for neighbor_filter_route_map_list in try(vrf.bgp.neighbor_filter_route_map_lists, {}) : {
                          "route_map_id"      = null
                          "update_direction"  = try(neighbor_filter_route_map_list.update_direction, null)
                    } ]
                    "neighbor_filter_threshold_value"               = try(ipv4_neighbor.neighbor_filter_threshold_value, null)
                    "neighbor_generate_default_route_map"         = null
                    "neighbor_hold_time"                            = try(ipv4_neighbor.neighbor_hold_time, null)
                    "neighbor_keepalive_interval"                   = try(ipv4_neighbor.neighbor_keepalive_interval, null)
                    "neighbor_max_hop_count"                        = try(ipv4_neighbor.neighbor_max_hop_count, null)
                    "neighbor_min_hold_time"                        = try(ipv4_neighbor.neighbor_min_hold_time, null)
                    "neighbor_nexthop_self"                         = try(ipv4_neighbor.neighbor_nexthop_self, null)
                    "neighbor_remote_as"                            = try(ipv4_neighbor.neighbor_remote_as, null)
                    "neighbor_routes_advertise_exist_nonexist_map" = null
                    "neighbor_routes_advertise_map"                = null
                    "neighbor_routes_advertise_map_use_exist"       = try(ipv4_neighbor.neighbor_routes_advertise_map_use_exist, null)
                    "neighbor_routes_advertisement_interval"        = try(ipv4_neighbor.neighbor_routes_advertisement_interval, null)
                    "neighbor_routes_remove_private_as"             = try(ipv4_neighbor.neighbor_routes_remove_private_as, null)
                    "neighbor_send_community_attribute"             = try(ipv4_neighbor.neighbor_send_community_attribute, null)
                    "neighbor_shutdown"                             = try(ipv4_neighbor.neighbor_shutdown, null)
                    "neighbor_tcp_mtu_path_discovery"               = try(ipv4_neighbor.neighbor_tcp_mtu_path_discovery, null)
                    "neighbor_tcp_transport_mode"                   = try(ipv4_neighbor.neighbor_tcp_transport_mode, null)
                    "neighbor_version"                              = try(ipv4_neighbor.neighbor_version, null)
                    "neighbor_weight"                               = try(ipv4_neighbor.neighbor_weight, null)
                    "update_source_interface_id"                    = local.map_interface_logical_names["${device.name}:${ipv4_neighbor.update_source_interface}"].id
                } ]

                "ipv4_networks"           = [ for ipv4_network in try(vrf.bgp.ipv4_networks, {}) : {
                    "network_id"      = try(local.map_network_objects[ipv4_network.network].id, local.map_network_group_objects[ipv4_network.network].id, null)
                    "route_map_id"    = null
                } ]
                "ipv4_redistributions"    = [ for ipv4_redistribution in try(vrf.bgp.ipv4_redistributions, {}) : {
                    "match_external1"       = try(ipv4_redistribution.match_external1, null)
                    "match_external2"       = try(ipv4_redistribution.match_external2, null)
                    "match_internal"        = try(ipv4_redistribution.match_internal, null)
                    "match_nssa_external1"  = try(ipv4_redistribution.match_nssa_external1, null)
                    "match_nssa_external2"  = try(ipv4_redistribution.match_nssa_external2, null)
                    "metric"                = try(ipv4_redistribution.metric, null)
                    "process_id"            = try(ipv4_redistribution.process_id, null)
                    "route_map_id"          = null
                } ]
                "ipv4_route_injections"   = [ for ipv4_route_injection in try(vrf.bgp.ipv4_route_injections, {}) : {
                    "exist_route_map_id"    = null
                    "inject_route_map_id"   = null
                } ]
                "ipv4_synchronization"                  = try(vrf.bgp.ipv4_synchronization, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].bgp.ipv4_synchronization, null)  
              
                "domain_name"                           = domain.name              
              
              } if contains(keys(vrf), "bgp" ) && vrf.name == "Global"
        ]
      ]
    ]) : "${item.device_name}:Global" => item if contains(keys(item), "device_name" ) 
  }
}

resource "fmc_device_bgp" "module" {
  for_each = local.resource_bgp_global
  # Mandatory
    device_id                             = each.value.device_id
  
  # Optional
    ipv4_aggregate_addresses                  = each.value.ipv4_aggregate_addresses
    ipv4_auto_aummary                         = each.value.ipv4_auto_aummary
    ipv4_bgp_redistribute_internal            = each.value.ipv4_bgp_redistribute_internal
    ipv4_bgp_supress_inactive                 = each.value.ipv4_bgp_supress_inactive
    ipv4_default_information_orginate         = each.value.ipv4_default_information_orginate
    ipv4_external_distance                    = each.value.ipv4_external_distance
    ipv4_filterings                           = each.value.ipv4_filterings
    ipv4_forward_packets_over_multipath_ebgp  = each.value.ipv4_forward_packets_over_multipath_ebgp
    ipv4_forward_packets_over_multipath_ibgp  = each.value.ipv4_forward_packets_over_multipath_ibgp
    ipv4_internal_distance                    = each.value.ipv4_internal_distance
    ipv4_learned_route_map_id                 = each.value.ipv4_learned_route_map_id
    ipv4_local_distance                       = each.value.ipv4_local_distance
    ipv4_neighbors                            = each.value.ipv4_neighbors
    ipv4_networks                             = each.value.ipv4_networks
    ipv4_redistributions                      = each.value.ipv4_redistributions
    ipv4_route_injections                     = each.value.ipv4_route_injections
    ipv4_synchronization                      = each.value.ipv4_synchronization

    domain                                    = each.value.domain_name

    depends_on = [ 
      data.fmc_device.module,
      fmc_device.module,
      data.fmc_device_bgp_general_settings.module,
      fmc_device_bgp_general_settings.module,
      data.fmc_hosts.hosts,
      fmc_hosts.hosts,
      data.fmc_networks.networks,
      fmc_networks.networks,
      data.fmc_ranges.ranges,
      fmc_ranges.ranges,
      fmc_network_groups.network_groups,     
    ]
}