*** Settings ***
Documentation    Verify timeranges
Suite Setup      Login FMC
Default Tags     fmc    day1    config    timeranges
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All Time Ranges - Domain Global
    ${TIMERANGES}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/timeranges?
    Set Global Variable    ${TIMERANGES}