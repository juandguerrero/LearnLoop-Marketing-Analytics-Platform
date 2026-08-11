{{ config(
    materialized = 'table'
) }}

with subscriptions as (

    select
        subscription_start_date_key as date_key,
        campaign_key,
        customer_key,
        subscription_plan_key,

        subscription_count,
        active_subscription_count,
        monthly_recurring_revenue,
        annual_recurring_revenue

    from {{ ref('fact_subscriptions') }}

),

aggregated as (

    select
        date_key,
        campaign_key,
        subscription_plan_key,

        sum(subscription_count) as subscriptions,
        sum(active_subscription_count) as active_subscriptions,

        sum(monthly_recurring_revenue) as mrr,
        sum(annual_recurring_revenue) as arr,

        count(distinct customer_key) as customers

    from subscriptions

    group by
        date_key,
        campaign_key,
        subscription_plan_key

),

final as (

    select
        aggregated.date_key,
        aggregated.campaign_key,
        aggregated.subscription_plan_key,

        campaign.platform,
        campaign.campaign_id,
        campaign.campaign_name,

        plan.plan_id,
        plan.plan_name,
        plan.monthly_price,
        plan.annual_price,

        aggregated.subscriptions,
        aggregated.active_subscriptions,
        aggregated.customers,
        aggregated.mrr,
        aggregated.arr,

        aggregated.active_subscriptions
            / nullif(aggregated.subscriptions, 0)
            as active_subscription_rate,

        aggregated.mrr
            / nullif(aggregated.active_subscriptions, 0)
            as average_mrr_per_active_subscription

    from aggregated

    left join {{ ref('dim_campaign') }} as campaign
        on aggregated.campaign_key = campaign.campaign_key

    inner join {{ ref('dim_subscription_plan') }} as plan
        on aggregated.subscription_plan_key = plan.subscription_plan_key

)

select *
from final