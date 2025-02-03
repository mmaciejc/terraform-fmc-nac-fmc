*** Settings ***
Documentation    Verify access policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    accesspolicies
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

{% for accesspolicy in domain.policies.access_policies | default([]) %}

Verify Access Policy - {{ accesspolicy.name }}
    ${r}=    GET On Session    fmc    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/accesspolicies?expanded=true&name={{ accesspolicy.name }}
    Run Keyword If    'items' not in @{r.json()}    Fail    Item not found on FMC
    
    Should Be Equal Value Json String    ${r.json()}    $.items[0].name                                  {{ accesspolicy.name }}
    Should Be Equal Value Json String    ${r.json()}    $.items[0].description                           {{ accesspolicy.description }}
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.action                  {{ accesspolicy.default_action | default(defaults.fmc.domains.policies.access_policies.default_action) }}
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.intrusionPolicy.name    {{ accesspolicy.base_ips_policy }}
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.sendEventsToFMC         {{ accesspolicy.send_events_to_fmc | default(defaults.fmc.domains.policies.access_policies.send_events_to_fmc) }}
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.logBegin                {{ accesspolicy.log_begin | default(defaults.fmc.domains.policies.access_policies.log_begin) }}
    Should Be Equal Value Json String    ${r.json()}    $.items[0].defaultAction.logEnd                  {{ accesspolicy.log_end | default(defaults.fmc.domains.policies.access_policies.log_end) }}

    ${access_policy_id}    Get Value From Json    ${r.json()}    $.items[0].id
    Set Global Variable    ${access_policy_id}    ${access_policy_id[0]}

Get All Categories for Access Policy - {{ accesspolicy.name }}
    ${CATEGORIES}=    Get All Objects By Name    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/accesspolicies/${access_policy_id}/categories?
    Set Global Variable    ${CATEGORIES}

{% for category in accesspolicy.categories | default([]) %}
Verify Access Policy - {{ accesspolicy.name }} - Category {{ category }}
    Run Keyword If    '{{ category.name }}' not in @{CATEGORIES}    Fail    Item not found on FMC
{% endfor %}

Get All Access Rules for Access Policy - {{ accesspolicy.name }}
    ${ACCESSRULES}=    Get All Objects By Name    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/accesspolicies/${access_policy_id}/accessrules?
    Set Global Variable    ${ACCESSRULES}

{% for accessrule in accesspolicy.access_rules | default([]) %}
Verify Access Policy - {{ accesspolicy.name }} - Access Rule {{ accessrule.name }}

    Run Keyword If    '{{ accessrule.name }}' not in @{ACCESSRULES}    Fail    Item not found on FMC
    #Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.metadata.ruleIndex   {{ loop.index }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.name                 {{ accessrule.name }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.action               {{ accessrule.action }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.enabled              {{ accessrule.enabled }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.metadata.category    {{ accessrule.category }}

{% if accessrule.destination_dynamic_objects %}
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['{{ accessrule.name }}']}   $.destinationDynamicObjects.objects    name    {{ accessrule.destination_dynamic_objects }}
{% endif %}

{% if accessrule.destination_networks %}
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['{{ accessrule.name }}']}   $.destinationNetworks.objects          name    {{ accessrule.destination_network_objects }}
{% endif %}

{% if accessrule.destination_ports %}
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['{{ accessrule.name }}']}   $.destinationPorts.objects             name    {{ accessrule.destination_port_objects }}
{% endif %}

{% if accessrule.destination_zones %}
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['{{ accessrule.name }}']}   $.destinationZones.objects             name    {{ accessrule.destination_zones }}
{% endif %}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.enableSyslog         {{ accessrule.enable_syslog }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.ipsPolicy.name       {{ accessrule.ips_policy }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.logBegin             {{ accessrule.log_connection_begin }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.logEnd               {{ accessrule.log_connection_end }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.logFiles             {{ accessrule.log_files }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.metadata.section     {{ accessrule.section }}
    Should Be Equal Value Json String    ${ACCESSRULES['{{ accessrule.name }}']}    $.sendEventsToFMC      {{ accessrule.send_events_to_fmc }}

{% if accessrule.source_dynamic_objects %}
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['{{ accessrule.name }}']}   $.sourceDynamicObjects.objects         name    {{ accessrule.source_dynamic_objects }}
{% endif %}

{% if accessrule.source_networks %}
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['{{ accessrule.name }}']}   $.sourceNetworks.objects               name    {{ accessrule.source_network_objects }}
{% endif %}

{% if accessrule.source_ports %}
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['{{ accessrule.name }}']}   $.sourcePorts.objects                  name    {{ accessrule.source_port_objects }}
{% endif %}

{% if accessrule.source_zones %}
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['{{ accessrule.name }}']}   $.sourceZones.objects                  name    {{ accessrule.source_zones }}
{% endif %}

{% if accessrule.urls %}
    Should Be Equal Value Json List Of Dictionaries    ${ACCESSRULES['{{ accessrule.name }}']}   $.urls.objects                         name    {{ accessrule.urls }}
{% endif %}

{% endfor %}

{% endfor %}
{% endfor %}