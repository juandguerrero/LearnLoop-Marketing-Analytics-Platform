{{ config(
    materialized = 'table'
) }}

with revenue as (

    select
        customer_key,
        campaign_key,
        subscription_plan_key,

        payment_date,
        amount,
        refund_amount,
        net_revenue,
        successful_payment_count,
        refunded_payment_count

    from {{ ref('fact_revenue') }}

),

customer_revenue as (

    select
        customer_key,

        max(campaign_key) as campaign_key,
        max(subscription_plan_key) as subscription_plan_key,

        count(*) as payment_records,

        sum(successful_payment_count) as successful_payments,
        sum(refunded_payment_count) as refunded_payments,

        sum(amount) as gross_revenue,
        sum(refund_amount) as total_refunds,
        sum(net_revenue) as lifetime_value,

        min(payment_date) as first_payment_date,
        max(payment_date) as last_payment_date

    from revenue

    group by customer_key

),

final as (

    select
        customer_revenue.customer_key,

        customer.customer_id,
        customer.lead_id,
        customer.user_id,

        customer_revenue.campaign_key,
        campaign.platform,
        campaign.campaign_id,
        campaign.campaign_name,

        customer_revenue.subscription_plan_key,
        plan.plan_id,
        plan.plan_name,

        customer_revenue.payment_records,
        customer_revenue.successful_payments,
        customer_revenue.refunded_payments,

        customer_revenue.gross_revenue,
        customer_revenue.total_refunds,
        customer_revenue.lifetime_value,

        customer_revenue.first_payment_date,
        customer_revenue.last_payment_date,

        customer_revenue.lifetime_value
            / nullif(customer_revenue.successful_payments, 0)
            as average_revenue_per_successful_payment

    from customer_revenue

    inner join {{ ref('dim_customer') }} as customer
        on customer_revenue.customer_key = customer.customer_key

    left join {{ ref('dim_campaign') }} as campaign
        on customer_revenue.campaign_key = campaign.campaign_key

    left join {{ ref('dim_subscription_plan') }} as plan
        on customer_revenue.subscription_plan_key = plan.subscription_plan_key

)

select *
from final