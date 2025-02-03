*** Settings ***
Documentation    Verify ICMPv4s
Suite Setup      Login FMC
Default Tags     fmc    day1    config    icmpv4s
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All ICMPv4s - Domain {{ domain.name }}
    ${ICMPv4s}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/icmpv4objects?
    Set Global Variable    ${ICMPv4s}

{% for icmpv4 in domain.objects.icmp_v4s | default([]) %}

Verify ICMPv4 - {{ icmpv4.name }}
    Run Keyword If    '{{ icmpv4.name }}' not in @{ICMPv4s}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${ICMPv4s['{{ icmpv4.name }}']}   $.name           {{ icmpv4.name }}
    Should Be Equal Value Json String Case Insensitive   ${ICMPv4s['{{ icmpv4.name }}']}   $.icmpType          {{ icmpv4.icmp_type }} 
{% if icmpv4.code|lower != "any" %}    
    Should Be Equal Value Json String    ${ICMPv4s['{{ icmpv4.name }}']}   $.code          {{ icmpv4.code }} 
{% endif %}      
    Should Be Equal Value Json String    ${ICMPv4s['{{ icmpv4.name }}']}   $.description    {{ icmpv4.description | default(defaults.fmc.domains.objects.icmp_v4s.description) }} 

{% endfor %}
{% endfor %}