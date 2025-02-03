*** Settings ***
Documentation    Verify IPS policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    ipspolicies
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All IPS Policies - Domain Global
    ${IPSPolicies}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/policy/intrusionpolicies?
    Set Global Variable    ${IPSPolicies}