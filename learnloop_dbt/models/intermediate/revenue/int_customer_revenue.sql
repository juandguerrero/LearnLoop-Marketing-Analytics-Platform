with successful_payments as (

    select
        customer_id,
        payment_id,
        subscription_id,
        payment_date,
        amount,
        refund_amount,
        net_revenue,
        currency,
        refunded

    from {{ ref('stg_stripe_payments') }}

    where lower(payment_status) = 'succeeded'

),

customer_payment_summary as (

    select
        customer_id,

        count(distinct payment_id) as successful_payment_count,

        sum(amount) as gross_revenue,

        sum(refund_amount) as total_refund_amount,

        sum(net_revenue) as total_revenue,

        min(payment_date) as first_payment_date,

        max(payment_date) as last_payment_date

    from successful_payments

    group by customer_id

),

ranked_subscriptions as (

    select
        subscription_id,
        customer_id,
        lead_id,
        status as subscription_status,
        plan_id,
        plan_name,
        monthly_price,
        subscription_start_date,

        row_number() over (
            partition by customer_id
            order by
                subscription_start_date desc,
                subscription_id desc
        ) as subscription_rank

    from {{ ref('stg_stripe_subscriptions') }}

),

latest_subscription as (

    select
        subscription_id,
        customer_id,
        lead_id,
        subscription_status,
        plan_id,
        plan_name,
        monthly_price,
        subscription_start_date

    from ranked_subscriptions

    where subscription_rank = 1

),

all_customers as (

    select customer_id
    from customer_payment_summary

    union

    select customer_id
    from latest_subscription

),

final as (

    select
        customers.customer_id,

        subscriptions.lead_id,

        coalesce(
            payments.successful_payment_count,
            0
        ) as successful_payment_count,

        coalesce(
            payments.gross_revenue,
            0
        ) as gross_revenue,

        coalesce(
            payments.total_refund_amount,
            0
        ) as total_refund_amount,

        coalesce(
            payments.total_revenue,
            0
        ) as total_revenue,

        payments.first_payment_date,
        payments.last_payment_date,

        subscriptions.subscription_id as latest_subscription_id,
        subscriptions.subscription_status as latest_subscription_status,
        subscriptions.plan_id as latest_plan_id,
        subscriptions.plan_name as latest_plan_name,
        subscriptions.monthly_price as latest_monthly_price,
        subscriptions.subscription_start_date,

        case
            when lower(subscriptions.subscription_status) = 'active'
                then true
            else false
        end as is_active_subscriber

    from all_customers as customers

    left join customer_payment_summary as payments
        on customers.customer_id = payments.customer_id

    left join latest_subscription as subscriptions
        on customers.customer_id = subscriptions.customer_id

)

select *
from final