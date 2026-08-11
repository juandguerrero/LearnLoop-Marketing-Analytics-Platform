{{ config(
    materialized = 'table'
) }}

with subscriptions as (

    select
        subscription_id,
        customer_id,
        lead_id,
        plan_id,
        plan_name,
        monthly_price,
        subscription_status,
        subscription_start_date,
        is_active_subscription,
        monthly_recurring_revenue,
        annual_recurring_revenue,
        subscription_age_days

    from {{ ref('int_subscription_metrics') }}

),

customers as (

    select
        customer_key,
        customer_id,
        acquisition_campaign_id

    from {{ ref('dim_customer') }}

),

campaigns as (

    select
        campaign_key,
        campaign_id

    from {{ ref('dim_campaign') }}

),

subscription_plans as (

    select
        subscription_plan_key,
        plan_id

    from {{ ref('dim_subscription_plan') }}

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
            coalesce(to_varchar(subscriptions.subscription_id), '')
        ) as subscription_key,

        dates.date_key as subscription_start_date_key,

        customers.customer_key,

        campaigns.campaign_key,

        subscription_plans.subscription_plan_key,

        subscriptions.subscription_id,
        subscriptions.customer_id,
        subscriptions.lead_id,

        subscriptions.plan_id,
        subscriptions.plan_name,
        subscriptions.monthly_price,

        subscriptions.subscription_status,
        subscriptions.subscription_start_date,
        subscriptions.is_active_subscription,

        subscriptions.monthly_recurring_revenue,
        subscriptions.annual_recurring_revenue,
        subscriptions.subscription_age_days,

        1 as subscription_count,

        case
            when subscriptions.is_active_subscription = true then 1
            else 0
        end as active_subscription_count

    from subscriptions

    inner join customers
        on subscriptions.customer_id = customers.customer_id

    inner join dates
        on subscriptions.subscription_start_date = dates.full_date

    inner join subscription_plans
        on subscriptions.plan_id = subscription_plans.plan_id

    left join campaigns
        on customers.acquisition_campaign_id = campaigns.campaign_id

)

select *
from final