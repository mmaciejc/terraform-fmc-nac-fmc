##########################################################
###    Content of the file:
##########################################################
#
###
#  Resources
####
# resource "fmc_access_control_policy" "access_control_policy" 
#
###  
#  Local variables
###
# local.resource_access_control_policy  => for building dynamic data source
# local.map_access_control_policy       => to collect all access control policies objects by name that can be used later in the module
#
###
##########################################################
###    Example of created local variables
##########################################################

#  + resource_access_control_policy = {
#      + MyAccessPolicyName1 = {
#          + categories                        = null
#          + default_action                    = "BLOCK"
#          + default_action_log_begin          = null
#          + default_action_log_end            = null
#          + default_action_send_events_to_fmc = null
#          + default_action_send_syslog        = null
#          + description                       = null
#          + domain_name                       = "Global"
#          + name                              = "MyAccessPolicyName1"
#          + rules                             = [
#              + {
#                  + action                       = "ALLOW"
#                  + category_name                = null
#                  + description                  = null
#                  + destination_network_literals = []
#                  + destination_network_objects  = []
#                  + name                         = "MyAccessRuleNAme1"
#                  + source_network_literals      = []
#                  + source_network_objects       = [
#                      + {
#                          + id   = "cb7116e8-66a6-480b-8f9b-295191a0940a"
#                          + type = "Network"
#                        },
#                    ]
#                },
#            ]
#        }
#    }

#  + map_access_control_policy  = {
#      + Dummy_ACP = {
#          + domain_name = "Global"
#          + id          = "005056B0-02BA-0ed3-0000-004294967348"
#          + name        = "Dummy_ACP"
#          + type        = null
#        }
#    }

##########################################################
###    Access Control Policy
##########################################################
locals {
  resource_access_control_policy = {
    for item in flatten([
      for domain in local.domains : [
        for item_value in try(domain.policies.access_policies, []) : [ 
          {
            name                                = item_value.name
            domain_name                         = domain.name
            description                         = try(item_value.description, null)
            default_action                      = try(item_value.default_action, local.defaults.fmc.domains.access_policies.default_action)
            default_action_log_begin            = try(item_value.log_begin, local.defaults.fmc.domains.access_policies.log_begin)
            default_action_log_end              = try(item_value.log_end, local.defaults.fmc.domains.access_policies.log_end)
            default_action_send_events_to_fmc   = try(item_value.send_events_to_fmc, local.defaults.fmc.domains.access_policies.send_events_to_fmc)
            default_action_send_syslog          = try(item_value.enable_syslog, local.defaults.fmc.domains.access_policies.enable_syslog)

            categories = try(item_value.categories, null)

            rules = [ for rule in try(item_value.access_rules, []) : {
                name = rule.name
                action = rule.action
                category_name = try(rule.category, null)
                description = try(rule.description, null)
                #intrusion_policy_id
                #send_events_to_fmc
                enabled = try(rule.enabled, local.defaults.fmc.domains.access_policies.access_rules.enabled)
                send_syslog = try(rule.enable_syslog, local.defaults.fmc.domains.access_policies.access_rules.enable_syslog)
                #log_begin
                #log_end
                #log_files
                #section = 
                source_zones = [ for source_zone in try(rule.source_zones, []) : {
                  id = try(local.map_security_zones[source_zone].id, null)
                }
                ]
                source_network_objects = [ for source_network_object in try(rule.source_network_objects, []) : {
                  id    = try(local.map_network_objects[source_network_object].id, local.map_network_group_objects[source_network_object].id, null)
                  type  = try(local.map_network_objects[source_network_object].type, local.map_network_group_objects[source_network_object].type, null)
                } 
                ]
                source_network_literals = [ for source_network_literal in try(rule.source_network_literals, []) : {
                  value = source_network_literal
                  type  = can(regex("/", source_network_literal)) ? "Network" : "Host"
                }
                ]
                destination_network_objects = [ for destination_network_object in try(rule.destination_network_objects, []) : {
                  id    = try(local.map_network_objects[destination_network_object].id, local.map_network_group_objects[destination_network_object].id, null)
                  type  = try(local.map_network_objects[destination_network_object].type, local.map_network_group_objects[destination_network_object].type, null)
                } 
                ]
                destination_zones = [ for destination_zone in try(rule.destination_zones, []) : {
                  id = try(local.map_security_zones[destination_zone].id, null)
                }
                ]
                destination_network_literals = [ for destination_network_literal in try(rule.destination_network_literals, []) : {
                  value = destination_network_literal
                  type  = can(regex("/", destination_network_literal)) ? "Network" : "Host"
                } 
                ]
                source_dynamic_objects = [ for source_dynamic_object in try(rule.source_dynamic_objects, []) : {
                  id    = try(local.map_dynamic_objects[source_dynamic_object].id, null)
                  type  = try(local.map_dynamic_objects[source_dynamic_object].type, null)
                } 
                ]
                destination_dynamic_objects = [ for destination_dynamic_object in try(rule.destination_dynamic_objects, []) : {
                  id    = try(local.map_dynamic_objects[destination_dynamic_object].id, null)
                  type  = try(local.map_dynamic_objects[destination_dynamic_object].type, null)
                } 
                ]  
                source_port_objects = [ for source_port_object in try(rule.source_port_objects, []) : {
                  id    = try(local.map_services[source_port_object].id, null)
                  type  = try(local.map_services[source_port_object].type, null)
                } 
                ]
                destination_port_objects = [ for destination_port_object in try(rule.destination_port_objects, []) : {
                  id    = try(local.map_services[destination_port_object].id, null)
                  type  = try(local.map_services[destination_port_object].type, null)
                } 
                ] 
              }
            ]
          }
        ]
      ]
      ]) : item.name => item if contains(keys(item), "name") && !contains(try(keys(local.data_access_control_policy), []), item.name)
  }
  
}

