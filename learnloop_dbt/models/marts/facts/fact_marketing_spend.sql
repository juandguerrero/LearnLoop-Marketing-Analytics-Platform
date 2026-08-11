{{ config(
    materialized = 'table'
) }}

with marketing_performance as (

    select
        performance_date,
        platform,
        campaign_id,
        impressions,
        clicks,
        ad_spend,
        cost_per_click,
        click_through_rate

    from {{ ref('int_marketing_performance') }}

),

campaigns as (

    select
        campaign_key,
        platform,
        campaign_id

    from {{ ref('dim_campaign') }}

),

channels as (

    select
        channel_key,
        channel_name

    from {{ ref('dim_channel') }}

),

dates as (

    select
        date_key,
        full_date

    from {{ ref('dim_date') }}

),

final as (

    select
        md5(
            concat_ws(
                '||',
                coalesce(to_varchar(marketing.performance_date), ''),
                coalesce(marketing.platform, ''),
                coalesce(to_varchar(marketing.campaign_id), '')
            )
        ) as marketing_spend_key,

        dates.date_key,

        campaigns.campaign_key,

        channels.channel_key,

        marketing.performance_date,

        marketing.platform,

        marketing.campaign_id,

        marketing.impressions,

        marketing.clicks,

        marketing.ad_spend,

        marketing.cost_per_click,

        marketing.click_through_rate

    from marketing_performance as marketing

    inner join campaigns
        on lower(trim(marketing.platform)) = lower(trim(campaigns.platform))
        and marketing.campaign_id = campaigns.campaign_id

    inner join dates
        on marketing.performance_date = dates.full_date

    inner join channels
        on lower(trim(marketing.platform)) = channels.channel_name

)

select *
from final