*** Settings ***
Documentation    Verify ports
Suite Setup      Login FMC
Default Tags     fmc    day1    config    ports
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All Hosts - Domain Global
    ${PORTS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/protocolportobjects?
    Set Global Variable    ${PORTS}

Verify Port - TCP_333
    Run Keyword If    'TCP_333' not in @{PORTS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${PORTS['TCP_333']}   $.name           TCP_333
    Should Be Equal Value Json String    ${PORTS['TCP_333']}   $.protocol          TCP
    Should Be Equal Value Json String    ${PORTS['TCP_333']}   $.port          333    

Verify Port - TCP_666
    Run Keyword If    'TCP_666' not in @{PORTS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${PORTS['TCP_666']}   $.name           TCP_666
    Should Be Equal Value Json String    ${PORTS['TCP_666']}   $.protocol          TCP
    Should Be Equal Value Json String    ${PORTS['TCP_666']}   $.port          666    

Verify Port - TCP_999
    Run Keyword If    'TCP_999' not in @{PORTS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${PORTS['TCP_999']}   $.name           TCP_999
    Should Be Equal Value Json String    ${PORTS['TCP_999']}   $.protocol          TCP
    Should Be Equal Value Json String    ${PORTS['TCP_999']}   $.port          999    