*** Settings ***
Documentation    Verify Network Analysis policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    networkanalysispolicies
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All NetAnalysis Policies - Domain {{ domain.name }}
    ${NAPolicies}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/networkanalysispolicies?
    Set Global Variable    ${NAPolicies}

{% for netanaysispolicy in domain.policies.network_analysis_policies | default([]) %}

Verify Network Analysis Policy - {{ netanaysispolicy.name }}
    Run Keyword If    '{{ netanaysispolicy.name }}' not in @{NAPolicies}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NAPolicies['{{ netanaysispolicy.name }}']}   $.name           {{ netanaysispolicy.name }}
    Should Be Equal Value Json String    ${NAPolicies['{{ netanaysispolicy.name }}']}   $.metadata.snortEngine        {{ netanaysispolicy.snort_engine }}    
    Should Be Equal Value Json String    ${NAPolicies['{{ netanaysispolicy.name }}']}   $.description           {{ netanaysispolicy.description }}   

{% if netanaysispolicy.basePolicy %}
    Should Be Equal Value Json String    ${NAPolicies['{{ netanaysispolicy.name }}']}    $.basePolicy.name     {{ netanaysispolicy.base_policy }}
{% endif %}


{% endfor %}
{% endfor %}
