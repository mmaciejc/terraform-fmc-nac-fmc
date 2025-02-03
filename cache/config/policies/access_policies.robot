*** Settings ***
Documentation    Verify access policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    accesspolicies
Resource    ../../fmc_common.resource

*** Test Cases ***

Verify Access Policy - MyAccessPolicyName1
    ${r}=    GET On Session    fmc    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/policy/accesspolicies?expanded=true&name=MyAccessPolicyName1
    Run Keyword If    'items' not in @{r.json()}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${r.json()}    $.items[0].name                                  MyAccessPolicyName1
    Should Be Equal Value Json String    ${r.json()}    $.items[0].description                           
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.action                  BLOCK
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.intrusionPolicy.name    
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.sendEventsToFMC         
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.logBegin                
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.logEnd                  
    ${access_policy_id}    Get Value From Json    ${r.json()}    $.items[0].id
    Set Global Variable    ${access_policy_id}    ${access_policy_id[0]}

Get All Categories for Access Policy - MyAccessPolicyName1
    ${CATEGORIES}=    Get All Objects By Name    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/policy/accesspolicies/${access_policy_id}/categories?
    Set Global Variable    ${CATEGORIES}

Verify Access Policy - MyAccessPolicyName1 - Category {'name': 'MyCategoryName1', 'section': 'mandatory'}
    Run Keyword If    'MyCategoryName1' not in @{CATEGORIES}    Fail    Item not found on FMC
Verify Access Policy - MyAccessPolicyName1 - Category {'name': 'MyCategoryName2', 'section': 'default'}
    Run Keyword If    'MyCategoryName2' not in @{CATEGORIES}    Fail    Item not found on FMC

Get All Access Rules for Access Policy - MyAccessPolicyName1
    ${ACCESSRULES}=    Get All Objects By Name    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/policy/accesspolicies/${access_policy_id}/accessrules?
    Set Global Variable    ${ACCESSRULES}

Verify Access Policy - MyAccessPolicyName1 - Access Rule MyAccessRuleNAme1
    Run Keyword If    'MyAccessRuleNAme1' not in @{ACCESSRULES}    Fail    Item not found on FMC
    #Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.metadata.ruleIndex   1
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.name                 MyAccessRuleNAme1
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.action               ALLOW
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.enabled              
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.metadata.category    MyCategoryName1
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['MyAccessRuleNAme1']}   $.destinationZones.objects             name    ['inside']
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.enableSyslog         
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.ipsPolicy.name       
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.logBegin             True
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.logEnd               True
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.logFiles             False
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.metadata.section     
    Should Be Equal Value Json String    ${ACCESSRULES['MyAccessRuleNAme1']}    $.sendEventsToFMC      True
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['MyAccessRuleNAme1']}   $.sourceZones.objects                  name    ['dmz']