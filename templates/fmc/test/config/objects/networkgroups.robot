*** Settings ***
Documentation    Verify network groups
Suite Setup      Login FMC
Default Tags     fmc    day1    config    networkgroups
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All Network Groups - Domain {{ domain.name }}
    ${NETWORKGROUPS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/networkgroups?
    Set Global Variable    ${NETWORKGROUPS}

{% for networkgroup in domain.objects.network_groups | default([]) %}

Verify Network Group - {{ networkgroup.name }}
    Run Keyword If    '{{ networkgroup.name }}' not in @{NETWORKGROUPS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${NETWORKGROUPS['{{ networkgroup.name }}']}   $.name           {{ networkgroup.name }}
    Should Be Equal Value Json String    ${NETWORKGROUPS['{{ networkgroup.name }}']}   $.description    {{ networkgroup.description | default(defaults.fmc.domains.objects.networkgroups.description) }}

{% if networkgroup.objects %}
    Should Be Equal Value Json List Of Dictionaries    ${NETWORKGROUPS['{{ networkgroup.name }}']}    $.objects     name      {{ networkgroup.objects }}
{% endif %}

{% if networkgroup.literals %}
    Should Be Equal Value Json List Of Dictionaries    ${NETWORKGROUPS['{{ networkgroup.name }}']}    $.literals    value     {{ networkgroup.literals }}
{% endif %}

{% endfor %}
{% endfor %}