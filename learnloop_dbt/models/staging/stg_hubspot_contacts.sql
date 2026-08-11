with source as (

    select
        raw_data,
        source_file,
        loaded_at

    from {{ source('raw', 'hubspot_contacts') }}

),

flattened as (

    select
        contact_record.value as contact_data,
        source.source_file,
        source.loaded_at

    from source,
    lateral flatten(
        input => source.raw_data:data
    ) as contact_record

)

select

    contact_data:lead_id::varchar            as lead_id,
    contact_data:user_id::varchar            as user_id,
    contact_data:session_id::varchar         as session_id,
    contact_data:campaign_id::varchar        as campaign_id,

    contact_data:first_name::varchar         as first_name,
    contact_data:last_name::varchar          as last_name,
    contact_data:email::varchar              as email,
    contact_data:company_name::varchar       as company_name,
    contact_data:country::varchar            as country,

    contact_data:lifecycle_stage::varchar    as lifecycle_stage,
    contact_data:original_source::varchar    as original_source,

    contact_data:is_mql::boolean             as is_mql,
    contact_data:is_sql::boolean             as is_sql,
    contact_data:is_customer::boolean        as is_customer,

    contact_data:created_date::date          as created_date,

    source_file,
    loaded_at

from flattened