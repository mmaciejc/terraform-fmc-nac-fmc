*** Settings ***
Documentation    Verify Prefilter policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    prefilterpolicy
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All Prefilter Policies - Domain {{ domain.name }}
    ${PreFilterPolicies}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/prefilterpolicies?
    Set Global Variable    ${PreFilterPolicies}

{% for prefilterpolicy in domain.policies.prefilter_policies | default([]) %}

Verify Prefilter Policy - {{ prefilterpolicy.name }}
    Run Keyword If    '{{ prefilterpolicy.name }}' not in @{PreFilterPolicies}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${PreFilterPolicies['{{ prefilterpolicy.name }}']}   $.name           {{ prefilterpolicy.name }}
    #Should Be Equal Value Json String    ${PreFilterPolicies['{{ prefilterpolicy.name }}']}   $.description    {{ prefilterpolicy.description | default(defaults.fmc.domains.policies.prefilter_policies.description) }}
   
{% if prefilterpolicy.action %}
    Should Be Equal Value Json String    ${PreFilterPolicies['{{ prefilterpolicy.name }}']}    $.defaultAction.action     {{ prefilterpolicy.action }}
{% endif %}

#{% if prefilterpolicy.log_begin %}
#    Should Be Equal Value Json String    ${PreFilterPolicies['{{ prefilterpolicy.name }}']}    $.defaultAction.log_begin     {{ prefilterpolicy.log_begin }}
#{% endif %}

#{% if prefilterpolicy.send_events_to_fmc %}
#    Should Be Equal Value Json String    ${PreFilterPolicies['{{ prefilterpolicy.name }}']}    $.defaultAction.sendEventsToFMC     {{ prefilterpolicy.send_events_to_fmc }}
#{% endif %}


{% endfor %}
{% endfor %}