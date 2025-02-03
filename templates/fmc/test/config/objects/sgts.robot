*** Settings ***
Documentation    Verify SGTs
Suite Setup      Login FMC
Default Tags     fmc    day1    config    sgts
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All SGTs - Domain {{ domain.name }}
    ${SGTS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/securitygrouptags?
    Set Global Variable    ${SGTS}

{% for sgt in domain.objects.sgts | default([]) %}

Verify SGT - {{ sgt.name }}
    Run Keyword If    '{{ sgt.name }}' not in @{SGTS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${SGTS['{{ sgt.name }}']}   $.name           {{ sgt.name }}
    Should Be Equal Value Json String    ${SGTS['{{ sgt.name }}']}   $.tag          {{ sgt.tag }}
    Should Be Equal Value Json String    ${SGTS['{{ sgt.name }}']}   $.description    {{ sgt.description | default(defaults.fmc.domains.objects.sgts.description) }}

{% endfor %}
{% endfor %}