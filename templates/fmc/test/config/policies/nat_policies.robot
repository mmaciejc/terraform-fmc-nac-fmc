*** Settings ***
Documentation    Verify MAT policies
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policies    natpolicies
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get Nat Policies
    ${nat_policies}=    Get All Objects By Name    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/ftdnatpolicies?
    Set Global Variable    ${nat_policies}

{% for ftd_nat_policy in domain.policies.ftd_nat_policies | default([]) %}

Verify NAT Policy - {{ ftd_nat_policy.name }}
    Run Keyword If    '{{ ftd_nat_policy.name }}' not in @{nat_policies}    Fail    Item not found on FMC
    
    Should Be Equal Value Json String    ${nat_policies['{{ ftd_nat_policy.name }}']}           $.name                                  {{ ftd_nat_policy.name }}
    Should Be Equal Value Json String    ${nat_policies['{{ ftd_nat_policy.name }}']}           $.description                           {{ ftd_nat_policy.description }}

    ${nat_policy_id}    Get Value From Json    ${nat_policies['{{ ftd_nat_policy.name }}']}    $.id
    Set Global Variable    ${nat_policy_id}    ${nat_policy_id[0]}

Get All Manual NAT Rules for Nat Policy - {{ ftd_nat_policy.name }}
    ${manual_nat_rules}=    Get All Objects    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/ftdnatpolicies/${nat_policy_id}/manualnatrules?
    Set Global Variable    ${manual_nat_rules}

{% for ftd_manual_nat_rule in ftd_nat_policy.ftd_manual_nat_rules | default([]) %}
Verify NAT Policy - {{ ftd_nat_policy.name }} - Manual NAT Rule {{ ftd_manual_nat_rule.name }}
    ${id}=    Get Object ID By Name From Tfstate    {{ ftd_nat_policy.name }}_{{ ftd_manual_nat_rule.name }}

    ${resource}    Set Variable    ${EMPTY}
    FOR    ${resource_item}    IN    @{manual_nat_rules}
        ${resource}=    Set Variable    ${resource_item}
        Exit For Loop If    "${resource_item}[id]" == "${id}"
    END
    Run Keyword If    "${resource_item}[id]" != "${id}"    Fail    Item not found on FMC

    Should Be Equal Value Json String Case Insensitive    ${resource}    $.natType                             {{ ftd_manual_nat_rule.nat_type }}
    Should Be Equal Value Json String                     ${resource}    $.originalSource.name                 {{ ftd_manual_nat_rule.original_source }}
    Should Be Equal Value Json String                     ${resource}    $.description                         {{ ftd_manual_nat_rule.description }}
    Should Be Equal Value Json String                     ${resource}    $.destinationInterface.name           {{ ftd_manual_nat_rule.destination_interface }}
    Should Be Equal Value Json String                     ${resource}    $.enabled                             {{ ftd_manual_nat_rule.enabled }}
    Should Be Equal Value Json String                     ${resource}    $.fallThrough                         {{ ftd_manual_nat_rule.fall_through }}
    Should Be Equal Value Json String                     ${resource}    $.interfaceInOriginalDestination      {{ ftd_manual_nat_rule.interface_in_original_destination }}
    Should Be Equal Value Json String                     ${resource}    $.interfaceInTranslatedSource         {{ ftd_manual_nat_rule.interface_in_translated_source }}
    Should Be Equal Value Json String                     ${resource}    $.interfaceIpv6                       {{ ftd_manual_nat_rule.ipv6 }}
    Should Be Equal Value Json String                     ${resource}    $.netToNet                            {{ ftd_manual_nat_rule.net_to_net }}
    Should Be Equal Value Json String                     ${resource}    $.noProxyArp                          {{ ftd_manual_nat_rule.no_proxy_arp }}
    Should Be Equal Value Json String                     ${resource}    $.originalDestination.name            {{ ftd_manual_nat_rule.original_destination }}
    Should Be Equal Value Json String                     ${resource}    $.originalDestinationPort.name        {{ ftd_manual_nat_rule.original_destination_port }}
    Should Be Equal Value Json String                     ${resource}    $.originalSourcePort.name             {{ ftd_manual_nat_rule.original_source_port }}
    Should Be Equal Value Json String                     ${resource}    $.routeLookup                         {{ ftd_manual_nat_rule.perform_route_lookup }}
    Should Be Equal Value Json String Case Insensitive    ${resource}    $.metadata.section                    {{ ftd_manual_nat_rule.section }}
    Should Be Equal Value Json String                     ${resource}    $.sourceInterface.name                {{ ftd_manual_nat_rule.source_interface }}
    Should Be Equal Value Json String                     ${resource}    $.dns                                 {{ ftd_manual_nat_rule.translate_dns }}
    Should Be Equal Value Json String                     ${resource}    $.translatedDestination.name          {{ ftd_manual_nat_rule.translated_destination }}
    Should Be Equal Value Json String                     ${resource}    $.translatedDestinationPort.name      {{ ftd_manual_nat_rule.translated_destination_port }}
    Should Be Equal Value Json String                     ${resource}    $.translatedSource.name               {{ ftd_manual_nat_rule.translated_source }}
    Should Be Equal Value Json String                     ${resource}    $.translatedSourcePort.name           {{ ftd_manual_nat_rule.translated_source_port }}
    Should Be Equal Value Json String                     ${resource}    $.unidirectional                      {{ ftd_manual_nat_rule.unidirectional }}
{% endfor %}

