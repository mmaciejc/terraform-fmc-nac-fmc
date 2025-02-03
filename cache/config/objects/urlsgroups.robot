*** Settings ***
Documentation    Verify URL Groups
Suite Setup      Login FMC
Default Tags     fmc    day1    config    urlgroups
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All URL Groups - Domain Global
    ${URLGrps}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/urlgroups?
    Set Global Variable    ${URLGrps}

Verify URL Group - new_url_grp
    Run Keyword If    'new_url_grp' not in @{URLGrps}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${URLGrps['new_url_grp']}   $.name           new_url_grp
    Should Be Equal Value Json String    ${URLGrps['new_url_grp']}   $.description    

#
    Should Be Equal Value Json List Of Dictionaries    ${URLGrps['new_url_grp']}    $.literals     url     ['https://ddd.org']