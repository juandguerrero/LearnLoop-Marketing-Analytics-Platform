with source as (

    select
        raw_data,
        source_file,
        loaded_at

    from {{ source('raw', 'stripe_subscriptions') }}

),

flattened as (

    select
        subscription_record.value as subscription_data,
        source.source_file,
        source.loaded_at

    from source,
    lateral flatten(
        input => source.raw_data:data
    ) as subscription_record

)

select
    subscription_data:subscription_id::varchar as subscription_id,
    subscription_data:customer_id::varchar as customer_id,
    subscription_data:lead_id::varchar as lead_id,

    subscription_data:plan_id::varchar as plan_id,
    subscription_data:plan_name::varchar as plan_name,

    subscription_data:status::varchar as status,

    try_to_date(
        subscription_data:subscription_start_date::varchar
    ) as subscription_start_date,

    try_to_date(
        subscription_data:subscription_end_date::varchar
    ) as subscription_end_date,

    subscription_data:monthly_price::number(12, 2) as monthly_price,

    source_file,
    loaded_at

from flattened