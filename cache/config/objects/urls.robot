*** Settings ***
Documentation    Verify URL
Suite Setup      Login FMC
Default Tags     fmc    day1    config    urls
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All URLs - Domain Global
    ${URLS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/urls?
    Set Global Variable    ${URLS}

Verify URL - URL_1
    Run Keyword If    'URL_1' not in @{URLS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${URLS['URL_1']}   $.name           URL_1
    Should Be Equal Value Json String    ${URLS['URL_1']}   $.url          http://10.62.158.113:8080
    Should Be Equal Value Json String    ${URLS['URL_1']}   $.description    

Verify URL - URL_2
    Run Keyword If    'URL_2' not in @{URLS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${URLS['URL_2']}   $.name           URL_2
    Should Be Equal Value Json String    ${URLS['URL_2']}   $.url          http://10.62.158.111:8080
    Should Be Equal Value Json String    ${URLS['URL_2']}   $.description    