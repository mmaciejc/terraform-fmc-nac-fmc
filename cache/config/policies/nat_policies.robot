*** Settings ***
Documentation    Verify MAT policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    natpolicies
Resource    ../../fmc_common.resource

*** Test Cases ***

Get Nat Policies
    ${nat_policies}=    Get All Objects By Name    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/policy/ftdnatpolicies?
    Set Global Variable    ${nat_policies}