*** Settings ***
Documentation    Verify timeranges
Suite Setup      Login FMC
Default Tags     fmc    day1    config    timeranges
Resource    ../../fmc_common.resource

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}

Get All Time Ranges - Domain {{ domain.name }}
    ${TIMERANGES}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/timeranges?
    Set Global Variable    ${TIMERANGES}

{% for timerange in domain.objects.time_ranges | default([]) %}
Verify Time range - {{ timerange.name }}
    Run Keyword If    '{{ timerange.name }}' not in @{TIMERANGES}    Fail    Item not found on FMC
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.name                         {{ timerange.name }}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.description                  {{ timerange.description }}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.effectiveStartDateTime       {{ timerange.effective_start_date }}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.effectiveEndDateTime         {{ timerange.effective_end_date }}

{% for recurrence in timerange.recurrences %}
Verify Time range - {{ timerange.name }} - Recurrence {{ loop.index }}
    {% if recurrence.recurrence_type == "DAILY_INTERVAL" %}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.recurrenceList[{{loop.index0}}].recurrenceType     {{ recurrence.recurrence_type }}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.recurrenceList[{{loop.index0}}].dailyEndTime       {{ recurrence.daily_end_time }}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.recurrenceList[{{loop.index0}}].dailyStartTime     {{ recurrence.daily_start_time }}
    ${days}=    Evaluate    eval("{{recurrence.days}}")
    Should Be Equal Value Json List      ${TIMERANGES['{{ timerange.name }}']}   $.recurrenceList[{{loop.index0}}].days               ${days}
    {% endif %}

    {% if recurrence.recurrence_type == "RANGE" %}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.recurrenceList[{{loop.index0}}].recurrenceType     {{ recurrence.recurrence_type }}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.recurrenceList[{{loop.index0}}].rangeEndDay        {{ recurrence.end_day }}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.recurrenceList[{{loop.index0}}].rangeEndTime       {{ recurrence.end_time }}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.recurrenceList[{{loop.index0}}].rangeStartDay      {{ recurrence.start_day }}
    Should Be Equal Value Json String    ${TIMERANGES['{{ timerange.name }}']}   $.recurrenceList[{{loop.index0}}].rangeStartTime     {{ recurrence.start_time }}
    {% endif %}

{% endfor %}

{% endfor %}
{% endfor %}