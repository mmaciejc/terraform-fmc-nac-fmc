*** Settings ***
Documentation    Verify URL Groups
Suite Setup      Login FMC
Default Tags     fmc    day1    config    urlgroups
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All URL Groups - Domain {{ domain.name }}
    ${URLGrps}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/urlgroups?
    Set Global Variable    ${URLGrps}

{% for urlgrp in domain.objects.url_groups | default([]) %}

Verify URL Group - {{ urlgrp.name }}
    Run Keyword If    '{{ urlgrp.name }}' not in @{URLGrps}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${URLGrps['{{ urlgrp.name }}']}   $.name           {{ urlgrp.name }}
    Should Be Equal Value Json String    ${URLGrps['{{ urlgrp.name }}']}   $.description    {{ urlgrp.description | default(defaults.fmc.domains.objects.urlgroups.description) }}

#{% if urlgrp.objects %}
#    Should Be Equal Value Json List Of Dictionaries    ${URLGrps['{{ urlgrp.name }}']}    $.objects     name      {{ urlgrp.objects }}
#{% endif %}

{% if urlgrp.literals %}
    Should Be Equal Value Json List Of Dictionaries    ${URLGrps['{{ urlgrp.name }}']}    $.literals     url     {{ urlgrp.literals }}
{% endif %}

{% endfor %}
{% endfor %}

