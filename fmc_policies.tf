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
###    HOST
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
            default_action_log_begin            = try(item_value.default_action_log_begin, null)
            default_action_log_end              = try(item_value.default_action_log_end, null)
            default_action_send_events_to_fmc   = try(item_value.default_action_send_events_to_fmc, null)
            default_action_send_syslog          = try(item_value.default_action_send_syslog, null)

            categories = try(item_value.categories, null)

            rules = [ for rule in try(item_value.access_rules, []) : {
                name = rule.name
                action = rule.action
                category_name = try(rule.category, null)
                description = try(rule.description, null)
                #intrusion_policy_id
                #send_events_to_fmc
                #log_begin
                #log_end
                #log_files
                #section = 
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
                destination_network_literals = [ for destination_network_literal in try(rule.destination_network_literals, []) : {
                  value = destination_network_literal
                  type  = can(regex("/", destination_network_literal)) ? "Network" : "Host"
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