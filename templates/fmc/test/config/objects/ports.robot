*** Settings ***
Documentation    Verify ports
Suite Setup      Login FMC
Default Tags     fmc    day1    config    ports
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All Hosts - Domain {{ domain.name }}
    ${PORTS}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/protocolportobjects?
    Set Global Variable    ${PORTS}

{% for port in domain.objects.ports | default([]) %}

Verify Port - {{ port.name }}
    Run Keyword If    '{{ port.name }}' not in @{PORTS}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${PORTS['{{ port.name }}']}   $.name           {{ port.name }}
    Should Be Equal Value Json String    ${PORTS['{{ port.name }}']}   $.protocol          {{ port.protocol }}
    Should Be Equal Value Json String    ${PORTS['{{ port.name }}']}   $.port          {{ port.port }}    

{% endfor %}
{% endfor %}