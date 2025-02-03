*** Settings ***
Documentation    Verify Network Analysis policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    networkanalysispolicies
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All NetAnalysis Policies - Domain Global
    ${NAPolicies}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/policy/networkanalysispolicies?
    Set Global Variable    ${NAPolicies}