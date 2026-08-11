{{ config(
    materialized = 'table'
) }}

with subscription_plans as (

    select
        plan_id,
        plan_name,
        monthly_price
    from {{ ref('stg_stripe_subscriptions') }}
    where plan_id is not null

),

deduplicated as (

    select
        plan_id,
        max(plan_name) as plan_name,
        max(monthly_price) as monthly_price
    from subscription_plans
    group by plan_id

)

select
    md5(plan_id) as subscription_plan_key,
    plan_id,
    plan_name,
    monthly_price,
    monthly_price * 12 as annual_price

from deduplicated