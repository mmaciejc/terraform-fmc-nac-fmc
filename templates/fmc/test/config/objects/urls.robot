*** Settings ***
Documentation    Verify URL
Suite Setup      Login FMC
Default Tags     fmc    day1    config    urls
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All URLs - Domain {{ domain.name }}
    ${URLS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/urls?
    Set Global Variable    ${URLS}

{% for url in domain.objects.urls | default([]) %}

Verify URL - {{ url.name }}
    Run Keyword If    '{{ url.name }}' not in @{URLS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${URLS['{{ url.name }}']}   $.name           {{ url.name }}
    Should Be Equal Value Json String    ${URLS['{{ url.name }}']}   $.url          {{ url.url }}
    Should Be Equal Value Json String    ${URLS['{{ url.name }}']}   $.description    {{ url.description | default(defaults.fmc.domains.objects.urls.description) }}

{% endfor %}
{% endfor %}