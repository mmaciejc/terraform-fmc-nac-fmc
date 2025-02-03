*** Settings ***
Documentation    Verify File policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    filepolicies
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All File Policies - Domain Global
    ${FilePolicies}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/policy/filepolicies?
    Set Global Variable    ${FilePolicies}