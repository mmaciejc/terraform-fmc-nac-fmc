###
# ACCESS POLICY
###
locals {
  res_accesspolicies = flatten([
    for domain in local.domains : [
      for object in try(domain.access_policies, {}) :
      {
        name                              = object.name
        domain                            = domain.name
        description                       = try(object.description, null)
        default_action                    = try(object.default_action, local.defaults.fmc.domains.access_policies.default_action)
        default_action_log_begin          = try(object.default_action_log_begin, null)
        default_action_log_end            = try(object.default_action_log_end, null)
        default_action_send_events_to_fmc = try(object.default_action_send_events_to_fmc, null)
        default_action_send_syslog        = try(object.default_action_send_syslog, null)

        categories = try(object.categories, null)

        rules = [for rule in try(object.access_rules, []) : {
          name          = rule.name
          action        = rule.action
          category_name = try(rule.category, null)
          description   = try(rule.description, null)
          #intrusion_policy_id
          #send_events_to_fmc
          #log_begin
          #log_end
          #log_files
          #section = 
          source_network_objects = [for source_network in try(rule.source_networks, []) : {
            id   = try(local.map_networkobjects[source_network].id, null)
            type = try(local.map_networkobjects[source_network].type, null)
            #test = length(try(split(".", source_network), null))
            } if length(try(split(".", source_network), null)) == 1
          ]
          source_network_literals = [for source_network in try(rule.source_networks, []) : {
            value = source_network
            type  = can(regex("/", source_network)) ? "Network" : "Host"
            #test = length(try(split(".", source_network), null))
            } if length(try(split(".", source_network), null)) == 4
          ]
          destination_network_objects = [for destination_network in try(rule.destination_networks, []) : {
            id   = local.map_networkobjects[destination_network].id
            type = local.map_networkobjects[destination_network].type
            } if length(try(split(".", destination_network), null)) == 1
          ]
          destination_network_literals = [for destination_network in try(rule.destination_networks, []) : {
            value = destination_network
            type  = can(regex("/", destination_network)) ? "Network" : "Host"
            #test = length(try(split(".", source_network), null))
            } if length(try(split(".", destination_network), null)) == 4
          ]
          #can(regex("/", literals.value)) ? "Network" : "Host"
          }
        ]

      } if !contains(local.data_accesspolicies, object.name)
    ]
  ])
}

resource "fmc_access_control_policy" "accesspolicy" {
  for_each = { for accesspolicy in local.res_accesspolicies : accesspolicy.name => accesspolicy }

  # Mandatory
  name = each.value.name

  # Optional
  #description                             = try(each.value.description, local.defaults.fmc.domains.access_policies.description, null)
  default_action = try(each.value.default_action, local.defaults.fmc.domains.access_policies.default_action, null)
  #default_action_base_intrusion_policy_id = try(local.map_ipspolicies[each.value.base_ips_policy].id, local.map_ipspolicies[local.defaults.fmc.domains.access_policies.base_ips_policy].id, null)
  default_action_send_events_to_fmc = try(each.value.send_events_to_fmc, local.defaults.fmc.domains.access_policies.send_events_to_fmc, null)
  default_action_log_begin          = try(each.value.log_begin, local.defaults.fmc.domains.access_policies.log_begin, null)
  default_action_log_end            = try(each.value.log_end, local.defaults.fmc.domains.access_policies.log_end, null)
  #default_action_syslog_config_id         = try(each.value.syslog_config_id, local.defaults.fmc.domains.access_policies.syslog_config_id, null)
  categories = each.value.categories
  rules      = each.value.rules

}

