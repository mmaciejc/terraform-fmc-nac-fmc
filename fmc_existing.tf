###
# Define terraform data representation of objects that already exist on FMC
###

locals {
  data_smart_license             = contains(keys(try(local.data_existing.fmc.system, {})), "smart_license") ? [local.data_existing.fmc.system.smart_license] : []
  data_syslog_alerts             = [for obj in try(local.data_existing.fmc.system.syslog_alerts, []) : obj.name]
  data_devices                   = [for obj in try(local.data_existing.fmc.domains[0].devices.devices, []) : obj.name]
  data_clusters                  = [for obj in try(local.data_existing.fmc.domains[0].devices.clusters, []) : obj.name]
  data_accesspolicies            = [for obj in try(local.data_existing.fmc.domains[0].policies.access_policies, []) : obj.name]
  data_ftdnatpolicies            = [for obj in try(local.data_existing.fmc.domains[0].policies.ftd_nat_policies, []) : obj.name]
  data_ipspolicies               = [for obj in try(local.data_existing.fmc.domains[0].policies.ips_policies, []) : obj.name]
  data_filepolicies              = [for obj in try(local.data_existing.fmc.domains[0].policies.file_policies, []) : obj.name]
  data_network_analysis_policies = [for obj in try(local.data_existing.fmc.domains[0].network_analysis_policies, []) : obj.name]
  data_hosts                     = [for obj in try(local.data_existing.fmc.domains[0].objects.hosts, []) : obj.name]
  data_networks                  = [for obj in try(local.data_existing.fmc.domains[0].objects.networks, []) : obj.name]
  #data_ranges                    = []
  data_networkgroups = [for obj in try(local.data_existing.fmc.domains[0].objects.network_groups, []) : obj.name]
  data_ports         = [for obj in try(local.data_existing.fmc.domains[0].objects.ports, []) : obj.name]
  data_portgroups    = [for obj in try(local.data_existing.fmc.domains[0].objects.port_groups, []) : obj.name]
  #data_icmpv_4s                  = []
  data_securityzones         = [for obj in try(local.data_existing.fmc.domains[0].objects.security_zones, []) : obj.name]
  data_urls                  = [for obj in try(local.data_existing.fmc.domains[0].objects.urls, []) : obj.name]
  data_sgts                  = [for obj in try(local.data_existing.fmc.domains[0].objects.sgts, []) : obj.name]
  data_dynamicobjects        = [for obj in try(local.data_existing.fmc.domains[0].objects.dynamic_objects, []) : obj.name]
  data_time_ranges           = [for obj in try(local.data_existing.fmc.domains[0].objects.time_ranges, []) : obj.name]
  data_standard_access_lists = [for obj in try(local.data_existing.fmc.domains[0].objects.standard_access_lists, []) : obj.name]
  data_extended_access_lists = [for obj in try(local.data_existing.fmc.domains[0].objects.extended_access_lists, []) : obj.name]



}
