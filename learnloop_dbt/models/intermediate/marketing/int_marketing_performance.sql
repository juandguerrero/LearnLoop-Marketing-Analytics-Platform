with google_ads as (

    select
        campaign_date as performance_date,
        'google_ads' as platform,
        campaign_id,
        campaign_name,
        campaign_type,
        impressions,
        clicks,
        cost as ad_spend
    from {{ ref('stg_google_ads') }}

),

meta_ads as (

    select
        campaign_date as performance_date,
        'meta_ads' as platform,
        campaign_id,
        campaign_name,
        campaign_type,
        impressions,
        clicks,
        cost as ad_spend
    from {{ ref('stg_meta_ads') }}

),

combined_platforms as (

    select * from google_ads

    union all

    select * from meta_ads

),

final as (

    select
        md5(
            concat_ws(
                '||',
                coalesce(to_varchar(performance_date), ''),
                coalesce(platform, ''),
                coalesce(to_varchar(campaign_id), '')
            )
        ) as marketing_performance_id,

        performance_date,
        platform,
        campaign_id,
        campaign_name,
        campaign_type,
        impressions,
        clicks,
        ad_spend,

        ad_spend / nullif(clicks, 0) as cost_per_click,
        clicks / nullif(impressions, 0) as click_through_rate

    from combined_platforms

)

select * from final