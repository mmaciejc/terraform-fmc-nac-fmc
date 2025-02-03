*** Settings ***
Documentation    Verify hosts
Suite Setup      Login FMC
Default Tags     fmc    day1    config    hosts
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All Hosts - Domain {{ domain.name }}
    ${HOSTS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/hosts?
    Set Global Variable    ${HOSTS}

{% for host in domain.objects.hosts | default([]) %}

Verify Host - {{ host.name }}
    Run Keyword If    '{{ host.name }}' not in @{HOSTS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${HOSTS['{{ host.name }}']}   $.name           {{ host.name }}
    Should Be Equal Value Json String    ${HOSTS['{{ host.name }}']}   $.value          {{ host.ip }}
    Should Be Equal Value Json String    ${HOSTS['{{ host.name }}']}   $.description    {{ host.description | default(defaults.fmc.domains.objects.hosts.description) }}

{% endfor %}
{% endfor %}