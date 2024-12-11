##########################################################
###    Content of the file:
##########################################################
#
###
#  Resources
####
# resource "fmc_device" "module" {
# resource "fmc_device_ha_pair" "module" {
# resource "fmc_device_ha_pair_monitoring" "module" {
# resource "fmc_device_physical_interface" "module" {
# resource "fmc_device_etherchannel_interface" "module" {
# resource "fmc_device_subinterface" "module" {
#
###  
#  Local variables
###
#  local.resource_device 
#  local.resource_device_ha_pair 
#  local.resource_device_ha_pair_monitored_interface 
#  local.resource_physical_interface 
#  local.resource_etherchannel_interface 
#  local.resource_sub_interface 
#
###

##########################################################
###    Example of created local variables
##########################################################


##########################################################
###    DEVICE
##########################################################

# OLD CODE - TODO 
locals {

  resource_device = {
    for item in flatten([
      for domain in local.domains : [
        for item_value in try(domain.devices.devices, []) : [ 
          merge(item_value, 
            {
              "domain_name" = domain.name
            })
        ]
      ]
      ]) : item.name => item if contains(keys(item), "name") && !contains(try(keys(local.data_device), []), item.name) #The device name is unique across the different domains.
  }
        
}

resource "fmc_device" "module" {
  for_each = local.resource_device

  # Mandatory
    name                      = each.key
    host_name                 = each.value.host_name
    registration_key          = each.value.registration_key
    access_policy_id          = local.map_access_control_policy[each.value.access_policy].id
    license_capabilities      = each.value.license_capabilities

  #Optional
    nat_id                    = try(each.value.nat_id, null)
    performance_tier          = try(each.value.performance_tier, null)
    prohibit_packet_transfer  = try(each.value.prohibit_packet_transfer, null)
    domain                    = try(each.value.domain_name, null)

  depends_on = [ 
    data.fmc_access_control_policy.module,
    fmc_access_control_policy.module,
   ]

}

##########################################################
###    DEVICE HA Pair
##########################################################
# TODO once PR is commited
locals {

  resource_device_ha_pair = {
    for item in flatten([
      for domain in local.domains : [
        for ha_pair in try(domain.devices.ha_pairs, []) : [ 
            {
              name = ha_pair.name
              domain_name = domain.name
            }
        ]
      ]
      ]) : item.name => item if contains(keys(item), "name") && !contains(try(keys(local.data_device_ha_pair), []), item.name) #The device name is unique across the different domains.
  }
        
}
resource "fmc_device_ha_pair" "module" {
  for_each = local.resource_device_ha_pair

    name                              = each.value.name
    primary_device_id                 = each.value.primary_device_id
    secondary_device_id               = each.value.secondary_device_id
    is_encryption_enabled             = each.value.is_encryption_enabled
    use_same_link_for_failovers       = each.value.use_same_link_for_failovers
    shared_key                        = each.value.shared_key
    enc_key_generation_scheme         = each.value.enc_key_generation_scheme
    lan_failover_standby_ip           = each.value.lan_failover_standby_ip
    lan_failover_active_ip            = each.value.lan_failover_active_ip
    lan_failover_name                 = each.value.lan_failover_name
    lan_failover_subnet_mask          = each.value.lan_failover_subnet_mask
    lan_failover_ipv6_addr            = each.value.lan_failover_ipv6_addr
    lan_failover_interface_name       = each.value.lan_failover_interface_name
    lan_failover_interface_id         = each.value.lan_failover_interface_id
    lan_failover_interface_type       = each.value.lan_failover_interface_type
    stateful_failover_standby_ip      = each.value.stateful_failover_standby_ip
    stateful_failover_active_ip       = each.value.stateful_failover_active_ip
    stateful_failover_name            = each.value.stateful_failover_name
    stateful_failover_subnet_mask     = each.value.stateful_failover_subnet_mask
    stateful_failover_ipv6_addr       = each.value.stateful_failover_ipv6_addr
    stateful_failover_interface_name  = each.value.stateful_failover_interface_name
    stateful_failover_interface_id    = each.value.stateful_failover_interface_id
    stateful_failover_interface_type  = each.value.stateful_failover_interface_type
    action                            = each.value.action
    #force_break                      = each.value.force_break

  depends_on = [
    fmc_device.module,
    data.fmc_device.module,
  ]
}
##########################################################
###    DEVICE HA Pair - Monitored interfaces - no data source used, no use case 
##########################################################

locals {

  resource_device_ha_pair_monitored_interface = {
    for item in flatten([
      for domain in local.domains : [
        for ha_pair in try(domain.devices.ha_pairs, []) : [ 
          for monitored_interface in try(ha_pair.interfaces, []) : [ 
            {
              device_name           = ha_pair.name
              device_id             = try(data.fmc_device_ha_pair.module[ha_pair.name].id, fmc_device_ha_pair.module[ha_pair.name].id)
              logical_name          = monitored_interface.logical_name
              ipv4_standby_address  = try(monitored_interface.ipv4_standby_address, null)
              monitor_interface     = try(monitored_interface.monitor_interface, null)
              domain_name           = domain.name
            }
          ]
        ]
      ]
      ]) : "${item.device_name}:${item.logical_name}" => item if contains(keys(item), "logical_name")  #The device name is unique across the different domains.
  }
        
}

resource "fmc_device_ha_pair_monitoring" "module" {
  for_each = local.resource_device_ha_pair_monitored_interface

  # Mandatory
    logical_name    = each.value.logical_name 
    device_id       = each.value.device_id

  #Optional
    monitor_interface    = each.value.monitor_interface
    ipv4_standby_address = each.value.ipv4_standby_address

  depends_on = [ 
    data.fmc_device_ha_pair.module,
    fmc_device_ha_pair.module,
    fmc_device_physical_interface.module,
    data.fmc_device_physical_interface.module,
    fmc_device_etherchannel_interface.module,
    data.fmc_device_etherchannel_interface.module,
    fmc_device_subinterface.module,
    data.fmc_device_subinterface.module,
   ]
}

##########################################################
###    Physical Interface
##########################################################

