with source as (

    select
        raw_data,
        source_file,
        loaded_at

    from {{ source('raw', 'meta_ads_campaign_performance') }}

),

flattened as (

    select
        performance_record.value as performance_data,
        source.source_file,
        source.loaded_at

    from source,
    lateral flatten(
        input => source.raw_data:data
    ) as performance_record

)

select
    performance_data:campaign_id::varchar       as campaign_id,
    performance_data:campaign_name::varchar     as campaign_name,
    performance_data:campaign_type::varchar     as campaign_type,
    performance_data:date::date                 as campaign_date,
    performance_data:impressions::integer       as impressions,
    performance_data:clicks::integer            as clicks,
    performance_data:cost::number(12,2)         as cost,
    performance_data:average_cpc::number(12,2)  as average_cpc,
    performance_data:ctr::float                 as ctr,
    performance_data:source_system::varchar     as source_system,
    source_file,
    loaded_at

from flattened