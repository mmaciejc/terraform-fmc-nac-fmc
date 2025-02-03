*** Settings ***
Documentation    Verify Smart License
Suite Setup      Login FMC
Default Tags     fmc    day1    config    smartlicense
Resource    ../fmc_common.resource

*** Test Cases ***

Verify Smart License - {{ smartlicense }}
    ${r}=    GET On Session    fmc    url=/api/fmc_platform/v1/license/smartlicenses
    Run Keyword If    'items' not in @{r.json()}    Fail    Item not found on FMC
    

{% if fmc.system.smart_license %}
    
    Should Be Equal Value Json String    ${r.json()}    $.items[0].regStatus                                  {{ fmc.system.smart_license.registration_type }}
 
 {% endif %}