locals {

  resource_physical_interface = {
    for item in flatten([
      for domain in local.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : [ 
            for physical_interface in try(vrf.physical_interfaces, []) : [ 
                {
                  vrf_name    = vrf.name 
                  device_name = device.name

                  name            = physical_interface.name
                  device_id       = local.map_devices[device.name].id
                  mode            = try(physical_interface.mode, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.mode, null)

                  active_mac_address                          = try(physical_interface.active_mac_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.active_mac_address, null)
                  allow_full_fragment_reassembly              = try(physical_interface.allow_full_fragment_reassembly, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.allow_full_fragment_reassembly, null)
                  arp_table_entries                           = [ for arp_table_entry in try(physical_interface.arp_table_entries, []) : {
                                                                    enable_alias  = try(arp_table_entry.enable_alias, null)
                                                                    ip_address    = try(arp_table_entry.ip_address, null)
                                                                    mac_address   = try(arp_table_entry.mac_address, null)
                                                                  } ]
                  auto_negotiation                            = try(physical_interface.enabled, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.enabled, null)
                  description                                 = try(physical_interface.description, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.description, null)
                  domain_name                                 = domain.name
                  duplex                                      = try(physical_interface.duplex, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.duplex, null)
                  enable_anti_spoofing                        = try(physical_interface.enable_anti_spoofing, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.enable_anti_spoofing, null)
                  enable_sgt_propagate                        = try(physical_interface.enable_sgt_propagate, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.enable_sgt_propagate, null)
                  enabled                                     = try(physical_interface.enabled, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.enabled, null)
                  fec_mode                                    = try(physical_interface.fec_mode, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.fec_mode, null)
                  flow_control_send                           = try(physical_interface.flow_control_send, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.flow_control_send, null)
                  ip_based_monitoring                         = try(physical_interface.ip_based_monitoring, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ip_based_monitoring, null)  
                  ip_based_monitoring_next_hop                = try(physical_interface.ip_based_monitoring_next_hop, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ip_based_monitoring_next_hop, null)
                  ip_based_monitoring_type                    = try(physical_interface.ip_based_monitoring_type, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ip_based_monitoring_type, null)
                  ipv4_dhcp_obtain_route                      = try(physical_interface.ipv4_dhcp_obtain_route, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_dhcp_obtain_route, null)
                  ipv4_dhcp_route_metric                      = try(physical_interface.ipv4_dhcp_route_metric, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_dhcp_route_metric, null)
                  ipv4_pppoe_authentication                   = try(physical_interface.ipv4_pppoe_authentication, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_pppoe_authentication, null)
                  ipv4_pppoe_password                         = try(physical_interface.ipv4_pppoe_password, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_pppoe_password, null)
                  ipv4_pppoe_route_metric                     = try(physical_interface.ipv4_pppoe_route_metric, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_pppoe_route_metric, null)
                  ipv4_pppoe_route_settings                   = try(physical_interface.ipv4_pppoe_route_settings, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_pppoe_route_settings, null)
                  ipv4_pppoe_store_credentials_in_flash       = try(physical_interface.ipv4_pppoe_store_credentials_in_flash, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_pppoe_store_credentials_in_flash, null)
                  ipv4_pppoe_user                             = try(physical_interface.ipv4_pppoe_user, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_pppoe_user, null)
                  ipv4_pppoe_vpdn_group_name                  = try(physical_interface.ipv4_pppoe_vpdn_group_name, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_pppoe_vpdn_group_name, null)
                  ipv4_static_address                         = try(physical_interface.ipv4_static_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_static_address, null)
                  ipv4_static_netmask                         = try(physical_interface.ipv4_static_netmask, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv4_static_netmask, null)
                  ipv6_addresses                              = [ for ipv6_address in try(physical_interface.ipv6_addresses, []) : {
                                                                    address     = try(ipv6_address.address, null)
                                                                    enforce_eui = try(ipv6_address.enforce_eui, null)
                                                                    prefix      = try(ipv6_address.prefix, null)
                                                                  } ]
                  ipv6_dad_attempts                           = try(physical_interface.ipv6_dad_attempts, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_dad_attempts, null)
                  ipv6_default_route_by_dhcp                  = try(physical_interface.ipv6_default_route_by_dhcp, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_default_route_by_dhcp, null)
                  ipv6_dhcp                                   = try(physical_interface.ipv6_dhcp, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_dhcp, null)
                  ipv6_dhcp_client_pd_hint_prefixes           = try(physical_interface.ipv6_dhcp_client_pd_hint_prefixes, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_dhcp_client_pd_hint_prefixes, null)
                  ipv6_dhcp_client_pd_prefix_name             = try(physical_interface.ipv6_dhcp_client_pd_prefix_name, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_dhcp_client_pd_prefix_name, null)
                  ipv6_dhcp_pool_id                           = try(local.map_ipv6_dhcp_pools[physical_interface.ipv6_dhcp_pool].id, null)
                  ipv6_enable                                 = try(physical_interface.ipv6_enable, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_enable, null)
                  ipv6_enable_auto_config                     = try(physical_interface.ipv6_enable_auto_config, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_enable_auto_config, null)
                  ipv6_enable_dad                             = try(physical_interface.ipv6_enable_dad, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_enable_dad, null)
                  ipv6_enable_dhcp_address_config             = try(physical_interface.ipv6_enable_dhcp_address_config, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_enable_dhcp_address_config, null)
                  ipv6_enable_dhcp_nonaddress_config          = try(physical_interface.ipv6_enable_dhcp_nonaddress_config, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_enable_dhcp_nonaddress_config, null)
                  ipv6_enable_ra                              = try(physical_interface.ipv6_enable_ra, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_enable_ra, null)
                  ipv6_enforce_eui                            = try(physical_interface.ipv6_enforce_eui, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_enforce_eui, null)
                  ipv6_link_local_address                     = try(physical_interface.ipv6_link_local_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_link_local_address, null)
                  ipv6_ns_interval                            = try(physical_interface.ipv6_ns_interval, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_ns_interval, null)
                  ipv6_prefixes                               = [ for ipv6_prefix in try(physical_interface.ipv6_prefixes, []) : {
                                                                    address     = try(ipv6_prefix.address, null)
                                                                    enforce_eui = try(ipv6_prefix.enforce_eui, null)
                                                                    default      = try(ipv6_prefix.default, null)
                                                                  } ]
                  ipv6_ra_interval                            = try(physical_interface.ipv6_ra_interval, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_ra_interval, null)
                  ipv6_ra_life_time                           = try(physical_interface.ipv6_ra_life_time, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_ra_life_time, null)
                  ipv6_reachable_time                         = try(physical_interface.ipv6_reachable_time, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.ipv6_reachable_time, null)
                  lldp_receive                                = try(physical_interface.lldp_receive, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.lldp_receive, null)
                  lldp_transmit                               = try(physical_interface.lldp_transmit, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.lldp_transmit, null)
                  logical_name                                = try(physical_interface.logical_name, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.logical_name, null)
                  management_access                           = try(physical_interface.management_access, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.management_access, null)
                  management_access_network_objects           = [ for management_access_network_object in try(physical_interface.management_access_network_objects, []) : {
                                                                    id    = try(local.map_network_objects[management_access_network_object].id, local.map_network_group_objects[management_access_network_object].id, null)
                                                                    type  = try(local.map_network_objects[management_access_network_object].type, local.map_network_group_objects[management_access_network_object].type, null)
                                                                  } ]
                  management_only                             = try(physical_interface.management_only, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.management_only, null)
                  mtu                                         = try(physical_interface.mtu, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.mtu, null)
                  nve_only                                    = try(physical_interface.nve_only, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.nve_only, null)
                  override_default_fragment_setting_chain     = try(physical_interface.override_default_fragment_setting_chain, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.override_default_fragment_setting_chain, null)
                  override_default_fragment_setting_size      = try(physical_interface.override_default_fragment_setting_size, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.override_default_fragment_setting_size, null)
                  override_default_fragment_setting_timeout   = try(physical_interface.override_default_fragment_setting_timeout, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.override_default_fragment_setting_timeout, null)
                  priority                                    = try(physical_interface.priority, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.priority, null)
                  security_zone_id                            = try(local.map_security_zones[physical_interface.security_zone].id, null)
                  speed                                       = try(physical_interface.speed, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.speed, null)
                  standby_mac_address                         = try(physical_interface.standby_mac_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].physical_interfaces.standby_mac_address, null)
                  
                }
            ]
          ]
        ]
      ]
    ]) : "${item.device_name}:${item.name}" => item if contains(keys(item), "name") && !contains(try(keys(local.data_physical_interface), []), "${item.device_name}:${item.name}") #The device name is unique across the different domains.
  }
        
}

