*** Settings ***
Documentation    Verify Device
Suite Setup      Login FMC
Default Tags     fmc    day1    config    devices
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

{% for device in domain.devices.devices | default([]) %}

Verify Device - {{ device.name }}
    ${r}=    GET On Session    fmc    url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/devices/devicerecords?filter=name:{{ device.name }}&expanded=true
    Log To Console    ${r.json()}
    Run Keyword If    'items' not in @{r.json()}    Fail    Item not found on FMC
    
    Should Be Equal Value Json String    ${r.json()}    $.items[0].name    {{ device.name }}
    Should Be Equal Value Json String    ${r.json()}    $.items[0].hostName    {{ device.host }}
    Should Be Equal Value Json String    ${r.json()}    $.items[0].license_caps    {{ device.licenses }}
    Should Be Equal Value Json String    ${r.json()}    $.items[0].accessPolicy.name    {{ device.access_policy }}

    ${device_id}    Get Value From Json    ${r.json()}    $.items[0].id
    Set Global Variable    ${device_id}    ${device_id[0]}

Get Physical Interfaces for Device - {{ device.name }}
    ${physicalinterfaces}=    Get All Objects By Name     url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/devices/devicerecords/${device_id}/physicalinterfaces?

    Set Global Variable    ${physicalinterfaces}

Get Dictionary of All Security Zones
    ${securityzones}=    Get All Objects By Name     url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/securityzones?

    Set Global Variable    ${securityzones}  

###
# Physical Interfaces
###
{% if device.physical_interfaces %}
{% for physicalinterface in device.physical_interfaces | default([]) %}
Verify Device - {{ device.name }} - Physical Interface {{ physicalinterface.interface }}

    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.ifname                              {{ physicalinterface.name }}
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.enabled                             {{ physicalinterface.enabled | default(defaults.fmc.domains.devices.devices.physical_interfaces.enabled) }}
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.description                         {{ physicalinterface.description | default(defaults.fmc.domains.devices.devices.physical_interfaces.description) }}
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.mode                                {{ physicalinterface.mode | default(defaults.fmc.domains.devices.devices.physical_interfaces.mode) }}
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.name                                {{ physicalinterface.interface }}    
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.mtu                                 {{ physicalinterface.mtu }}  
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.ipv4.dhcp.enableDefaultRouteDHCP    {{ physicalinterface.ipv4_dhcp }}  
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.ipv4.dhcp.dhcpRouteMetric           {{ physicalinterface.ipv4_dhcp_route_metric }}  
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.ipv6.enableIPV6                     {{ physicalinterface.ipv6 }}  
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.ipv6.addresses[0].address           {{ physicalinterface.ipv6_address }}  
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.ipv6.addresses[0].prefix            {{ physicalinterface.ipv6_prefix }}  
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.ipv6.enforceEUI64                   {{ physicalinterface.ipv6_enforce_eui64 }}  
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.ipv4.static.address                 {{ physicalinterface.ipv4_static_address }}      
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.ipv4.static.netmask                 {{ physicalinterface.ipv4_static_netmask }}          
    IF    '{{ physicalinterface.security_zone }}' in @{securityzones}
    Should Be Equal Value Json String    ${physicalinterfaces['{{ physicalinterface.interface }}']}   $.securityZone.id    ${securityzones['{{ physicalinterface.security_zone }}']['id']}
    END

###
# Subinterfaces
###
{% if physicalinterface.subinterfaces %}

Get Subbnterfaces for Interface - {{ physicalinterface.interface }} - of the device {{ device.name }}

    ${subinterfaces}=    Get All Objects By Name     url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/devices/devicerecords/${device_id}/subinterfaces?     key=ifname
    Set Global Variable    ${subinterfaces}

