*** Settings ***
Documentation    Verify networks
Suite Setup      Login FMC
Default Tags     fmc    day1    config    networks
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All Networks - Domain Global
    ${NETWORKS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/networks?
    Set Global Variable    ${NETWORKS}

Verify Network - LAN_1
    Run Keyword If    'LAN_1' not in @{NETWORKS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKS['LAN_1']}   $.name           LAN_1
    Should Be Equal Value Json String    ${NETWORKS['LAN_1']}   $.value          10.1.0.0/24
    Should Be Equal Value Json String    ${NETWORKS['LAN_1']}   $.description    

Verify Network - LAN_2
    Run Keyword If    'LAN_2' not in @{NETWORKS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKS['LAN_2']}   $.name           LAN_2
    Should Be Equal Value Json String    ${NETWORKS['LAN_2']}   $.value          10.1.1.0/24
    Should Be Equal Value Json String    ${NETWORKS['LAN_2']}   $.description    

Verify Network - LAN_3
    Run Keyword If    'LAN_3' not in @{NETWORKS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKS['LAN_3']}   $.name           LAN_3
    Should Be Equal Value Json String    ${NETWORKS['LAN_3']}   $.value          10.2.0.0/24
    Should Be Equal Value Json String    ${NETWORKS['LAN_3']}   $.description    

Verify Network - WAN_1
    Run Keyword If    'WAN_1' not in @{NETWORKS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKS['WAN_1']}   $.name           WAN_1
    Should Be Equal Value Json String    ${NETWORKS['WAN_1']}   $.value          172.0.0.0/8
    Should Be Equal Value Json String    ${NETWORKS['WAN_1']}   $.description    

Verify Network - WAN_2
    Run Keyword If    'WAN_2' not in @{NETWORKS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKS['WAN_2']}   $.name           WAN_2
    Should Be Equal Value Json String    ${NETWORKS['WAN_2']}   $.value          172.17.0.0/16
    Should Be Equal Value Json String    ${NETWORKS['WAN_2']}   $.description    