resource "fmc_device_physical_interface" "module" {
  for_each = local.resource_physical_interface

  # Mandatory
    name            = each.value.name
    device_id       = each.value.device_id
    mode            = each.value.mode

  #Optional
    active_mac_address                          = each.value.active_mac_address
    allow_full_fragment_reassembly              = each.value.allow_full_fragment_reassembly
    arp_table_entries                           = each.value.arp_table_entries
    auto_negotiation                            = each.value.auto_negotiation
    description                                 = each.value.description
    domain                                      = each.value.domain_name
    duplex                                      = each.value.duplex
    enable_anti_spoofing                        = each.value.enable_anti_spoofing
    enable_sgt_propagate                        = each.value.enable_sgt_propagate
    enabled                                     = each.value.enabled
    fec_mode                                    = each.value.fec_mode
    flow_control_send                           = each.value.flow_control_send
    ip_based_monitoring                         = each.value.ip_based_monitoring
    ip_based_monitoring_next_hop                = each.value.ip_based_monitoring_next_hop
    ip_based_monitoring_type                    = each.value.ip_based_monitoring_type
    ipv4_dhcp_obtain_route                      = each.value.ipv4_dhcp_obtain_route
    ipv4_dhcp_route_metric                      = each.value.ipv4_dhcp_route_metric
    ipv4_pppoe_authentication                   = each.value.ipv4_pppoe_authentication
    ipv4_pppoe_password                         = each.value.ipv4_pppoe_password
    ipv4_pppoe_route_metric                     = each.value.ipv4_pppoe_route_metric
    ipv4_pppoe_route_settings                   = each.value.ipv4_pppoe_route_settings
    ipv4_pppoe_store_credentials_in_flash       = each.value.ipv4_pppoe_store_credentials_in_flash
    ipv4_pppoe_user                             = each.value.ipv4_pppoe_user
    ipv4_pppoe_vpdn_group_name                  = each.value.ipv4_pppoe_vpdn_group_name
    ipv4_static_address                         = each.value.ipv4_static_address
    ipv4_static_netmask                         = each.value.ipv4_static_netmask
    ipv6_addresses                              = each.value.ipv6_addresses
    ipv6_dad_attempts                           = each.value.ipv6_dad_attempts
    ipv6_default_route_by_dhcp                  = each.value.ipv6_default_route_by_dhcp
    ipv6_dhcp                                   = each.value.ipv6_dhcp
    ipv6_dhcp_client_pd_hint_prefixes           = each.value.ipv6_dhcp_client_pd_hint_prefixes
    ipv6_dhcp_client_pd_prefix_name             = each.value.ipv6_dhcp_client_pd_prefix_name
    ipv6_dhcp_pool_id                           = each.value.ipv6_dhcp_pool_id
    ipv6_enable                                 = each.value.ipv6_enable
    ipv6_enable_auto_config                     = each.value.ipv6_enable_auto_config
    ipv6_enable_dad                             = each.value.ipv6_enable_dad
    ipv6_enable_dhcp_address_config             = each.value.ipv6_enable_dhcp_address_config
    ipv6_enable_dhcp_nonaddress_config          = each.value.ipv6_enable_dhcp_nonaddress_config
    ipv6_enable_ra                              = each.value.ipv6_enable_ra
    ipv6_enforce_eui                            = each.value.ipv6_enforce_eui
    ipv6_link_local_address                     = each.value.ipv6_link_local_address
    ipv6_ns_interval                            = each.value.ipv6_ns_interval
    ipv6_prefixes                               = each.value.ipv6_prefixes
    ipv6_ra_interval                            = each.value.ipv6_ra_interval
    ipv6_ra_life_time                           = each.value.ipv6_ra_life_time
    ipv6_reachable_time                         = each.value.ipv6_reachable_time
    lldp_receive                                = each.value.lldp_receive
    lldp_transmit                               = each.value.lldp_transmit
    logical_name                                = each.value.logical_name
    management_access                           = each.value.management_access
    management_access_network_objects           = each.value.management_access_network_objects
    management_only                             = each.value.management_only
    mtu                                         = each.value.mtu
    nve_only                                    = each.value.nve_only
    override_default_fragment_setting_chain     = each.value.override_default_fragment_setting_chain
    override_default_fragment_setting_size      = each.value.override_default_fragment_setting_size
    override_default_fragment_setting_timeout   = each.value.override_default_fragment_setting_timeout
    priority                                    = each.value.priority
    security_zone_id                            = each.value.security_zone_id
    speed                                       = each.value.speed
    standby_mac_address                         = each.value.standby_mac_address

  depends_on = [ 
    fmc_device.module,
    data.fmc_device.module
   ]
}
##########################################################
###    Ether-Channel Interface
##########################################################

