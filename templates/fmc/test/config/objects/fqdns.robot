*** Settings ***
Documentation    Verify fqdns
Suite Setup      Login FMC
Default Tags     fmc    day1    config    fqdns
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All FQDNs - Domain {{ domain.name }}
    ${FQDNS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/fqdns?
    Set Global Variable    ${FQDNS}

{% for fqdn in domain.objects.fqdns | default([]) %}

Verify FQDN - {{ fqdn.name }}
    Run Keyword If    '{{ fqdn.name }}' not in @{FQDNS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${FQDNS['{{ fqdn.name }}']}   $.name           {{ fqdn.name }}
    Should Be Equal Value Json String    ${FQDNS['{{ fqdn.name }}']}   $.value          {{ fqdn.value }}
    Should Be Equal Value Json String    ${FQDNS['{{ fqdn.name }}']}   $.dnsResolution          {{ fqdn.dns_resolution | default(defaults.fmc.domains.objects.fqdns.dns_resolution) }}
    Should Be Equal Value Json String    ${FQDNS['{{ fqdn.name }}']}   $.description    {{ fqdn.description | default(defaults.fmc.domains.objects.fqdns.description) }}

{% endfor %}
{% endfor %}