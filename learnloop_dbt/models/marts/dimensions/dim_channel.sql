{{ config(
    materialized = 'table'
) }}

with advertising_channels as (

    select distinct
        lower(trim(platform)) as channel_name,
        'paid advertising' as channel_group
    from {{ ref('int_marketing_performance') }}
    where platform is not null

),

website_channels as (

    select distinct
        lower(trim(traffic_source)) as channel_name,

        case
            when lower(trim(traffic_medium)) = 'paid'
                then 'paid advertising'

            when lower(trim(traffic_medium)) in ('organic', 'organic_search')
                then 'organic'

            when lower(trim(traffic_medium)) = 'email'
                then 'email'

            when lower(trim(traffic_medium)) = 'referral'
                then 'referral'

            when lower(trim(traffic_source)) = 'direct'
                then 'direct'

            else coalesce(
                lower(trim(traffic_medium)),
                'other'
            )
        end as channel_group

    from {{ ref('stg_ga4_sessions') }}
    where traffic_source is not null

),

combined_channels as (

    select
        channel_name,
        channel_group
    from advertising_channels

    union

    select
        channel_name,
        channel_group
    from website_channels

),

deduplicated_channels as (

    select
        channel_name,
        min(channel_group) as channel_group
    from combined_channels
    group by channel_name

)

select
    md5(channel_name) as channel_key,
    channel_name,
    channel_group

from deduplicated_channels