locals {

  resource_etherchannel_interface = {
    for item in flatten([
      for domain in local.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : [ 
            for etherchannel_interface in try(vrf.etherchannel_interfaces, []) : [ 
                {
                  vrf_name    = vrf.name 
                  device_name = device.name

                  name            = etherchannel_interface.name
                  ether_channel_id  = split("Port-channel", etherchannel_interface.name)[length(split("Port-channel", etherchannel_interface.name))-1]
                  device_id         = local.map_devices[device.name].id
                  mode              = try(etherchannel_interface.mode, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.mode, null)

                  active_mac_address                          = try(etherchannel_interface.active_mac_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.active_mac_address, null)
                  allow_full_fragment_reassembly              = try(etherchannel_interface.allow_full_fragment_reassembly, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.allow_full_fragment_reassembly, null)
                  arp_table_entries                           = [ for arp_table_entry in try(etherchannel_interface.arp_table_entries, []) : {
                                                                    enable_alias  = try(arp_table_entry.enable_alias, null)
                                                                    ip_address    = try(arp_table_entry.ip_address, null)
                                                                    mac_address   = try(arp_table_entry.mac_address, null)
                                                                  } ]
                  auto_negotiation                            = try(etherchannel_interface.enabled, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.enabled, null)
                  description                                 = try(etherchannel_interface.description, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.description, null)
                  domain_name                                 = domain.name
                  duplex                                      = try(etherchannel_interface.duplex, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.duplex, null)
                  enable_anti_spoofing                        = try(etherchannel_interface.enable_anti_spoofing, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.enable_anti_spoofing, null)
                  enable_sgt_propagate                        = try(etherchannel_interface.enable_sgt_propagate, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.enable_sgt_propagate, null)
                  enabled                                     = try(etherchannel_interface.enabled, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.enabled, null)
                  fec_mode                                    = try(etherchannel_interface.fec_mode, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.fec_mode, null)
                  flow_control_send                           = try(etherchannel_interface.flow_control_send, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.flow_control_send, null)
                  ip_based_monitoring                         = try(etherchannel_interface.ip_based_monitoring, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ip_based_monitoring, null)  
                  ip_based_monitoring_next_hop                = try(etherchannel_interface.ip_based_monitoring_next_hop, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ip_based_monitoring_next_hop, null)
                  ip_based_monitoring_type                    = try(etherchannel_interface.ip_based_monitoring_type, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ip_based_monitoring_type, null)
                  ipv4_dhcp_obtain_route                      = try(etherchannel_interface.ipv4_dhcp_obtain_route, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_dhcp_obtain_route, null)
                  ipv4_dhcp_route_metric                      = try(etherchannel_interface.ipv4_dhcp_route_metric, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_dhcp_route_metric, null)
                  ipv4_pppoe_authentication                   = try(etherchannel_interface.ipv4_pppoe_authentication, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_authentication, null)
                  ipv4_pppoe_password                         = try(etherchannel_interface.ipv4_pppoe_password, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_password, null)
                  ipv4_pppoe_route_metric                     = try(etherchannel_interface.ipv4_pppoe_route_metric, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_route_metric, null)
                  ipv4_pppoe_route_settings                   = try(etherchannel_interface.ipv4_pppoe_route_settings, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_route_settings, null)
                  ipv4_pppoe_store_credentials_in_flash       = try(etherchannel_interface.ipv4_pppoe_store_credentials_in_flash, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_store_credentials_in_flash, null)
                  ipv4_pppoe_user                             = try(etherchannel_interface.ipv4_pppoe_user, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_user, null)
                  ipv4_pppoe_vpdn_group_name                  = try(etherchannel_interface.ipv4_pppoe_vpdn_group_name, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_vpdn_group_name, null)
                  ipv4_static_address                         = try(etherchannel_interface.ipv4_static_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_static_address, null)
                  ipv4_static_netmask                         = try(etherchannel_interface.ipv4_static_netmask, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_static_netmask, null)
                  ipv6_addresses                              = [ for ipv6_address in try(etherchannel_interface.ipv6_addresses, []) : {
                                                                    address     = try(ipv6_address.address, null)
                                                                    enforce_eui = try(ipv6_address.enforce_eui, null)
                                                                    prefix      = try(ipv6_address.prefix, null)
                                                                  } ]
                  ipv6_dad_attempts                           = try(etherchannel_interface.ipv6_dad_attempts, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_dad_attempts, null)
                  ipv6_default_route_by_dhcp                  = try(etherchannel_interface.ipv6_default_route_by_dhcp, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_default_route_by_dhcp, null)
                  ipv6_dhcp                                   = try(etherchannel_interface.ipv6_dhcp, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_dhcp, null)
                  ipv6_dhcp_client_pd_hint_prefixes           = try(etherchannel_interface.ipv6_dhcp_client_pd_hint_prefixes, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_dhcp_client_pd_hint_prefixes, null)
                  ipv6_dhcp_client_pd_prefix_name             = try(etherchannel_interface.ipv6_dhcp_client_pd_prefix_name, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_dhcp_client_pd_prefix_name, null)
                  ipv6_dhcp_pool_id                           = try(local.map_ipv6_dhcp_pools[etherchannel_interface.ipv6_dhcp_pool].id, null)
                  ipv6_enable                                 = try(etherchannel_interface.ipv6_enable, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable, null)
                  ipv6_enable_auto_config                     = try(etherchannel_interface.ipv6_enable_auto_config, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_auto_config, null)
                  ipv6_enable_dad                             = try(etherchannel_interface.ipv6_enable_dad, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_dad, null)
                  ipv6_enable_dhcp_address_config             = try(etherchannel_interface.ipv6_enable_dhcp_address_config, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_dhcp_address_config, null)
                  ipv6_enable_dhcp_nonaddress_config          = try(etherchannel_interface.ipv6_enable_dhcp_nonaddress_config, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_dhcp_nonaddress_config, null)
                  ipv6_enable_ra                              = try(etherchannel_interface.ipv6_enable_ra, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_ra, null)
                  ipv6_enforce_eui                            = try(etherchannel_interface.ipv6_enforce_eui, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enforce_eui, null)
                  ipv6_link_local_address                     = try(etherchannel_interface.ipv6_link_local_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_link_local_address, null)
                  ipv6_ns_interval                            = try(etherchannel_interface.ipv6_ns_interval, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_ns_interval, null)
                  ipv6_prefixes                               = [ for ipv6_prefix in try(etherchannel_interface.ipv6_prefixes, []) : {
                                                                    address     = try(ipv6_prefix.address, null)
                                                                    enforce_eui = try(ipv6_prefix.enforce_eui, null)
                                                                    default      = try(ipv6_prefix.default, null)
                                                                  } ]
                  ipv6_ra_interval                            = try(etherchannel_interface.ipv6_ra_interval, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_ra_interval, null)
                  ipv6_ra_life_time                           = try(etherchannel_interface.ipv6_ra_life_time, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_ra_life_time, null)
                  ipv6_reachable_time                         = try(etherchannel_interface.ipv6_reachable_time, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_reachable_time, null)
                  lldp_receive                                = try(etherchannel_interface.lldp_receive, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.lldp_receive, null)
                  lldp_transmit                               = try(etherchannel_interface.lldp_transmit, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.lldp_transmit, null)
                  logical_name                                = try(etherchannel_interface.logical_name, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.logical_name, null)
                  management_access                           = try(etherchannel_interface.management_access, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.management_access, null)
                  management_access_network_objects           = [ for management_access_network_object in try(etherchannel_interface.management_access_network_objects, []) : {
                                                                    id    = try(local.map_network_objects[management_access_network_object].id, local.map_network_group_objects[management_access_network_object].id, null)
                                                                    type  = try(local.map_network_objects[management_access_network_object].type, local.map_network_group_objects[management_access_network_object].type, null)
                                                                  } ]
                  management_only                             = try(etherchannel_interface.management_only, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.management_only, null)
                  mtu                                         = try(etherchannel_interface.mtu, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.mtu, null)
                  nve_only                                    = try(etherchannel_interface.nve_only, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.nve_only, null)
                  override_default_fragment_setting_chain     = try(etherchannel_interface.override_default_fragment_setting_chain, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.override_default_fragment_setting_chain, null)
                  override_default_fragment_setting_size      = try(etherchannel_interface.override_default_fragment_setting_size, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.override_default_fragment_setting_size, null)
                  override_default_fragment_setting_timeout   = try(etherchannel_interface.override_default_fragment_setting_timeout, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.override_default_fragment_setting_timeout, null)
                  priority                                    = try(etherchannel_interface.priority, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.priority, null)
                  security_zone_id                            = try(local.map_security_zones[etherchannel_interface.security_zone].id, null)
                  selected_interfaces                         = [ for selected_interface in try(etherchannel_interface.selected_interfaces, []) : {
                                                                    id    = try(fmc_device_physical_interface.module["${device.name}:${selected_interface}"].id, data.fmc_device_physical_interface.module["${device.name}:${selected_interface}"].id)
                                                                    name  = selected_interface
                                                                  } ]
                  speed                                       = try(etherchannel_interface.speed, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.speed, null)
                  standby_mac_address                         = try(etherchannel_interface.standby_mac_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.standby_mac_address, null)
                  
                }
            ]
          ]
        ]
      ]
    ]) : "${item.device_name}:${item.name}" => item if contains(keys(item), "name") && !contains(try(keys(local.data_physical_interface), []), "${item.device_name}:${item.name}") #The device name is unique across the different domains.
  }

}

