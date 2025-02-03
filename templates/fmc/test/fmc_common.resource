*** Settings ***
Library    pabot.PabotLib
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    Process

*** Keywords ***
Get FMC Token
    ${auth}=    Create List    %{FMC_USERNAME}    %{FMC_PASSWORD}
    ${verify}=    Set Variable If    "%{FMC_INSECURE_SKIP_VERIFY}" == "False"    True    False
    ${log_level}=   Set Log Level   NONE
    Create Session    fmc_login    https://%{FMC_HOST}   auth=${auth}  verify=${verify}    disable_warnings=1
    Set Log Level   ${log_level}
    ${response}=    Wait Until Keyword Succeeds    1x    10s    POST On Session    fmc_login    /api/fmc_platform/v1/auth/generatetoken
    
    ${fmc_domain_map}=    Create Dictionary
    ${domain_list}    Evaluate    json.loads('''${response.headers['DOMAINS']}''')
    FOR    ${element}    IN    @{domain_list}
        Set To Dictionary    ${fmc_domain_map}    ${element['name']}    ${element['uuid']}
    END

    Set Parallel Value For Key    fmc_token    ${response.headers['X-auth-access-token']}
    Set Parallel Value For Key    fmc_domain_map    ${fmc_domain_map}

Login FMC
    Run Only Once    Get FMC Token
    ${fmc_token}=    Get Parallel Value For Key    fmc_token
    ${fmc_domain_map}=    Get Parallel Value For Key    fmc_domain_map 
    Create Session    fmc    https://%{FMC_HOST}    headers={"content-type": "application/json", "X-auth-access-token":"${fmc_token}"}    disable_warnings=1
    Set Global Variable    ${FMC_DOMAIN_MAP}    ${fmc_domain_map}

Should Be Equal Value Json String
    [Arguments]    ${json}    ${json_path}   ${value}=${EMPTY}
    ${r_value}=   Get Value From Json   ${json}   ${json_path}
    Run Keyword If   "${value}" != "${EMPTY}"   Should Be Equal As Strings   ${r_value}[0]   ${value}

Should Be Equal Value Json String Case Insensitive
    [Arguments]    ${json}    ${json_path}   ${value}=${EMPTY}
    ${r_value}=   Get Value From Json   ${json}   ${json_path}
    ${tmp_val}=   Convert To Lowercase   ${r_value}[0] 
    Run Keyword If   "${value}" != "${EMPTY}"   Should Be Equal As Strings     ${tmp_val.lower()}   ${value.lower()}

Should Be Equal Value Json List
    [Arguments]    ${json}    ${json_path}   ${value}=${None}
    ${r_value}=   Get Value From Json   ${json}   ${json_path}
    ${inner_list}=    Get From List    ${r_value}    0
    Run Keyword If   "${value}" != "${None}"   Lists Should Be Equal   ${inner_list}   ${value}   ignore_order=True

Should Be Equal Value Json List Of Dictionaries
    #
    #Data model: literals: ["obj1", "obj2"]
    #FMC:        literals: [{"name": "obj1"},{"name": "obj2"}]
    #}
    [Arguments]    ${json}    ${json_path}    ${key}    ${value}=${None}
    ${r_value}=    Get Value From Json    ${json}    ${json_path}
    ${r_value_extracted}=    Create List
    FOR    ${element}    IN    @{r_value}[0]
        Append To List    ${r_value_extracted}    ${element["${key}"]}
    END
    ${l_value}=    Evaluate    eval("${value}")

    Run Keyword If   "${value}" != "${None}"   Lists Should Be Equal    ${r_value_extracted}    ${l_value}    ignore_order=True

Should Value be in Json List Of Dictionaries
    
    [Arguments]    ${json}    ${key}    ${value}=${None}
    ${r_value_extracted}=    Create List

    FOR    ${element}    IN    ${json}[0]
        Append To List    ${r_value_extracted}    ${element["${key}"]}
    END

    Run Keyword If   "${value}" == "${None}"   Fail    Device not present in the configuration 
    Run Keyword If    '${value}' not in ${r_value_extracted}    Fail    Device not on the list of targed devices for checked policy 
    
    [Return]

Get All Objects
    [Arguments]    ${url}
    ${r}=    GET On Session    fmc    url=${url}expanded=true&limit=10000
    IF     'items' not in @{r.json()}
        @{objects}      Create List
    ELSE
        @{objects}      Create List    @{r.json()['items']}
    END

    WHILE    'next' in @{r.json()['paging']}
        ${r}=       GET On Session    fmc    url=${r.json()['paging']['next'][0]}
        Append To List    ${objects}       @{r.json()['items']}
    END

    [Return]    ${objects}

Get All Objects By Name
    [Arguments]    ${url}     ${key}=${None}
    ${r}=    GET On Session    fmc    url=${url}expanded=true&limit=10000
    IF     'items' not in @{r.json()}
        @{objects}      Create List
    ELSE
        @{objects}      Create List    @{r.json()['items']}
    END

    WHILE    'next' in @{r.json()['paging']}
        ${r}=       GET On Session    fmc    url=${r.json()['paging']['next'][0]}
        Append To List    ${objects}       @{r.json()['items']}
    END



    ${objects_by_name}=    Create Dictionary
    FOR    ${element}    IN    @{objects}
        IF    "${key}" == "${None}"    
            Set To Dictionary    ${objects_by_name}    ${element['name']}    ${element}
        ELSE
            Set To Dictionary    ${objects_by_name}    ${element['${key}']}     ${element}
        END
    END

    [Return]    ${objects_by_name}

Dictionaries of Lists and String Should Be Equal 
    [Arguments]    ${obj1}     ${obj2}

    ${dict1}    Evaluate    eval("${obj1}")
    ${dict2}    Evaluate    eval("${obj2}")

    ${keys1}     Get Dictionary Keys     ${dict1}
    FOR    ${key}     IN     @{keys1}
        Dictionary Should Contain Key     ${dict2}    ${key}
        IF    "${key}" in ["objects", "literals"]
            Lists Should Be Equal    ${dict1['${key}']}      ${dict2['${key}']}     ignore_order=${True}
        END
        IF    "${key}" == "action"
            Should Be Equal As Strings    ${dict1['${key}']}      ${dict2['${key}']}     
        END
    END   

    ${keys2}     Get Dictionary Keys     ${dict2}
    FOR    ${key}     IN     @{keys2}
        Dictionary Should Contain Key     ${dict1}    ${key}
        IF    "${key}" in ["objects", "literals"]
            Lists Should Be Equal    ${dict1['${key}']}      ${dict2['${key}']}     ignore_order=${True}
        END
        IF    "${key}" == "action"
            Should Be Equal As Strings    ${dict1['${key}']}      ${dict2['${key}']}     
        END
    END       
    [Return]




Get Object ID By Name From Tfstate
    [Arguments]    ${name}
    ${tf_objects}=    Run Process    terraform    state    list
    ${tf_object_name}=    Get Lines Containing String     ${tf_objects.stdout}       \"${name}\"
    Run Keyword If    '${tf_object_name}' == '${EMPTY}'   Fail    Item not found in tfstate file
    ${tf_resource}=    Run Process    terraform    state    show    ${tf_object_name}
    ${ids}=    Get Lines Containing String    ${tf_resource.stdout}    id
    ${id_pair}=    Split String From Right    ${ids}    \n
    ${id}=    Split String    ${id_pair}[0]    \"
    ${id}=    Set Variable     ${id}[1]   

    [Return]    ${id}
