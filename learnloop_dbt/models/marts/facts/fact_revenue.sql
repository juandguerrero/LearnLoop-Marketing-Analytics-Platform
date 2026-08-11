{{ config(
    materialized = 'table'
) }}

with payments as (

    select
        payment_id,
        customer_id,
        subscription_id,
        payment_date,
        payment_status,
        amount,
        refund_amount,
        net_revenue,
        currency,
        refunded

    from {{ ref('stg_stripe_payments') }}

),

subscriptions as (

    select
        subscription_id,
        plan_id

    from {{ ref('int_subscription_metrics') }}

),

subscription_plans as (

    select
        subscription_plan_key,
        plan_id

    from {{ ref('dim_subscription_plan') }}

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

dates as (

    select
        date_key,
        full_date

    from {{ ref('dim_date') }}

),

final as (

    select
        md5(
            coalesce(to_varchar(payments.payment_id), '')
        ) as revenue_key,

        dates.date_key,

        customers.customer_key,

        campaigns.campaign_key,

        subscription_plans.subscription_plan_key,

        payments.payment_id,
        payments.customer_id,
        payments.subscription_id,
        subscriptions.plan_id,

        payments.payment_date,
        payments.payment_status,

        payments.amount,
        payments.refund_amount,
        payments.net_revenue,
        payments.currency,
        payments.refunded,

        case
            when lower(payments.payment_status) = 'succeeded'
                then 1
            else 0
        end as successful_payment_count,

        case
            when payments.refunded = true
                then 1
            else 0
        end as refunded_payment_count

    from payments

    inner join customers
        on payments.customer_id = customers.customer_id

    inner join dates
        on payments.payment_date = dates.full_date

    inner join subscriptions
        on payments.subscription_id = subscriptions.subscription_id

    inner join subscription_plans
        on subscriptions.plan_id = subscription_plans.plan_id

    left join campaigns
        on customers.acquisition_campaign_id = campaigns.campaign_id

)

select *
from final