resource "fmc_device_etherchannel_interface" "module" {
  for_each = local.resource_etherchannel_interface

  # Mandatory
    device_id         = each.value.device_id
    ether_channel_id  = each.value.ether_channel_id
    mode              = each.value.mode

  #Optional
    active_mac_address                          = each.value.active_mac_address
    allow_full_fragment_reassembly              = each.value.allow_full_fragment_reassembly
    arp_table_entries                           = each.value.arp_table_entries
    auto_negotiation                            = each.value.auto_negotiation
    description                                 = each.value.description
    domain                                      = each.value.domain_name
    duplex                                      = each.value.duplex
    enable_anti_spoofing                        = each.value.enable_anti_spoofing
    enable_sgt_propagate                        = each.value.enable_sgt_propagate
    enabled                                     = each.value.enabled
    fec_mode                                    = each.value.fec_mode
    flow_control_send                           = each.value.flow_control_send
    ip_based_monitoring                         = each.value.ip_based_monitoring
    ip_based_monitoring_next_hop                = each.value.ip_based_monitoring_next_hop
    ip_based_monitoring_type                    = each.value.ip_based_monitoring_type
    ipv4_dhcp_obtain_route                      = each.value.ipv4_dhcp_obtain_route
    ipv4_dhcp_route_metric                      = each.value.ipv4_dhcp_route_metric
    ipv4_pppoe_authentication                   = each.value.ipv4_pppoe_authentication
    ipv4_pppoe_password                         = each.value.ipv4_pppoe_password
    ipv4_pppoe_route_metric                     = each.value.ipv4_pppoe_route_metric
    ipv4_pppoe_route_settings                   = each.value.ipv4_pppoe_route_settings
    ipv4_pppoe_store_credentials_in_flash       = each.value.ipv4_pppoe_store_credentials_in_flash
    ipv4_pppoe_user                             = each.value.ipv4_pppoe_user
    ipv4_pppoe_vpdn_group_name                  = each.value.ipv4_pppoe_vpdn_group_name
    ipv4_static_address                         = each.value.ipv4_static_address
    ipv4_static_netmask                         = each.value.ipv4_static_netmask
    ipv6_addresses                              = each.value.ipv6_addresses
    ipv6_dad_attempts                           = each.value.ipv6_dad_attempts
    ipv6_default_route_by_dhcp                  = each.value.ipv6_default_route_by_dhcp
    ipv6_dhcp                                   = each.value.ipv6_dhcp
    ipv6_dhcp_client_pd_hint_prefixes           = each.value.ipv6_dhcp_client_pd_hint_prefixes
    ipv6_dhcp_client_pd_prefix_name             = each.value.ipv6_dhcp_client_pd_prefix_name
    ipv6_dhcp_pool_id                           = each.value.ipv6_dhcp_pool_id
    ipv6_enable                                 = each.value.ipv6_enable
    ipv6_enable_auto_config                     = each.value.ipv6_enable_auto_config
    ipv6_enable_dad                             = each.value.ipv6_enable_dad
    ipv6_enable_dhcp_address_config             = each.value.ipv6_enable_dhcp_address_config
    ipv6_enable_dhcp_nonaddress_config          = each.value.ipv6_enable_dhcp_nonaddress_config
    ipv6_enable_ra                              = each.value.ipv6_enable_ra
    ipv6_enforce_eui                            = each.value.ipv6_enforce_eui
    ipv6_link_local_address                     = each.value.ipv6_link_local_address
    ipv6_ns_interval                            = each.value.ipv6_ns_interval
    ipv6_prefixes                               = each.value.ipv6_prefixes
    ipv6_ra_interval                            = each.value.ipv6_ra_interval
    ipv6_ra_life_time                           = each.value.ipv6_ra_life_time
    ipv6_reachable_time                         = each.value.ipv6_reachable_time
    lldp_receive                                = each.value.lldp_receive
    lldp_transmit                               = each.value.lldp_transmit
    logical_name                                = each.value.logical_name
    management_access                           = each.value.management_access
    management_access_network_objects           = each.value.management_access_network_objects
    management_only                             = each.value.management_only
    mtu                                         = each.value.mtu
    nve_only                                    = each.value.nve_only
    override_default_fragment_setting_chain     = each.value.override_default_fragment_setting_chain
    override_default_fragment_setting_size      = each.value.override_default_fragment_setting_size
    override_default_fragment_setting_timeout   = each.value.override_default_fragment_setting_timeout
    priority                                    = each.value.priority
    security_zone_id                            = each.value.security_zone_id
    selected_interfaces                         = each.value.selected_interfaces
    speed                                       = each.value.speed
    standby_mac_address                         = each.value.standby_mac_address

  depends_on = [ 
    fmc_device.module,
    data.fmc_device.module,
    fmc_device_physical_interface.module,
    data.fmc_device_physical_interface.module
   ]

}