{% for subinterface in physicalinterface.subinterfaces %}

    Run Keyword If    '{{ subinterface.name }}' not in ${subinterfaces}    Fail    Subinterfce not found

    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.vlanId                {{ subinterface.vlan }}          
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.subIntfId             {{ subinterface.id }}          
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv4.static.netmask                 {{ subinterface.ipv4_static_netmask }}          
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv4.static.netmask                 {{ subinterface.ipv4_static_netmask }}          

    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.description                         {{ subinterface.description | default(defaults.fmc.domains.devices.devices.physical_interfaces.subinterfaces.description) }}
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.mode                                {{ subinterface.mode | default(defaults.fmc.domains.devices.devices.physical_interfaces.mode) }}
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.name                                {{ subinterface.interface }}    
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.priority                            {{ subinterface.priority }}  
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.mtu                                 {{ subinterface.mtu }}  
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv4.dhcp.enableDefaultRouteDHCP    {{ subinterface.ipv4_dhcp }}  
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv4.dhcp.dhcpRouteMetric           {{ subinterface.ipv4_dhcp_route_metric }}  
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv6.enableIPV6                     {{ subinterface.ipv6 }}  
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv6.addresses[0].address           {{ subinterface.ipv6_address }}  
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv6.addresses[0].prefix            {{ subinterface.ipv6_prefix }}  
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv6.enforceEUI64                   {{ subinterface.ipv6_enforce_eui64 }}  
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv4.static.address                 {{ subinterface.ipv4_static_address }}      
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.ipv4.static.netmask                 {{ subinterface.ipv4_static_netmask }}          
    IF    '{{ subinterface.security_zone }}' in @{securityzones}
    Should Be Equal Value Json String    ${subinterfaces['{{ subinterface.name }}']}   $.securityZone.id    ${securityzones['{{ subinterface.security_zone }}']['id']}
    END


{% endfor %}  
{% endif %}

###
# VTEP
###
{% if physicalinterface.vteps %}

Get VTEPs for Interface - {{ physicalinterface.interface }} - of the device {{ device.name }}

    ${vteps}=    Get All Objects By Name     url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/devices/devicerecords/${device_id}/vteppolicies?     key=type
    Set Global Variable    ${vteps}

{% for vtep in physicalinterface.vteps %}

    Should Be Equal Value Json String    ${vteps['VTEPPolicy']}   $.nveEnable                                 {{ vtep.nve_enabled }}          
    Should Be Equal Value Json String    ${vteps['VTEPPolicy']}   $.vtepEntries[0].nveDestinationPort         {{ vtep.encapsulation_port }}          
    Should Be Equal Value Json String    ${vteps['VTEPPolicy']}   $.vtepEntries[0].nveEncapsulationType       {{ vtep.encapsulation_type }}          
    Should Be Equal Value Json String    ${vteps['VTEPPolicy']}   $.vtepEntries[0].sourceInterface.name       {{ physicalinterface.interface }}          

{% endfor %}  
{% endif %}


{% endfor %}  
{% endif %}
###
# VNI
###
{% if device.vnis %}
Get VNIs for Device {{ device.name }}
    ${vnis}=    Get All Objects By Name     url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/devices/devicerecords/${device_id}/vniinterfaces?     key=ifname
    Set Global Variable    ${vnis}

{% for vni in device.vnis  %}

    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.ifname                                 {{ vni.name }}          
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.enabled                                {{ vni.enabled }}          
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.description                            {{ vni.description }}          
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.priority                               {{ vni.priority }}          
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.segmentId                              {{ vni.vni_segment_id }}          
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.vniId                                  {{ vni.vni_id }}      
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.multicastGroupAddress                  {{ vni.multicast_group_address }}      
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.ipv4.static.address                    {{ vni.ipv4_static_address }}      
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.ipv4.static.netmask                    {{ vni.ipv4_static_netmask }}      
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.ipv4.dhcp.enableDefaultRouteDHCP       {{ vni.ipv4_dhcp_default_route }}      
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.ipv4.dhcp.dhcpRouteMetric              {{ vni.ipv4_dhcp_route_metric }}    
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.enableProxy                            {{ vni.enable_proxy }}      
    IF    '{{ vni.security_zone }}' in @{securityzones}
    Should Be Equal Value Json String    ${vnis['{{ vni.name }}']}   $.securityZone.id    ${securityzones['{{ vni.security_zone }}']['id']}
    END

{% endfor %}
{% endif %}


{% endfor %}
{% endfor %}

