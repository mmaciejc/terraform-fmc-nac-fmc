*** Settings ***
Documentation    Verify Dynamic Objects
Suite Setup      Login FMC
Default Tags     fmc    day1    config    dynamicobjects
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All DynamicObjects - Domain {{ domain.name }}
    ${DynObjs}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/dynamicobjects?
    Set Global Variable    ${DynObjs}

{% for dyn_obj in domain.objects.dynamic_objects | default([]) %}

Verify DynObjs - {{ dyn_obj.name }}
    Run Keyword If    '{{ dyn_obj.name }}' not in @{DynObjs}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${DynObjs['{{ dyn_obj.name }}']}   $.name           {{ dyn_obj.name }}
    Should Be Equal Value Json String    ${DynObjs['{{ dyn_obj.name }}']}   $.description    {{ dyn_obj.description | default(defaults.fmc.domains.objects.dynamic_objects.description) }} 

{% endfor %}
{% endfor %}