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
  help_protocol_mapping = {
    "TCP"   = "6",
    "UDP"   = "17",
    "ICMP"  = "1"
  }

  resource_access_control_policy = {
    for item in flatten([
      for domain in local.domains : [
        for item_value in try(domain.policies.access_policies, []) : [ 
          {
            name                                = item_value.name
            default_action                      = try(item_value.default_action, local.defaults.fmc.domains.policies.access_policies.default_action)
            
            categories                          = [ for category in try(item_value.categories, []) : {
              name          = category.name
              section       = try(category.section, null)
            } ]

            default_action_intrusion_policy_id  = try(local.map_intrusion_policy[item_value.base_intrusion_policy].id, local.map_intrusion_policy[local.defaults.fmc.domains.policies.access_policies.base_intrusion_policy].id, null)
            default_action_log_begin            = try(item_value.log_begin, local.defaults.fmc.domains.policies.access_policies.log_begin, null)
            default_action_log_end              = try(item_value.log_end, local.defaults.fmc.domains.policies.access_policies.log_end, null)
            default_action_send_events_to_fmc   = try(item_value.send_events_to_fmc, local.defaults.fmc.domains.policies.access_policies.send_events_to_fmc, null)
            default_action_send_syslog          = try(item_value.enable_syslog, local.defaults.fmc.domains.policies.access_policies.enable_syslog, null)
            
            default_action_snmp_config_id       = null # snmp_alert
            default_action_syslog_config_id     = null # syslog_alert
            default_action_syslog_severity      = try(item_value.syslog_severity, local.defaults.fmc.domains.policies.access_policies.syslog_severity, null)

            description                         = try(item_value.description, null)
            domain_name                         = domain.name


            rules = [ for rule in try(item_value.access_rules, []) : {
                name                    = rule.name
                action                  = rule.action
                category_name           = try(rule.category, null)
                description             = try(rule.description, null)

                destination_dynamic_objects = [ for destination_dynamic_object in try(rule.destination_dynamic_objects, []) : {
                  id    = local.map_dynamic_objects[destination_dynamic_object].id
                  type  = local.map_dynamic_objects[destination_dynamic_object].type
                } ] 
                destination_network_literals = [ for destination_network_literal in try(rule.destination_network_literals, []) : {
                  value = destination_network_literal
                  type  = can(regex("/", destination_network_literal)) ? "Network" : "Host"
                } ]
                destination_network_objects = [ for destination_network_object in try(rule.destination_network_objects, []) : {
                  id    = try(local.map_network_objects[destination_network_object].id, local.map_network_group_objects[destination_network_object].id)
                  type  = try(local.map_network_objects[destination_network_object].type, local.map_network_group_objects[destination_network_object].type)
                } ]
                destination_port_literals = [ for destination_port_literal in try(rule.destination_port_literals, []) : {
                  protocol   = local.help_protocol_mapping[destination_port_literal.protocol]
                  port       = try(destination_port_literal.port, null)
                  icmp_type   = try(destination_port_literal.icmp_type, null)
                  icmp_code   = try(destination_port_literal.icmp_code, null)
                } ]                 
                destination_port_objects = [ for destination_port_object in try(rule.destination_port_objects, []) : {
                  id    = local.map_services[destination_port_object].id
                  type  = local.map_services[destination_port_object].type
                } ]
                destination_zones = [ for destination_zone in try(rule.destination_zones, []) : {
                  id = local.map_security_zones[destination_zone].id
                } ]

                enabled               = try(rule.enabled, local.defaults.fmc.domains.policies.access_policies.access_rules.enabled, null)
                file_policy_id        = null #file_policy
                intrusion_policy_id  = try(local.map_intrusion_policy[rule.intrusion_policy].id, local.defaults.fmc.domains.policies.access_policies.access_rules.intrusion_policy, null)
                log_begin             = try(rule.log_connection_begin, local.defaults.fmc.domains.policies.access_policies.access_rules.log_connection_begin, null)
                log_end               = try(rule.log_connection_end, local.defaults.fmc.domains.policies.access_policies.access_rules.log_connection_end, null)
                log_files             = try(rule.log_files, local.defaults.fmc.domains.policies.access_policies.access_rules.log_files, null)
                section               = try(rule.section, local.defaults.fmc.domains.policies.access_policies.access_rules.section, null)
                send_events_to_fmc    = try(rule.send_events_to_fmc, local.defaults.fmc.domains.policies.access_policies.access_rules.send_events_to_fmc, null)
                send_syslog           = try(rule.enable_syslog, local.defaults.fmc.domains.policies.access_policies.access_rules.enable_syslog, null)
                snmp_config_id        = null #snmp_alert
                source_dynamic_objects = [ for source_dynamic_object in try(rule.source_dynamic_objects, []) : {
                  id    = local.map_dynamic_objects[source_dynamic_object].id
                  type  = local.map_dynamic_objects[source_dynamic_object].type
                } ]
                source_network_literals = [ for source_network_literal in try(rule.source_network_literals, []) : {
                  value = source_network_literal
                  type  = can(regex("/", source_network_literal)) ? "Network" : "Host"
                } ]
                source_network_objects = [ for source_network_object in try(rule.source_network_objects, []) : {
                  id    = try(local.map_network_objects[source_network_object].id, local.map_network_group_objects[source_network_object].id, null)
                  type  = try(local.map_network_objects[source_network_object].type, local.map_network_group_objects[source_network_object].type, null)
                } ]
                source_port_literals = [ for source_port_literal in try(rule.source_port_literals, []) : {
                  protocol   = local.help_protocol_mapping[source_port_literal.protocol]
                  port       = try(source_port_literal.port, null)
                  icmp_type   = try(source_port_literal.icmp_type, null)
                  icmp_code   = try(source_port_literal.icmp_code, null)
                } ]                  
                source_port_objects = [ for source_port_object in try(rule.source_port_objects, []) : {
                  id    = local.map_services[source_port_object].id
                  type  = local.map_services[source_port_object].type
                } ] 
                source_zones = [ for source_zone in try(rule.source_zones, []) : {
                  id = local.map_security_zones[source_zone].id
                } ]
                #source_sgt_objects = [ for source_sgt in try(rule.source_sgts, []) : {
                #  id = local.map_sgts[source_sgt].id
                #} ]
                syslog_config_id = null #syslog_alert
                syslog_severity      = try(item_value.syslog_severity, local.defaults.fmc.domains.policies.access_policies.syslog_severity, null)
                url_categories = [ for url_category in try(rule.url_categories, []) : {
                  id          = try(local.map_url_categories[url_category.category].id) 
                  reputation  = try(url_category.reputation, null)
                } ]
                url_objects = [ for url_object in try(rule.url_objects, []) : {
                  id = try(local.map_urls[url_object].id, local.map_url_groups[url_object].id)
                } ]
                variable_set_id    = try(local.map_variable_sets[rule.variable_set].id, null)
                vlan_tag_literals = [ for vlan_tag_literal in try(rule.vlan_tag_literals, []) : {
                  start_tag = vlan_tag_literal.start_tag
                  end_tag   = try(vlan_tag_literal.end_tag, vlan_tag_literal.start_tag)                  
                } ]
                vlan_tag_objects  = [ for vlan_tag_object in try(rule.vlan_tag_objects, []) : {
                  id = try(local.map_vlan_tags[vlan_tag_object].id, local.map_vlan_tag_groups[vlan_tag_object].id)
                } ]
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
  name                                    = each.key
  default_action                          = each.value.default_action
  
  # Optional
  default_action_intrusion_policy_id      = each.value.default_action_intrusion_policy_id
  default_action_log_begin                = each.value.default_action_log_begin
  default_action_log_end                  = each.value.default_action_log_end
  default_action_send_events_to_fmc       = each.value.default_action_send_events_to_fmc
  default_action_send_syslog              = each.value.default_action_send_syslog
  default_action_snmp_config_id           = each.value.default_action_snmp_config_id
  default_action_syslog_config_id         = each.value.default_action_syslog_config_id
  default_action_syslog_severity          = each.value.default_action_syslog_severity
  description                             = each.value.description

  categories                              = each.value.categories
  rules                                   = each.value.rules

  domain                                  = each.value.domain_name

  depends_on = [ 
    data.fmc_security_zones.module,
    fmc_security_zones.module,
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
    data.fmc_intrusion_policy.intrusion_policy,
    fmc_intrusion_policy.intrusion_policy,
   ]  

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
            description                         = try(item_value.description, null)
            domain_name                         = domain.name

            auto_nat_rules = [ for auto_rule in try(item_value.ftd_auto_nat_rules, []) : {
                # Mandatory
                nat_type                                      = auto_rule.nat_type     
                # Optional         
                destination_interface_id                      = try(local.map_security_zones[auto_rule.destination_interface].id, null)
                fall_through                                  = try(auto_rule.fall_through, local.defaults.fmc.domains.policies.ftd_nat_policies.ftd_auto_nat_rules.fall_through, null)
                ipv6                                          = try(auto_rule.ipv6, local.defaults.fmc.domains.policies.ftd_nat_policies.ftd_auto_nat_rules.ipv6, null)
                net_to_net                                    = try(auto_rule.net_to_net, local.defaults.fmc.domains.policies.ftd_nat_policies.ftd_auto_nat_rules.net_to_net, null)
                no_proxy_arp                                  = try(auto_rule.no_proxy_arp, local.defaults.fmc.domains.policies.ftd_nat_policies.ftd_auto_nat_rules.no_proxy_arp, null)
                original_network_id                           = try(local.map_network_objects[auto_rule.original_network].id, local.map_network_group_objects[auto_rule.original_network].id, null)
                original_port                                 = try(auto_rule.original_port, null)
                route_lookup                                  = try(auto_rule.perform_route_lookup, local.defaults.fmc.domains.policies.ftd_nat_policies.ftd_manual_nat_rules.perform_route_lookup, null)
                protocol                                      = try(auto_rule.protocol, null)
                source_interface_id                           = try(local.map_security_zones[auto_rule.source_interface].id, null)
                translate_dns                                 = try(auto_rule.translate_dns, local.defaults.fmc.domains.policies.ftd_nat_policies.ftd_auto_nat_rules.translate_dns, null)
                translated_network_id                         = try(local.map_network_objects[auto_rule.translated_network].id, local.map_network_group_objects[auto_rule.translated_network].id, null)
                translated_network_is_destination_interface   = try(auto_rule.translated_network_is_destination_interface, local.defaults.fmc.domains.policies.ftd_nat_policies.ftd_auto_nat_rules.translated_network_is_destination_interface, null)
                translated_port                               = try(auto_rule.translated_port, null)
            }]

            manual_nat_rules = [ for manual_rule in try(item_value.ftd_manual_nat_rules, []) : {
              # Mandatory
              nat_type                          = manual_rule.nat_type
              section                           = upper(manual_rule.section)
              # Optional
              description                       = try(manual_rule.description, null)
              destination_interface_id          = try(local.map_security_zones[manual_rule.destination_interface].id, null)
              enabled                           = try(manual_rule.enabled, local.defaults.fmc.domains.policies.ftd_nat_policies.ftd_manual_nat_rules.enabled, null)
              fall_through                      = try(manual_rule.fall_through, local.defaults.fmc.domains.policies.ftd_nat_policies.ftd_manual_nat_rules.fall_through, null)
              interface_in_original_destination = try(manual_rule.interface_in_original_destination, local.defaults.policies.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.interface_in_original_destination, null)
              interface_in_translated_source    = try(manual_rule.interface_in_translated_source, local.defaults.policies.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.interface_in_translated_source, null)
              ipv6                              = try(manual_rule.ipv6, local.defaults.policies.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.ipv6, null)
              net_to_net                        = try(manual_rule.net_to_net, local.defaults.policies.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.net_to_net, null)
              no_proxy_arp                      = try(manual_rule.no_proxy_arp, local.defaults.policies.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.no_proxy_arp, null)
              original_destination_id           = try(local.map_network_objects[manual_rule.original_destination].id, local.map_network_group_objects[manual_rule.original_destination].id, null)
              original_destination_port_id      = try(local.map_services[manual_rule.original_destination_port].id, local.map_service_groups[manual_rule.original_destination_port].id, null) 
              original_source_id                = try(local.map_network_objects[manual_rule.original_source].id, local.map_network_group_objects[manual_rule.original_source].id, null)
              original_source_port_id           = try(local.map_services[manual_rule.original_source_port].id, local.map_service_groups[manual_rule.original_source_port].id, null) 
              route_lookup                      = try(manual_rule.perform_route_lookup, local.defaults.policies.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.perform_route_lookup, null)
              source_interface_id               = try(local.map_security_zones[manual_rule.source_interface].id, null)
              translate_dns                     = try(manual_rule.translate_dns, local.defaults.policies.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.translate_dns, null)
              translated_destination_id         = try(local.map_network_objects[manual_rule.translated_destination].id, local.map_network_group_objects[manual_rule.translated_destination].id, null)
              translated_destination_port_id    = try(local.map_services[manual_rule.translated_destination_port].id, local.map_service_groups[manual_rule.translated_destination_port].id, null) 
              translated_source_id              = try(local.map_network_objects[manual_rule.translated_source].id, local.map_network_group_objects[manual_rule.translated_source].id, null)
              translated_source_port_id         = try(local.map_services[manual_rule.translated_source_port].id, local.map_service_groups[manual_rule.translated_source_port].id, null)  
              unidirectional                    = try(manual_rule.unidirectional, local.defaults.policies.fmc.domains.ftd_nat_policies.ftd_manual_nat_rules.unidirectional, null)
            }]
          }]
      ]
    ]) : item.name => item if contains(keys(item), "name") && !contains(try(keys(local.data_ftd_nat_policy), []), item.name)
  }

}

resource "fmc_ftd_nat_policy" "ftd_nat_policy" {
  for_each = local.resource_ftd_nat_policy

  # Mandatory
  name              = each.key

  # Optional
  description       = each.value.description
  manual_nat_rules  = each.value.manual_nat_rules
  auto_nat_rules    = each.value.auto_nat_rules

  domain            = try(each.value.domain_name, null)

  depends_on = [ 
    data.fmc_security_zones.module,
    fmc_security_zones.module,
    data.fmc_hosts.hosts,
    fmc_hosts.hosts,
    data.fmc_networks.networks,
    fmc_networks.networks,
    data.fmc_ranges.ranges,
    fmc_ranges.ranges,
    fmc_network_groups.network_groups,
    data.fmc_ports.ports,
    fmc_ports.ports,
   ]    
}
            
##########################################################
###    Intrusion Policy (IPS)
##########################################################
locals {
  resource_intrusion_policy = {
    for item in flatten([
      for domain in local.domains : [
        for item_value in try(domain.policies.intrusion_policies, []) : [ 
          {
            name                      = item_value.name
            domain_name               = domain.name
            description               = try(item_value.description, null)
            base_policy_id            = try(data.fmc_intrusion_policy.intrusion_policy[item_value.base_policy].id, null)
            inspection_mode           = try(item_value.inspection_mode, null)
          }]
      ]
    ]) : item.name => item if contains(keys(item), "name") && !contains(try(keys(local.data_intrusion_policy), []), item.name)
  }

}

resource "fmc_intrusion_policy" "intrusion_policy" {
  for_each = local.resource_intrusion_policy
    
    # Mandatory
    name              = each.key
    base_policy_id    = each.value.base_policy_id

    # Optional
    description       = each.value.description
    inspection_mode   = each.value.inspection_mode

    domain            = try(each.value.domain_name, null)

  depends_on = [ 
    data.fmc_intrusion_policy.intrusion_policy,
   ]      
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

######
### map_ftd_nat_policy 
######
locals {
  map_ftd_nat_policy = merge({
      for item in flatten([
        for item_key, item_value in local.resource_ftd_nat_policy : { 
          name = item_key
          id   = try(fmc_ftd_nat_policy.ftd_nat_policy[item_key].id, null)
          type = try(fmc_ftd_nat_policy.ftd_nat_policy[item_key].type, null)
          domain_name = item_value.domain_name
        }
      ]) : item.name => item if contains(keys(item), "name" )
    }, 
    {
      for item in flatten([
        for item_key, item_value in local.data_ftd_nat_policy : { 
          name = item_key
          id   = try(data.fmc_ftd_nat_policy.ftd_nat_policy[item_key].id, null)
          type = try(data.fmc_ftd_nat_policy.ftd_nat_policy[item_key].type, null)
          domain_name = item_value.domain_name
        }
      ]) : item.name => item if contains(keys(item), "name" )
    }, 
  )
}

######
### map_intrusion_policy 
######
locals {
  map_intrusion_policy = merge({
      for item in flatten([
        for item_key, item_value in local.resource_intrusion_policy : { 
          name = item_key
          id   = try(fmc_intrusion_policy.intrusion_policy[item_key].id, null)
          type = try(fmc_intrusion_policy.intrusion_policy[item_key].type, null)
          domain_name = item_value.domain_name
        }
      ]) : item.name => item if contains(keys(item), "name" )
    }, 
    {
      for item in flatten([
        for item_key, item_value in local.data_intrusion_policy : { 
          name = item_key
          id   = try(data.fmc_intrusion_policy.intrusion_policy[item_key].id, null)
          type = try(data.fmc_intrusion_policy.intrusion_policy[item_key].type, null)
          domain_name = item_value.domain_name
        }
      ]) : item.name => item if contains(keys(item), "name" )
    }, 
  )
}