resource "fmc_access_control_policy" "access_control_policy" {
  for_each = local.resource_access_control_policy

  # Mandatory
  name = each.key
  
  # Optional
  #description                             = try(each.value.description, local.defaults.fmc.domains.access_policies.description, null)
  default_action                          = try(each.value.default_action, local.defaults.fmc.domains.access_policies.default_action, null)
  #default_action_base_intrusion_policy_id = try(local.map_ipspolicies[each.value.base_ips_policy].id, local.map_ipspolicies[local.defaults.fmc.domains.access_policies.base_ips_policy].id, null)
  default_action_send_events_to_fmc       = try(each.value.send_events_to_fmc, local.defaults.fmc.domains.access_policies.send_events_to_fmc, null)
  default_action_log_begin                = try(each.value.log_begin, local.defaults.fmc.domains.access_policies.log_begin, null)
  default_action_log_end                  = try(each.value.log_end, local.defaults.fmc.domains.access_policies.log_end, null)
  #default_action_syslog_config_id         = try(each.value.syslog_config_id, local.defaults.fmc.domains.access_policies.syslog_config_id, null)
  categories                              = each.value.categories
  rules                                   = each.value.rules

  depends_on = [ 
    data.fmc_security_zones.security_zones,
    fmc_security_zones.security_zones,
    data.fmc_hosts.hosts,
    fmc_hosts.hosts,
    data.fmc_networks.networks,
    fmc_networks.networks,
    data.fmc_ranges.ranges,
    fmc_ranges.ranges,
    fmc_network_groups.network_groups,
    data.fmc_dynamic_objects.dynamic_objects,
    fmc_dynamic_objects.dynamic_objects,
    data.fmc_ports.ports,
    fmc_ports.ports,
   ]  

  #lifecycle {
  #  replace_triggered_by = [
  #    fmc_hosts.hosts,
  #    fmc_networks.networks,
  #    fmc_ranges.ranges,
  #  ]
  #}

}

