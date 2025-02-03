*** Settings ***
Documentation    Verify Policy Assignement
Suite Setup      Login FMC
Default Tags     fmc    day1    config    policyassignement
Resource    ../fmc_common.resource

*** Test Cases ***

{% for domain in fmc.domains | default([]) %}

{% for device in domain.devices | default([]) %}


Verify Policy Assignement for Device - {{ device.name }}
    ${PolicyAssignement}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/assignment/policyassignments?
    Set Global Variable    ${PolicyAssignement}

    

{% if device.nat_policy %}

    Run Keyword If    '{{ device.nat_policy }}' not in ${PolicyAssignement}    Fail    Policy assignement not present on FMC
    Run Keyword If    'targets' not in ${PolicyAssignement['{{ device.nat_policy }}']}    Fail    Policy is not assigned to any device
    Should Value be in Json List Of Dictionaries    ${PolicyAssignement['{{ device.nat_policy }}']['targets']}       name         {{ device.name }}

{% endif %}

{% if device.access_policy %}

    Run Keyword If    '{{ device.access_policy }}' not in ${PolicyAssignement}    Fail    Policy assignement not present on FMC
    Run Keyword If    'targets' not in ${PolicyAssignement['{{ device.access_policy }}']}    Fail    Policy is not assigned to any device
    Should Value be in Json List Of Dictionaries    ${PolicyAssignement['{{ device.access_policy }}']['targets']}       name         {{ device.name }}

{% endif %}

{% endfor %}
{% endfor %}
