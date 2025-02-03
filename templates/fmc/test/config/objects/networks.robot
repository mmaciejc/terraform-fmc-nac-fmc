*** Settings ***
Documentation    Verify networks
Suite Setup      Login FMC
Default Tags     fmc    day1    config    networks
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All Networks - Domain {{ domain.name }}
    ${NETWORKS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/networks?
    Set Global Variable    ${NETWORKS}

{% for network in domain.objects.networks | default([]) %}

Verify Network - {{ network.name }}
    Run Keyword If    '{{ network.name }}' not in @{NETWORKS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKS['{{ network.name }}']}   $.name           {{ network.name }}
    Should Be Equal Value Json String    ${NETWORKS['{{ network.name }}']}   $.value          {{ network.prefix }}
    Should Be Equal Value Json String    ${NETWORKS['{{ network.name }}']}   $.description    {{ network.description | default(defaults.fmc.domains.objects.networks.description) }}

{% endfor %}
{% endfor %}