with subscriptions as (

    select

        subscription_id,
        customer_id,
        lead_id,

        plan_id,
        plan_name,

        monthly_price,

        status,

        subscription_start_date

    from {{ ref('stg_stripe_subscriptions') }}

),

final as (

    select

        subscription_id,

        customer_id,

        lead_id,

        plan_id,

        plan_name,

        monthly_price,

        status as subscription_status,

        subscription_start_date,

        case

            when lower(status) = 'active'
                then true

            else false

        end as is_active_subscription,

        monthly_price as monthly_recurring_revenue,

        monthly_price * 12 as annual_recurring_revenue,

        datediff(
            day,
            subscription_start_date,
            current_date
        ) as subscription_age_days

    from subscriptions

)

select *

from final