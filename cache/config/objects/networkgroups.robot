*** Settings ***
Documentation    Verify network groups
Suite Setup      Login FMC
Default Tags     fmc    day1    config    networkgroups
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All Network Groups - Domain Global
    ${NETWORKGROUPS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/networkgroups?
    Set Global Variable    ${NETWORKGROUPS}

Verify Network Group - DC_1
    Run Keyword If    'DC_1' not in @{NETWORKGROUPS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKGROUPS['DC_1']}   $.name           DC_1
    Should Be Equal Value Json String    ${NETWORKGROUPS['DC_1']}   $.description    
    Should Be Equal Value Json List Of Dictionaries    ${NETWORKGROUPS['DC_1']}    $.objects     name      ['LAN_1', 'LAN_2', 'Range_1']

Verify Network Group - DC_2
    Run Keyword If    'DC_2' not in @{NETWORKGROUPS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKGROUPS['DC_2']}   $.name           DC_2
    Should Be Equal Value Json String    ${NETWORKGROUPS['DC_2']}   $.description    
    Should Be Equal Value Json List Of Dictionaries    ${NETWORKGROUPS['DC_2']}    $.objects     name      ['WAN_1', 'DC_1', 'Range_2']
    Should Be Equal Value Json List Of Dictionaries    ${NETWORKGROUPS['DC_2']}    $.literals    value     ['10.0.0.0/24']

Verify Network Group - Site_1
    Run Keyword If    'Site_1' not in @{NETWORKGROUPS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKGROUPS['Site_1']}   $.name           Site_1
    Should Be Equal Value Json String    ${NETWORKGROUPS['Site_1']}   $.description    
    Should Be Equal Value Json List Of Dictionaries    ${NETWORKGROUPS['Site_1']}    $.objects     name      ['WAN_1', 'Host_1', 'DC_2']

Verify Network Group - Site_2
    Run Keyword If    'Site_2' not in @{NETWORKGROUPS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKGROUPS['Site_2']}   $.name           Site_2
    Should Be Equal Value Json String    ${NETWORKGROUPS['Site_2']}   $.description    
    Should Be Equal Value Json List Of Dictionaries    ${NETWORKGROUPS['Site_2']}    $.objects     name      ['WAN_2']

Verify Network Group - RCH
    Run Keyword If    'RCH' not in @{NETWORKGROUPS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKGROUPS['RCH']}   $.name           RCH
    Should Be Equal Value Json String    ${NETWORKGROUPS['RCH']}   $.description    
    Should Be Equal Value Json List Of Dictionaries    ${NETWORKGROUPS['RCH']}    $.objects     name      ['DC_1', 'DC_2']