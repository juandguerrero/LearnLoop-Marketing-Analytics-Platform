with source as (

    select
        raw_data,
        source_file,
        loaded_at

    from {{ source('raw', 'ga4_sessions') }}

),

flattened as (

    select
        session_record.value as session_data,
        source.source_file,
        source.loaded_at

    from source,
    lateral flatten(
        input => source.raw_data:data
    ) as session_record

),

typed as (

    select
        session_data:session_id::varchar as session_id,
        session_data:user_id::varchar as user_id,
        session_data:session_date::date as session_date,

        session_data:campaign_id::varchar as campaign_id,
        session_data:campaign_name::varchar as campaign_name,

        session_data:source::varchar as traffic_source,
        session_data:medium::varchar as traffic_medium,

        session_data:country::varchar as country,
        session_data:device_category::varchar as device_category,
        session_data:landing_page::varchar as landing_page,

        session_data:page_views::integer as page_views,
        session_data:session_duration_seconds::integer
            as session_duration_seconds,

        session_data:engaged_session::boolean as engaged_session,
        session_data:bounce::boolean as bounced_session,

        source_file,
        loaded_at

    from flattened

)

select *
from typed