*** Settings ***
Documentation    Verify ICMPv4s
Suite Setup      Login FMC
Default Tags     fmc    day1    config    icmpv4s
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All ICMPv4s - Domain Global
    ${ICMPv4s}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/icmpv4objects?
    Set Global Variable    ${ICMPv4s}