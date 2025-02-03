*** Settings ***
Documentation    Verify securityzones
Suite Setup      Login FMC
Default Tags     fmc    day1    config    securityzones
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All SecurityZones - Domain {{ domain.name }}
    ${SECURITYZONES}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/securityzones?
    Set Global Variable    ${SECURITYZONES}

{% for securityzone in domain.objects.securityzones | default([]) %}

Verify SecurityZone - {{ securityzone.name }}
    Run Keyword If    '{{ securityzone.name }}' not in @{SECURITYZONES}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${SECURITYZONES['{{ securityzone.name }}']}   $.name           {{ securityzone.name }}
    Should Be Equal Value Json String    ${SECURITYZONES['{{ securityzone.name }}']}   $.interfaceMode          {{ securityzone.interface_type }}

{% endfor %}
{% endfor %}