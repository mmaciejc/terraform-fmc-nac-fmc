*** Settings ***
Documentation    Verify Prefilter policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    prefilterpolicy
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All Prefilter Policies - Domain Global
    ${PreFilterPolicies}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/policy/prefilterpolicies?
    Set Global Variable    ${PreFilterPolicies}