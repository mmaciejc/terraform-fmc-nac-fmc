*** Settings ***
Documentation    Verify Access Lists
Suite Setup      Login FMC
Default Tags     fmc    day1    config    accesslists
Resource    ../../fmc_common.resource

*** Test Cases ***

Get All Standard ACLs - Domain Global
    ${StdACLs}    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/standardaccesslists?
    Set Global Variable    ${StdACLs}

Verify ACL - Test_Standard_ACL
    Dictionary Should Contain Key     ${StdACLs}     Test_Standard_ACL
    Should Be Equal Value Json String    ${StdACLs['Test_Standard_ACL']}   $.name           Test_Standard_ACL
    ${i}     Set Variable     ${0}
    Set Global Variable    ${i}
    Dictionary Should Contain Key     ${StdACLs['Test_Standard_ACL']}     entries    
    ${acl_cnt}    Get Length     [{'action': 'PERMIT', 'literals': ['13.13.13.13'], 'objects': ['Host_1']}, {'action': 'PERMIT', 'objects': ['Host_1']}]
    Set Global Variable    ${acl_cnt}
    ${fmc_cnt}    Get Length    ${StdACLs['Test_Standard_ACL']["entries"]}   
    Set Global Variable    ${fmc_cnt}
    #Run Keyword If   "${acl_cnt}" != "${fmc_cnt}"   Fail    Different number of entries

Create All Objects Dictionary
    ${hosts}    Get All Objects By Name     url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/hosts?     key=id
    ${networks}    Get All Objects By Name     url=/api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['Global']}/object/networks?     key=id
    ${objects}    Create Dictionary
    Set To Dictionary      ${objects}     hosts     ${hosts}
    Set To Dictionary      ${objects}     networks     ${networks}
    Set Global Variable    ${objects}  

Verify ACL entries number YAML ${acl_cnt} FMC ${fmc_cnt}
    ${acl_entries}      Create Dictionary
    Set Global Variable    ${acl_entries}

Build ACL From FMC
    ${tmp_obj}    Create List
    ${tmp_lit}    Create List
        FOR    ${entry}     IN     @{StdACLs['Test_Standard_ACL']['entries']}
            Dictionary Should Contain Key     ${entry}     networks
            FOR     ${object}     IN     @{entry['networks']['objects']}
                IF    '${object["type"]}' == 'Host'
                    Append To List     ${tmp_obj}     ${objects["hosts"]['${object["id"]}']["name"]}
                END
                IF    '${object["type"]}' == 'Network'
                    Append To List     ${tmp_obj}     ${objects["networks"]['${object["id"]}']["name"]}
                END    
            Set To Dictionary      ${acl_entries}     objects     ${tmp_obj}
            END
            FOR     ${literal}     IN     @{entry['networks']['literals']}
                Append To List     ${tmp_lit}     ${literal["value"]}
            Set To Dictionary      ${acl_entries}     literals     ${tmp_lit}
            END            
            Set To Dictionary      ${acl_entries}     action     ${entry["action"]}
            #Log To Console     ${acl_entries}
            #Log To Console     {'action': 'PERMIT', 'literals': ['13.13.13.13'], 'objects': ['Host_1']}
            #Dictionaries Should Be Equal     {'action': 'PERMIT', 'literals': ['13.13.13.13'], 'objects': ['Host_1']}     ${acl_entries}    
            #ignore_keys=['objects', 'literals']
            Dictionaries of Lists and String Should Be Equal      {'action': 'PERMIT', 'literals': ['13.13.13.13'], 'objects': ['Host_1']}     ${acl_entries}
        END
    ${acl_entries}      Create Dictionary
    Set Global Variable    ${acl_entries}

Build ACL From FMC
    ${tmp_obj}    Create List
    ${tmp_lit}    Create List
        FOR    ${entry}     IN     @{StdACLs['Test_Standard_ACL']['entries']}
            Dictionary Should Contain Key     ${entry}     networks
            FOR     ${object}     IN     @{entry['networks']['objects']}
                IF    '${object["type"]}' == 'Host'
                    Append To List     ${tmp_obj}     ${objects["hosts"]['${object["id"]}']["name"]}
                END
                IF    '${object["type"]}' == 'Network'
                    Append To List     ${tmp_obj}     ${objects["networks"]['${object["id"]}']["name"]}
                END    
            Set To Dictionary      ${acl_entries}     objects     ${tmp_obj}
            END
            FOR     ${literal}     IN     @{entry['networks']['literals']}
                Append To List     ${tmp_lit}     ${literal["value"]}
            Set To Dictionary      ${acl_entries}     literals     ${tmp_lit}
            END            
            Set To Dictionary      ${acl_entries}     action     ${entry["action"]}
            #Log To Console     ${acl_entries}
            #Log To Console     {'action': 'PERMIT', 'objects': ['Host_1']}
            #Dictionaries Should Be Equal     {'action': 'PERMIT', 'objects': ['Host_1']}     ${acl_entries}    
            #ignore_keys=['objects', 'literals']
            Dictionaries of Lists and String Should Be Equal      {'action': 'PERMIT', 'objects': ['Host_1']}     ${acl_entries}
        END