##########################################################
###    Sub-Interface
##########################################################

locals {

  resource_sub_interface = {
    for item in flatten([
      for domain in local.domains : [
        for device in try(domain.devices.devices, []) : [ 
          for vrf in try(device.vrfs, []) : [ 
            for sub_interface in try(vrf.sub_interfaces, []) : [ 
                {
                  vrf_name    = vrf.name 
                  device_name = device.name

                  name              = sub_interface.name
                  interface_name    = split(".", sub_interface.name)[length(split(".", sub_interface.name))-2]
                  sub_interface_id  = split(".", sub_interface.name)[length(split(".", sub_interface.name))-1]
                  device_id         = local.map_devices[device.name].id
                  vlan_id           = sub_interface.vlan

                  active_mac_address                          = try(sub_interface.active_mac_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.active_mac_address, null)
                  allow_full_fragment_reassembly              = try(sub_interface.allow_full_fragment_reassembly, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.allow_full_fragment_reassembly, null)
                  arp_table_entries                           = [ for arp_table_entry in try(sub_interface.arp_table_entries, []) : {
                                                                    enable_alias  = try(arp_table_entry.enable_alias, null)
                                                                    ip_address    = try(arp_table_entry.ip_address, null)
                                                                    mac_address   = try(arp_table_entry.mac_address, null)
                                                                  } ]
                  description                                 = try(sub_interface.description, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.description, null)
                  domain_name                                 = domain.name
                  enable_anti_spoofing                        = try(sub_interface.enable_anti_spoofing, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.enable_anti_spoofing, null)
                  enable_sgt_propagate                        = try(sub_interface.enable_sgt_propagate, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.enable_sgt_propagate, null)
                  enabled                                     = try(sub_interface.enabled, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.enabled, null)
                  ip_based_monitoring                         = try(sub_interface.ip_based_monitoring, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ip_based_monitoring, null)  
                  ip_based_monitoring_next_hop                = try(sub_interface.ip_based_monitoring_next_hop, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ip_based_monitoring_next_hop, null)
                  ip_based_monitoring_type                    = try(sub_interface.ip_based_monitoring_type, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ip_based_monitoring_type, null)
                  ipv4_dhcp_obtain_route                      = try(sub_interface.ipv4_dhcp_obtain_route, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_dhcp_obtain_route, null)
                  ipv4_dhcp_route_metric                      = try(sub_interface.ipv4_dhcp_route_metric, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_dhcp_route_metric, null)
                  ipv4_pppoe_authentication                   = try(sub_interface.ipv4_pppoe_authentication, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_authentication, null)
                  ipv4_pppoe_password                         = try(sub_interface.ipv4_pppoe_password, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_password, null)
                  ipv4_pppoe_route_metric                     = try(sub_interface.ipv4_pppoe_route_metric, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_route_metric, null)
                  ipv4_pppoe_route_settings                   = try(sub_interface.ipv4_pppoe_route_settings, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_route_settings, null)
                  ipv4_pppoe_store_credentials_in_flash       = try(sub_interface.ipv4_pppoe_store_credentials_in_flash, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_store_credentials_in_flash, null)
                  ipv4_pppoe_user                             = try(sub_interface.ipv4_pppoe_user, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_user, null)
                  ipv4_pppoe_vpdn_group_name                  = try(sub_interface.ipv4_pppoe_vpdn_group_name, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_pppoe_vpdn_group_name, null)
                  ipv4_static_address                         = try(sub_interface.ipv4_static_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_static_address, null)
                  ipv4_static_netmask                         = try(sub_interface.ipv4_static_netmask, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv4_static_netmask, null)
                  ipv6_addresses                              = [ for ipv6_address in try(sub_interface.ipv6_addresses, []) : {
                                                                    address     = try(ipv6_address.address, null)
                                                                    enforce_eui = try(ipv6_address.enforce_eui, null)
                                                                    prefix      = try(ipv6_address.prefix, null)
                                                                  } ]
                  ipv6_dad_attempts                           = try(sub_interface.ipv6_dad_attempts, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_dad_attempts, null)
                  ipv6_default_route_by_dhcp                  = try(sub_interface.ipv6_default_route_by_dhcp, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_default_route_by_dhcp, null)
                  ipv6_dhcp                                   = try(sub_interface.ipv6_dhcp, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_dhcp, null)
                  ipv6_dhcp_client_pd_hint_prefixes           = try(sub_interface.ipv6_dhcp_client_pd_hint_prefixes, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_dhcp_client_pd_hint_prefixes, null)
                  ipv6_dhcp_client_pd_prefix_name             = try(sub_interface.ipv6_dhcp_client_pd_prefix_name, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_dhcp_client_pd_prefix_name, null)
                  ipv6_dhcp_pool_id                           = try(local.map_ipv6_dhcp_pools[sub_interface.ipv6_dhcp_pool].id, null)
                  ipv6_enable                                 = try(sub_interface.ipv6_enable, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable, null)
                  ipv6_enable_auto_config                     = try(sub_interface.ipv6_enable_auto_config, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_auto_config, null)
                  ipv6_enable_dad                             = try(sub_interface.ipv6_enable_dad, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_dad, null)
                  ipv6_enable_dhcp_address_config             = try(sub_interface.ipv6_enable_dhcp_address_config, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_dhcp_address_config, null)
                  ipv6_enable_dhcp_nonaddress_config          = try(sub_interface.ipv6_enable_dhcp_nonaddress_config, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_dhcp_nonaddress_config, null)
                  ipv6_enable_ra                              = try(sub_interface.ipv6_enable_ra, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enable_ra, null)
                  ipv6_enforce_eui                            = try(sub_interface.ipv6_enforce_eui, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_enforce_eui, null)
                  ipv6_link_local_address                     = try(sub_interface.ipv6_link_local_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_link_local_address, null)
                  ipv6_ns_interval                            = try(sub_interface.ipv6_ns_interval, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_ns_interval, null)
                  ipv6_prefixes                               = [ for ipv6_prefix in try(sub_interface.ipv6_prefixes, []) : {
                                                                    address     = try(ipv6_prefix.address, null)
                                                                    enforce_eui = try(ipv6_prefix.enforce_eui, null)
                                                                    default      = try(ipv6_prefix.default, null)
                                                                  } ]
                  ipv6_ra_interval                            = try(sub_interface.ipv6_ra_interval, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_ra_interval, null)
                  ipv6_ra_life_time                           = try(sub_interface.ipv6_ra_life_time, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_ra_life_time, null)
                  ipv6_reachable_time                         = try(sub_interface.ipv6_reachable_time, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.ipv6_reachable_time, null)
                  logical_name                                = try(sub_interface.logical_name, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.logical_name, null)
                  management_only                             = try(sub_interface.management_only, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.management_only, null)
                  mtu                                         = try(sub_interface.mtu, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.mtu, null)
                  nve_only                                    = try(sub_interface.nve_only, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.nve_only, null)
                  override_default_fragment_setting_chain     = try(sub_interface.override_default_fragment_setting_chain, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.override_default_fragment_setting_chain, null)
                  override_default_fragment_setting_size      = try(sub_interface.override_default_fragment_setting_size, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.override_default_fragment_setting_size, null)
                  override_default_fragment_setting_timeout   = try(sub_interface.override_default_fragment_setting_timeout, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.override_default_fragment_setting_timeout, null)
                  priority                                    = try(sub_interface.priority, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.priority, null)
                  security_zone_id                            = try(local.map_security_zones[sub_interface.security_zone].id, null)
                  standby_mac_address                         = try(sub_interface.standby_mac_address, local.defaults.fmc.domains[domain.name].devices.devices.vrfs[vrf.name].etherchannel_interfaces.standby_mac_address, null)
                  
                }
            ]
          ]
        ]
      ]
    ]) : "${item.device_name}:${item.name}" => item if contains(keys(item), "name") && !contains(try(keys(local.data_sub_interface), []), "${item.device_name}:${item.name}") #The device name is unique across the different domains.
  }

}

