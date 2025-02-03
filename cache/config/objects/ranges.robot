*** Settings ***
Documentation    Verify ranges
Suite Setup      Login FMC
Default Tags     fmc    day1    config    ranges
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All Ranges - Domain Global
    ${RANGES}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/ranges?
    Set Global Variable    ${RANGES}

Verify Range - Range_1
    Run Keyword If    'Range_1' not in @{RANGES}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${RANGES['Range_1']}   $.name           Range_1
    Should Be Equal Value Json String    ${RANGES['Range_1']}   $.value          1.1.1.1-1.1.1.2
    Should Be Equal Value Json String    ${RANGES['Range_1']}   $.description    

Verify Range - Range_2
    Run Keyword If    'Range_2' not in @{RANGES}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${RANGES['Range_2']}   $.name           Range_2
    Should Be Equal Value Json String    ${RANGES['Range_2']}   $.value          2.2.2.1-2.2.2.2
    Should Be Equal Value Json String    ${RANGES['Range_2']}   $.description    