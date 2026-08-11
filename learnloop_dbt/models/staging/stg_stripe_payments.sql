with source as (

    select
        raw_data,
        source_file,
        loaded_at

    from {{ source('raw', 'stripe_payments') }}

),

flattened as (

    select
        payment_record.value as payment_data,
        source.source_file,
        source.loaded_at

    from source,
    lateral flatten(
        input => source.raw_data:data
    ) as payment_record

)

select
    payment_data:payment_id::varchar          as payment_id,
    payment_data:customer_id::varchar         as customer_id,
    payment_data:subscription_id::varchar     as subscription_id,

    payment_data:payment_date::date           as payment_date,
    payment_data:payment_status::varchar      as payment_status,

    payment_data:amount::number(12,2)         as amount,
    payment_data:refund_amount::number(12,2)  as refund_amount,
    payment_data:net_revenue::number(12,2)    as net_revenue,

    payment_data:currency::varchar            as currency,
    payment_data:refunded::boolean            as refunded,

    source_file,
    loaded_at

from flattened