resource "fmc_device_subinterface" "module" {
  for_each = local.resource_sub_interface

  # Mandatory
    device_id         = each.value.device_id
    interface_name    = each.value.interface_name
    sub_interface_id  = each.value.sub_interface_id
    vlan_id           = each.value.vlan_id

  #Optional
    active_mac_address                          = each.value.active_mac_address
    allow_full_fragment_reassembly              = each.value.allow_full_fragment_reassembly
    arp_table_entries                           = each.value.arp_table_entries
    description                                 = each.value.description
    domain                                      = each.value.domain_name
    enable_anti_spoofing                        = each.value.enable_anti_spoofing
    enable_sgt_propagate                        = each.value.enable_sgt_propagate
    enabled                                     = each.value.enabled
    ip_based_monitoring                         = each.value.ip_based_monitoring
    ip_based_monitoring_next_hop                = each.value.ip_based_monitoring_next_hop
    ip_based_monitoring_type                    = each.value.ip_based_monitoring_type
    ipv4_dhcp_obtain_route                      = each.value.ipv4_dhcp_obtain_route
    ipv4_dhcp_route_metric                      = each.value.ipv4_dhcp_route_metric
    ipv4_pppoe_authentication                   = each.value.ipv4_pppoe_authentication
    ipv4_pppoe_password                         = each.value.ipv4_pppoe_password
    ipv4_pppoe_route_metric                     = each.value.ipv4_pppoe_route_metric
    ipv4_pppoe_route_settings                   = each.value.ipv4_pppoe_route_settings
    ipv4_pppoe_store_credentials_in_flash       = each.value.ipv4_pppoe_store_credentials_in_flash
    ipv4_pppoe_user                             = each.value.ipv4_pppoe_user
    ipv4_pppoe_vpdn_group_name                  = each.value.ipv4_pppoe_vpdn_group_name
    ipv4_static_address                         = each.value.ipv4_static_address
    ipv4_static_netmask                         = each.value.ipv4_static_netmask
    ipv6_addresses                              = each.value.ipv6_addresses
    ipv6_dad_attempts                           = each.value.ipv6_dad_attempts
    ipv6_default_route_by_dhcp                  = each.value.ipv6_default_route_by_dhcp
    ipv6_dhcp                                   = each.value.ipv6_dhcp
    ipv6_dhcp_client_pd_hint_prefixes           = each.value.ipv6_dhcp_client_pd_hint_prefixes
    ipv6_dhcp_client_pd_prefix_name             = each.value.ipv6_dhcp_client_pd_prefix_name
    ipv6_dhcp_pool_id                           = each.value.ipv6_dhcp_pool_id
    ipv6_enable                                 = each.value.ipv6_enable
    ipv6_enable_auto_config                     = each.value.ipv6_enable_auto_config
    ipv6_enable_dad                             = each.value.ipv6_enable_dad
    ipv6_enable_dhcp_address_config             = each.value.ipv6_enable_dhcp_address_config
    ipv6_enable_dhcp_nonaddress_config          = each.value.ipv6_enable_dhcp_nonaddress_config
    ipv6_enable_ra                              = each.value.ipv6_enable_ra
    ipv6_enforce_eui                            = each.value.ipv6_enforce_eui
    ipv6_link_local_address                     = each.value.ipv6_link_local_address
    ipv6_ns_interval                            = each.value.ipv6_ns_interval
    ipv6_prefixes                               = each.value.ipv6_prefixes
    ipv6_ra_interval                            = each.value.ipv6_ra_interval
    ipv6_ra_life_time                           = each.value.ipv6_ra_life_time
    ipv6_reachable_time                         = each.value.ipv6_reachable_time
    logical_name                                = each.value.logical_name
    management_only                             = each.value.management_only
    mtu                                         = each.value.mtu
    override_default_fragment_setting_chain     = each.value.override_default_fragment_setting_chain
    override_default_fragment_setting_size      = each.value.override_default_fragment_setting_size
    override_default_fragment_setting_timeout   = each.value.override_default_fragment_setting_timeout
    priority                                    = each.value.priority
    security_zone_id                            = each.value.security_zone_id
    standby_mac_address                         = each.value.standby_mac_address

  depends_on = [ 
    fmc_device.module,
    data.fmc_device.module,
    fmc_device_physical_interface.module,
    data.fmc_device_physical_interface.module,
    fmc_device_etherchannel_interface.module,
    data.fmc_device_etherchannel_interface.module
   ]

}

