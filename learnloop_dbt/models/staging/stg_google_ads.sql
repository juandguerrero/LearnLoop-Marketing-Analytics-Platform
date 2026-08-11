with source as (

    select
        raw_data,
        source_file,
        loaded_at

    from {{ source('raw', 'google_ads_campaign_performance') }}

),

flattened as (

    select
        campaign.value as campaign,
        source_file,
        loaded_at

    from source,
    lateral flatten(
        input => raw_data:data
    ) campaign

)

select

    campaign:campaign_id::varchar          as campaign_id,
    campaign:campaign_name::varchar        as campaign_name,
    campaign:campaign_type::varchar        as campaign_type,

    campaign:date::date                    as campaign_date,

    campaign:impressions::integer          as impressions,
    campaign:clicks::integer               as clicks,
    campaign:cost::number(12,2)            as cost,
    campaign:average_cpc::number(12,2)     as average_cpc,
    campaign:ctr::float                    as ctr,

    campaign:source_system::varchar        as source_system,

    source_file,
    loaded_at

from flattened