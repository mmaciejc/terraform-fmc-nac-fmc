*** Settings ***
Documentation    Verify Smart License
Suite Setup      Login FMC
Default Tags     fmc    day1    config    smartlicense
Resource    ../fmc_common.resource

*** Test Cases ***

Verify Smart License - 
    ${r}=    GET On Session    fmc    url=/api/fmc_platform/v1/license/smartlicenses
    Run Keyword If    'items' not in @{r.json()}    Fail    Item not found on FMC