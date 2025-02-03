*** Settings ***
Documentation    Verify File policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    filepolicies
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All File Policies - Domain {{ domain.name }}
    ${FilePolicies}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/filepolicies?
    Set Global Variable    ${FilePolicies}

{% for filepolicy in domain.policies.file_policies | default([]) %}

Verify File Policy - {{ filepolicy.name }}
    Run Keyword If    '{{ filepolicy.name }}' not in @{FilePolicies}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${FilePolicies['{{ filepolicy.name }}']}   $.name           {{ filepolicy.name }}
    Should Be Equal Value Json String    ${FilePolicies['{{ filepolicy.name }}']}   $.description    {{ filepolicy.description | default(defaults.fmc.domains.policies.file_policies.description) }}


{% endfor %}
{% endfor %}