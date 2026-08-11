with hubspot as (

    select
        lead_id,
        user_id,
        session_id,
        campaign_id,
        original_source,
        lifecycle_stage,
        is_mql,
        is_sql,
        is_customer,
        country,
        created_date

    from {{ ref('stg_hubspot_contacts') }}

),

ga4 as (

    select
        session_id,
        user_id,
        session_date,
        campaign_id,
        campaign_name,
        traffic_source,
        traffic_medium,
        country,
        device_category,
        landing_page,
        page_views,
        engaged_session,
        bounced_session

    from {{ ref('stg_ga4_sessions') }}

),

final as (

    select
        h.lead_id,
        h.user_id,
        h.session_id,
        h.created_date as lead_created_date,
        h.lifecycle_stage,
        h.original_source,
        h.is_mql,
        h.is_sql,
        h.is_customer,

        g.session_date,

        coalesce(
            g.campaign_id,
            h.campaign_id
        ) as campaign_id,

        g.campaign_name,
        g.traffic_source,
        g.traffic_medium,
        g.device_category,

        coalesce(
            g.country,
            h.country
        ) as country,

        g.landing_page,
        g.page_views,
        g.engaged_session,
        g.bounced_session

    from hubspot as h

    left join ga4 as g
        on h.session_id = g.session_id

)

select *
from final