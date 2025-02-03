*** Settings ***
Documentation    Verify SGTs
Suite Setup      Login FMC
Default Tags     fmc    day1    config    sgts
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All SGTs - Domain Global
    ${SGTS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/securitygrouptags?
    Set Global Variable    ${SGTS}

Verify SGT - SGT_1
    Run Keyword If    'SGT_1' not in @{SGTS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${SGTS['SGT_1']}   $.name           SGT_1
    Should Be Equal Value Json String    ${SGTS['SGT_1']}   $.tag          123
    Should Be Equal Value Json String    ${SGTS['SGT_1']}   $.description    