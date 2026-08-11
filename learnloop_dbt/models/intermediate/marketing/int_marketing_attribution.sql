with marketing_performance as (

    select
        platform,
        campaign_id,
        campaign_name,

        sum(impressions) as total_impressions,
        sum(clicks) as total_clicks,
        sum(ad_spend) as total_ad_spend

    from {{ ref('int_marketing_performance') }}

    group by
        platform,
        campaign_id,
        campaign_name

),

customer_acquisition as (

    select
        lead_id,
        campaign_id,
        campaign_name,
        traffic_source,
        traffic_medium,
        original_source,
        is_mql,
        is_sql,
        is_customer,

        case
            when lower(coalesce(traffic_source, original_source, ''))
                in ('google', 'google ads', 'google_ads')
                then 'google_ads'

            when lower(coalesce(traffic_source, original_source, ''))
                in (
                    'facebook',
                    'instagram',
                    'meta',
                    'meta ads',
                    'meta_ads'
                )
                then 'meta_ads'

            else null
        end as platform

    from {{ ref('int_customer_acquisition') }}

),

customer_revenue as (

    select
        lead_id,
        customer_id,
        successful_payment_count,
        total_revenue

    from {{ ref('int_customer_revenue') }}

),

acquisition_with_revenue as (

    select
        acquisition.platform,
        acquisition.campaign_id,
        acquisition.campaign_name,
        acquisition.traffic_source,
        acquisition.traffic_medium,
        acquisition.lead_id,
        acquisition.is_mql,
        acquisition.is_sql,
        acquisition.is_customer,

        revenue.customer_id,
        coalesce(revenue.successful_payment_count, 0)
            as successful_payment_count,
        coalesce(revenue.total_revenue, 0)
            as attributed_revenue

    from customer_acquisition as acquisition

    left join customer_revenue as revenue
        on acquisition.lead_id = revenue.lead_id

),

campaign_attribution as (

    select
        platform,
        campaign_id,
        campaign_name,

        max(traffic_source) as traffic_source,
        max(traffic_medium) as traffic_medium,

        count(distinct lead_id) as total_leads,

        count(
            distinct case
                when is_mql = true then lead_id
            end
        ) as total_mqls,

        count(
            distinct case
                when is_sql = true then lead_id
            end
        ) as total_sqls,

        count(
            distinct case
                when is_customer = true then lead_id
            end
        ) as acquired_customers,

        count(distinct customer_id) as paying_customers,

        sum(successful_payment_count) as successful_payments,

        sum(attributed_revenue) as attributed_revenue

    from acquisition_with_revenue

    where
        platform is not null
        and campaign_id is not null

    group by
        platform,
        campaign_id,
        campaign_name

),

final as (

    select
        md5(
            concat_ws(
                '||',
                coalesce(marketing.platform, ''),
                coalesce(to_varchar(marketing.campaign_id), '')
            )
        ) as marketing_attribution_id,

        marketing.platform,
        marketing.campaign_id,
        marketing.campaign_name,

        attribution.traffic_source,
        attribution.traffic_medium,

        marketing.total_impressions,
        marketing.total_clicks,
        marketing.total_ad_spend,

        coalesce(attribution.total_leads, 0) as total_leads,
        coalesce(attribution.total_mqls, 0) as total_mqls,
        coalesce(attribution.total_sqls, 0) as total_sqls,

        coalesce(
            attribution.acquired_customers,
            0
        ) as acquired_customers,

        coalesce(
            attribution.paying_customers,
            0
        ) as paying_customers,

        coalesce(
            attribution.successful_payments,
            0
        ) as successful_payments,

        coalesce(
            attribution.attributed_revenue,
            0
        ) as attributed_revenue,

        marketing.total_clicks
            / nullif(marketing.total_impressions, 0)
            as click_through_rate,

        marketing.total_ad_spend
            / nullif(attribution.total_leads, 0)
            as cost_per_lead,

        marketing.total_ad_spend
            / nullif(attribution.acquired_customers, 0)
            as customer_acquisition_cost,

        attribution.acquired_customers
            / nullif(attribution.total_leads, 0)
            as lead_to_customer_rate,

        attribution.attributed_revenue
            / nullif(marketing.total_ad_spend, 0)
            as return_on_ad_spend,

        (
            attribution.attributed_revenue
            - marketing.total_ad_spend
        )
            / nullif(marketing.total_ad_spend, 0)
            as marketing_roi

    from marketing_performance as marketing

    left join campaign_attribution as attribution
        on marketing.platform = attribution.platform
        and marketing.campaign_id = attribution.campaign_id

)

select *
from final