##########################################################
###    Create maps for combined set of _data and _resources devices  
##########################################################

######
### map_devices
######
locals {
  map_devices = merge({
      for item in flatten([
        for device_key, device_value in local.resource_device :  { 
            name = device_key
            id   = fmc_device.module[device_key].id
            type = fmc_device.module[device_key].type
            domain_name = device_value.domain_name
          }
        ]) : item.name => item if contains(keys(item), "name" )
    }, 
    {
      for item in flatten([
        for device_key, device_value in local.data_device : { 
            name = device_key
            id   = data.fmc_device.module[device_key].id
            type = data.fmc_device.module[device_key].type
            domain_name = device_value.domain_name
          }
        ]) : item.name => item if contains(keys(item), "name" )
    }, 
  )

}

##########################################################
###    Create maps for combined set of _data and _resources vrf  
##########################################################

######
### map_vrfs
######
locals {
  map_vrfs = merge({
      for item in flatten([
        for vrf_key, vrf_value in local.resource_vrf :  { 
            name = vrf_key
            id   = fmc_device_vrf.module[vrf_key].id
            domain_name = vrf_value.domain_name
          }
        ]) : item.name => item if contains(keys(item), "name" )
    }, 
    {
      for item in flatten([
        for vrf_key, vrf_value in local.data_vrf : { 
            name = vrf_key
            id   = data.fmc_device_vrf.module[vrf_key].id
            domain_name = vrf_value.domain_name
          }
        ]) : item.name => item if contains(keys(item), "name" )
    }, 
  )

}

##########################################################
###    Create maps for combined set of _data and _resources physical_interfaces  
##########################################################

######
### map_physical_interfaces by logical_name as a key
######

locals {
  map_interface_logical_names = merge({
      for item in flatten([
        for physical_interface_key, physical_interface_value in local.resource_physical_interface : { 
            name          = physical_interface_key
            device_name   = physical_interface_value.device_name
            id            = fmc_device_physical_interface.module[physical_interface_key].id
            logical_name  = physical_interface_value.logical_name
            domain_name   = physical_interface_value.domain_name
          }
        ]) : "${item.device_name}:${item.logical_name}" => item if item.logical_name != null 
    }, 
    {
      for item in flatten([
        for physical_interface_key, physical_interface_value in local.data_physical_interface : { 
            name          = physical_interface_key
            device_name   = physical_interface_value.device_name
            id            = data.fmc_device_physical_interface.module[physical_interface_key].id
            logical_name  = try(data.fmc_device_physical_interface.module[physical_interface_key].logical_name, null)
            domain_name   = physical_interface_value.domain_name
          }
        ]) : "${item.device_name}:${item.logical_name}" => item if item.logical_name != null 
    },
    {
      for item in flatten([
        for etherchannel_interface_key, etherchannel_interface_value in local.resource_etherchannel_interface : { 
            name          = etherchannel_interface_key
            device_name   = etherchannel_interface_value.device_name
            id            = fmc_device_etherchannel_interface.module[etherchannel_interface_key].id
            logical_name  = etherchannel_interface_value.logical_name
            domain_name   = etherchannel_interface_value.domain_name
          }
        ]) : "${item.device_name}:${item.logical_name}" => item if item.logical_name != null 
    }, 
    {
      for item in flatten([
        for etherchannel_interface_key, etherchannel_interface_value in local.data_etherchannel_interface : { 
            name          = etherchannel_interface_key
            device_name   = etherchannel_interface_value.device_name
            id            = data.fmc_device_etherchannel_interface.module[etherchannel_interface_key].id
            logical_name  = try(data.fmc_device_etherchannel_interface.module[etherchannel_interface_key].logical_name, null)
            domain_name   = etherchannel_interface_value.domain_name
          }
        ]) : "${item.device_name}:${item.logical_name}" => item if item.logical_name != null 
    },    
    {
      for item in flatten([
        for sub_interface_key, sub_interface_value in local.resource_sub_interface : { 
            name          = sub_interface_key
            device_name   = sub_interface_value.device_name
            id            = fmc_device_subinterface.module[sub_interface_key].id
            logical_name  = sub_interface_value.logical_name
            domain_name   = sub_interface_value.domain_name
          }
        ]) : "${item.device_name}:${item.logical_name}" => item if item.logical_name != null 
    }, 
    {
      for item in flatten([
        for sub_interface_key, sub_interface_value in local.data_sub_interface : { 
            name          = sub_interface_key
            device_name   = sub_interface_value.device_name
            id            = data.fmc_device_subinterface.module[sub_interface_key].id
            logical_name  = try(data.fmc_device_subinterface.module[sub_interface_key].logical_name, null)
            domain_name   = sub_interface_value.domain_name
          }
        ]) : "${item.device_name}:${item.logical_name}" => item if item.logical_name != null 
    },    
  )

}
