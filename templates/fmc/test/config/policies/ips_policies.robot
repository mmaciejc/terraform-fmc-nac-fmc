*** Settings ***
Documentation    Verify IPS policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    ipspolicies
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All IPS Policies - Domain {{ domain.name }}
    ${IPSPolicies}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/intrusionpolicies?
    Set Global Variable    ${IPSPolicies}

{% for ipspolicy in domain.policies.ips_policies | default([]) %}

Verify IPS Policy - {{ ipspolicy.name }}
    Run Keyword If    '{{ ipspolicy.name }}' not in @{IPSPolicies}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${IPSPolicies['{{ ipspolicy.name }}']}   $.name           {{ ipspolicy.name }}
    Should Be Equal Value Json String    ${IPSPolicies['{{ ipspolicy.name }}']}   $.inspectionMode           {{ ipspolicy.inspectionMode }}    
    Should Be Equal Value Json String    ${IPSPolicies['{{ ipspolicy.name }}']}   $.description           {{ ipspolicy.description }}    

{% if ipspolicy.basePolicy %}
    Should Be Equal Value Json String    ${IPSPolicies['{{ ipspolicy.name }}']}    $.basePolicy.name     {{ ipspolicy.base_policy }}
{% endif %}


{% endfor %}
{% endfor %}