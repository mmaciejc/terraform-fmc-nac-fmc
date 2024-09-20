##########################################################
###    Content of the file:
##########################################################
#
###
#  Principles
####
# FMC uses references based on ID, which means that any object used in the configuration needs to be created first/or exists on FMC
# It implies the condition that resources need to be created/modified in the correct order
# Module uses a new terraform provider for FMC
# Module is built for multidomain support
# Module is built for easy bulk operations support
#
###  
#  Local variables
###
# local.fmc           => map of FMC configuration loaded from YAML file
# local.domains       => map of domain configuration 
# local.data_existing => map of existing objects configuration loaded from YAML file (should reflect builtin/read-only objects like SSH, HTTP etc.)
#
###


locals {
  fmc           = try(local.model.fmc, {})
  domains       = try(local.fmc.domains, {})
  data_existing = try(local.model.existing, {})

}