##########################################################
###    FTD NAT Policy
##########################################################
locals {
  resource_ftd_nat_policy = {
    for item in flatten([
      for domain in local.domains : [
        for item_value in try(domain.policies.ftd_nat_policies, []) : [ 
          {
            name                                = item_value.name
            domain_name                         = domain.name
            description                         = try(item_value.description, null)

            auto_nat_rules = [ for auto_rule in try(item_value.ftd_auto_nat_rules, []) : {
                nat_type                                      = auto_rule.nat_type              
                destination_interface_id                      = try(local.map_security_zones[auto_rule.destination_interface].id, null)
                fall_through                                  = try(auto_rule.fall_through, local.defaults.fmc.domains.ftd_nat_policies.ftd_auto_nat_rules.fall_through)
                ipv6                                          = try(auto_rule.ipv6, local.defaults.fmc.domains.ftd_nat_policies.ftd_auto_nat_rules.ipv6)
                net_to_net                                    = try(auto_rule.net_to_net, local.defaults.fmc.domains.ftd_nat_policies.ftd_auto_nat_rules.net_to_net)
                no_proxy_arp                                  = try(auto_rule.no_proxy_arp, local.defaults.fmc.domains.ftd_nat_policies.ftd_auto_nat_rules.no_proxy_arp)
                original_network_id                           = try(local.map_network_objects[auto_rule.original_network].id, local.map_network_group_objects[auto_rule.original_network].id, null)
                original_port                                 = try(auto_rule.original_port.port, null)
                protocol                                      = try(auto_rule.original_port.protocol, null)
                source_interface_id                           = try(local.map_security_zones[auto_rule.source_interface].id, null)
                translate_dns                                 = try(auto_rule.translate_dns, local.defaults.fmc.domains.ftd_nat_policies.ftd_auto_nat_rules.translate_dns)
                translated_network_id                         = try(local.map_network_objects[auto_rule.translated_network].id, local.map_network_group_objects[auto_rule.translated_network].id, null)
                translated_network_is_destination_interface   = try(auto_rule.translated_network_is_destination_interface, local.defaults.fmc.domains.ftd_nat_policies.ftd_auto_nat_rules.translated_network_is_destination_interface)
                translated_port                               = try(auto_rule.translated_port, null)
            }]
            manual_nat_rules = [ for manual_rule in try(item_value.ftd_manual_nat_rules, []) : {
              nat_type                          = manual_rule.nat_type
              section                           = upper(manual_rule.section)
              description                       = try(manual_rule.description, null)
              destination_interface_id          = try(local.map_security_zones[manual_rule.destination_interface].id, null)
              enabled                           = try(manual_rule.enabled, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.enabled)
              fall_through                      = try(manual_rule.fall_through, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.fall_through)
              interface_in_original_destination = try(manual_rule.interface_in_original_destination, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.interface_in_original_destination)
              interface_in_translated_source    = try(manual_rule.interface_in_translated_source, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.interface_in_translated_source)
              ipv6                              = try(manual_rule.ipv6, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.ipv6)
              net_to_net                        = try(manual_rule.net_to_net, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.net_to_net)
              no_proxy_arp                      = try(manual_rule.no_proxy_arp, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.no_proxy_arp)
              original_destination_id           = try(local.map_network_objects[manual_rule.original_destination].id, local.map_network_group_objects[manual_rule.original_destination].id, null)
              original_destination_port_id      = try(local.map_services[manual_rule.original_destination_port].id, local.map_service_groups[manual_rule.original_destination_port].id, null) 
              original_source_id                = try(local.map_network_objects[manual_rule.original_source].id, local.map_network_group_objects[manual_rule.original_source].id, null)
              original_source_port_id           = try(local.map_services[manual_rule.original_source_port].id, local.map_service_groups[manual_rule.original_source_port].id, null) 
              route_lookup                      = try(manual_rule.perform_route_lookup, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.perform_route_lookup)
              source_interface_id               = try(local.map_security_zones[manual_rule.source_interface].id, null)
              translate_dns                     = try(manual_rule.translate_dns, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.translate_dns)
              translated_destination_id         = try(local.map_network_objects[manual_rule.translated_destination].id, local.map_network_group_objects[manual_rule.translated_destination].id, null)
              translated_destination_port_id    = try(local.map_services[manual_rule.translated_destination_port].id, local.map_service_groups[manual_rule.translated_destination_port].id, null) 
              translated_source_id              = try(local.map_network_objects[manual_rule.translated_source].id, local.map_network_group_objects[manual_rule.translated_source].id, null)
              translated_source_port_id         = try(local.map_services[manual_rule.translated_source_port].id, local.map_service_groups[manual_rule.translated_source_port].id, null)  
              unidirectional                    = try(manual_rule.unidirectional, local.defaults.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.unidirectional)
            }]
          }]
      ]
    ]) : item.name => item if contains(keys(item), "name") && !contains(try(keys(local.data_ftd_nat_policy), []), item.name)
  }

}

resource "fmc_ftd_nat_policy" "ftd_nat_policy" {
  for_each = local.resource_ftd_nat_policy

  # Mandatory
  name = each.key

  # Optional
  description       = each.value.description
  manual_nat_rules  = each.value.manual_nat_rules
  auto_nat_rules    = each.value.auto_nat_rules
}
            


##########################################################
###    Create maps for combined set of _data and _resources network objects 
##########################################################

######
### map_access_control_policy 
######
locals {
  map_access_control_policy = merge({
      for item in flatten([
        for item_key, item_value in local.resource_access_control_policy : { 
          name = item_key
          id   = try(fmc_access_control_policy.access_control_policy[item_key].id, null)
          type = try(fmc_access_control_policy.access_control_policy[item_key].type, null)
          domain_name = item_value.domain_name
        }
      ]) : item.name => item if contains(keys(item), "name" )
    }, 
    {
      for item in flatten([
        for item_key, item_value in local.data_access_control_policy : { 
          name = item_key
          id   = try(data.fmc_access_control_policy.access_control_policy[item_key].id, null)
          type = try(data.fmc_access_control_policy.access_control_policy[item_key].type, null)
          domain_name = item_value.domain_name
        }
      ]) : item.name => item if contains(keys(item), "name" )
    }, 
  )
}