Get All Auto NAT Rules for Nat Policy - {{ ftd_nat_policy.name }}
    ${auto_nat_rules}=    Get All Objects    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/policy/ftdnatpolicies/${nat_policy_id}/autonatrules?
    Set Global Variable    ${auto_nat_rules}

{% for ftd_auto_nat_rule in ftd_nat_policy.ftd_auto_nat_rules | default([]) %}
Verify NAT Policy - {{ ftd_nat_policy.name }} - Auto NAT Rule {{ ftd_auto_nat_rule.name }}
    ${id}=    Get Object ID By Name From Tfstate    {{ ftd_nat_policy.name }}/{{ ftd_auto_nat_rule.name }}

    ${resource}    Set Variable    ${EMPTY}
    FOR    ${resource_item}    IN    @{auto_nat_rules}
        ${resource}=    Set Variable    ${resource_item}
        Exit For Loop If    "${resource_item}[id]" == "${id}"
    END
    Run Keyword If    "${resource_item}[id]" != "${id}"    Fail    Item not found on FMC

    Should Be Equal Value Json String Case Insensitive    ${resource}    $.natType                             {{ ftd_auto_nat_rule.nat_type }}
    Should Be Equal Value Json String                     ${resource}    $.description                         {{ ftd_auto_nat_rule.description }}
    Should Be Equal Value Json String                     ${resource}    $.destinationInterface.name           {{ ftd_auto_nat_rule.destination_interface }}
    Should Be Equal Value Json String                     ${resource}    $.fallThrough                         {{ ftd_auto_nat_rule.fall_through }}
    Should Be Equal Value Json String                     ${resource}    $.interfaceIpv6                       {{ ftd_auto_nat_rule.ipv6 }}
    Should Be Equal Value Json String                     ${resource}    $.netToNet                            {{ ftd_auto_nat_rule.net_to_net }}
    Should Be Equal Value Json String                     ${resource}    $.noProxyArp                          {{ ftd_auto_nat_rule.no_proxy_arp }}
    Should Be Equal Value Json String                     ${resource}    $.originalNetwork.name                {{ ftd_auto_nat_rule.original_network }}
    Should Be Equal Value Json String                     ${resource}    $.originalPort                        {{ ftd_auto_nat_rule.original_port.port }}
    Should Be Equal Value Json String                     ${resource}    $.serviceProtocol                     {{ ftd_auto_nat_rule.original_port.protocol }}
    Should Be Equal Value Json String                     ${resource}    $.originalSourcePort.name             {{ ftd_auto_nat_rule.original_source_port }}
    Should Be Equal Value Json String                     ${resource}    $.routeLookup                         {{ ftd_auto_nat_rule.perform_route_lookup }}
    Should Be Equal Value Json String                     ${resource}    $.sourceInterface.name                {{ ftd_auto_nat_rule.source_interface }}
    Should Be Equal Value Json String                     ${resource}    $.dns                                 {{ ftd_auto_nat_rule.translate_dns }}
    Should Be Equal Value Json String                     ${resource}    $.translatedNetwork.name              {{ ftd_auto_nat_rule.translated_network }}
    Should Be Equal Value Json String                     ${resource}    $.translatedPort                      {{ ftd_auto_nat_rule.translated_port }}
    Should Be Equal Value Json String                     ${resource}    $.interfaceInTranslatedNetwork        {{ ftd_auto_nat_rule.translated_network_is_destination_interface }}
    Should Be Equal Value Json String                     ${resource}    $.patOptions.extendedPat              {{ ftd_auto_nat_rule.pat_options.extended_pat_table }}
    Should Be Equal Value Json String                     ${resource}    $.patOptions.includeReserve           {{ ftd_auto_nat_rule.pat_options.include_reserve_ports }}
    Should Be Equal Value Json String                     ${resource}    $.patOptions.interfacePat             {{ ftd_auto_nat_rule.pat_options.interface_pat }}
    Should Be Equal Value Json String                     ${resource}    $.patOptions.patPoolAddress.name      {{ ftd_auto_nat_rule.pat_options.pat_pool_address }}
    Should Be Equal Value Json String                     ${resource}    $.patOptions.roundRobin               {{ ftd_auto_nat_rule.pat_options.round_robin }}

{% endfor %}

{% endfor %}
{% endfor %}