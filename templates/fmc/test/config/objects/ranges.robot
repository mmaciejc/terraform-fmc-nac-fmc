*** Settings ***
Documentation    Verify ranges
Suite Setup      Login FMC
Default Tags     fmc    day1    config    ranges
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All Ranges - Domain {{ domain.name }}
    ${RANGES}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/ranges?
    Set Global Variable    ${RANGES}

{% for range in domain.objects.ranges | default([]) %}

Verify Range - {{ range.name }}
    Run Keyword If    '{{ range.name }}' not in @{RANGES}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${RANGES['{{ range.name }}']}   $.name           {{ range.name }}
    Should Be Equal Value Json String    ${RANGES['{{ range.name }}']}   $.value          {{ range.ip_range }}
    Should Be Equal Value Json String    ${RANGES['{{ range.name }}']}   $.description    {{ range.description | default(defaults.fmc.domains.objects.ranges.description) }}

{% endfor %}
{% endfor %}