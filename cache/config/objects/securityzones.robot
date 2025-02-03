*** Settings ***
Documentation    Verify securityzones
Suite Setup      Login FMC
Default Tags     fmc    day1    config    securityzones
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All SecurityZones - Domain Global
    ${SECURITYZONES}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/securityzones?
    Set Global Variable    ${SECURITYZONES}