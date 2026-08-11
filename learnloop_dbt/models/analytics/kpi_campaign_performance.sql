{{ config(
    materialized = 'table'
) }}

with marketing_spend as (

    select
        date_key,
        campaign_key,
        channel_key,

        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(ad_spend) as ad_spend

    from {{ ref('fact_marketing_spend') }}

    group by
        date_key,
        campaign_key,
        channel_key

),

leads as (

    select
        date_key,
        campaign_key,
        channel_key,

        sum(lead_count) as leads,
        sum(mql_count) as mqls,
        sum(sql_count) as sqls,
        sum(customer_conversion_count) as customers

    from {{ ref('fact_leads') }}

    group by
        date_key,
        campaign_key,
        channel_key

),

revenue as (

    select
        date_key,
        campaign_key,

        sum(
            case
                when lower(payment_status) = 'succeeded'
                    then net_revenue
                else 0
            end
        ) as revenue

    from {{ ref('fact_revenue') }}

    group by
        date_key,
        campaign_key

),

final as (

    select
        spend.date_key,
        spend.campaign_key,
        spend.channel_key,

        campaign.platform,
        campaign.campaign_id,
        campaign.campaign_name,

        channel.channel_name,
        channel.channel_group,

        spend.impressions,
        spend.clicks,
        spend.ad_spend,

        coalesce(leads.leads, 0) as leads,
        coalesce(leads.mqls, 0) as mqls,
        coalesce(leads.sqls, 0) as sqls,
        coalesce(leads.customers, 0) as customers,

        coalesce(revenue.revenue, 0) as revenue,

        spend.clicks / nullif(spend.impressions, 0) as click_through_rate,

        spend.ad_spend / nullif(spend.clicks, 0) as cost_per_click,

        spend.ad_spend / nullif(leads.leads, 0) as cost_per_lead,

        spend.ad_spend / nullif(leads.customers, 0) as customer_acquisition_cost,

        revenue.revenue / nullif(spend.ad_spend, 0) as return_on_ad_spend,

        (
            revenue.revenue - spend.ad_spend
        ) / nullif(spend.ad_spend, 0) as return_on_investment

    from marketing_spend as spend

    inner join {{ ref('dim_campaign') }} as campaign
        on spend.campaign_key = campaign.campaign_key

    inner join {{ ref('dim_channel') }} as channel
        on spend.channel_key = channel.channel_key

    left join leads
        on spend.date_key = leads.date_key
        and spend.campaign_key = leads.campaign_key
        and spend.channel_key = leads.channel_key

    left join revenue
        on spend.date_key = revenue.date_key
        and spend.campaign_key = revenue.campaign_key

)

select *
from final