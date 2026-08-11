with campaigns as (

    select
        platform,
        campaign_id,
        campaign_name,
        campaign_type

    from {{ ref('int_marketing_performance') }}

),

deduplicated_campaigns as (

    select
        platform,
        campaign_id,

        max(campaign_name) as campaign_name,
        max(campaign_type) as campaign_type

    from campaigns

    group by
        platform,
        campaign_id

),

final as (

    select
        md5(
            concat_ws(
                '||',
                coalesce(platform, ''),
                coalesce(to_varchar(campaign_id), '')
            )
        ) as campaign_key,

        platform,
        campaign_id,
        campaign_name,
        campaign_type

    from deduplicated_campaigns

)

select *
from final