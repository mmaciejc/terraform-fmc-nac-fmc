*** Settings ***
Documentation    Verify fqdns
Suite Setup      Login FMC
Default Tags     fmc    day1    config    fqdns
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All FQDNs - Domain Global
    ${FQDNS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/fqdns?
    Set Global Variable    ${FQDNS}

Verify FQDN - FQDN_1
    Run Keyword If    'FQDN_1' not in @{FQDNS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${FQDNS['FQDN_1']}   $.name           FQDN_1
    Should Be Equal Value Json String    ${FQDNS['FQDN_1']}   $.value          
    Should Be Equal Value Json String    ${FQDNS['FQDN_1']}   $.dnsResolution          
    Should Be Equal Value Json String    ${FQDNS['FQDN_1']}   $.description    

Verify FQDN - FQDN_2
    Run Keyword If    'FQDN_2' not in @{FQDNS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${FQDNS['FQDN_2']}   $.name           FQDN_2
    Should Be Equal Value Json String    ${FQDNS['FQDN_2']}   $.value          
    Should Be Equal Value Json String    ${FQDNS['FQDN_2']}   $.dnsResolution          
    Should Be Equal Value Json String    ${FQDNS['FQDN_2']}   $.description    