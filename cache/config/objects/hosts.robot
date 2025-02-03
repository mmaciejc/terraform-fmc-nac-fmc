*** Settings ***
Documentation    Verify hosts
Suite Setup      Login FMC
Default Tags     fmc    day1    config    hosts
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All Hosts - Domain Global
    ${HOSTS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/hosts?
    Set Global Variable    ${HOSTS}

Verify Host - Host_1
    Run Keyword If    'Host_1' not in @{HOSTS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${HOSTS['Host_1']}   $.name           Host_1
    Should Be Equal Value Json String    ${HOSTS['Host_1']}   $.value          192.168.0.13
    Should Be Equal Value Json String    ${HOSTS['Host_1']}   $.description    