{{ config(
    materialized = 'table'
) }}

with customer_acquisition as (

    select
        lead_id,
        user_id,
        session_id,

        lead_created_date,
        lifecycle_stage,
        original_source,

        is_mql,
        is_sql,
        is_customer,

        campaign_id,
        campaign_name,
        traffic_source,
        traffic_medium,

        page_views,
        engaged_session,
        bounced_session

    from {{ ref('int_customer_acquisition') }}

),

campaigns as (

    select
        campaign_key,
        platform,
        campaign_id

    from {{ ref('dim_campaign') }}

),

channels as (

    select
        channel_key,
        channel_name

    from {{ ref('dim_channel') }}

),

dates as (

    select
        date_key,
        full_date

    from {{ ref('dim_date') }}

),

customers as (

    select
        customer_key,
        customer_id,
        lead_id

    from {{ ref('dim_customer') }}

),

final as (

    select
        md5(
            coalesce(to_varchar(acquisition.lead_id), '')
        ) as lead_key,

        dates.date_key,
        campaigns.campaign_key,
        channels.channel_key,
        customers.customer_key,

        acquisition.lead_id,
        customers.customer_id,

        acquisition.user_id,
        acquisition.session_id,

        acquisition.lead_created_date,
        acquisition.lifecycle_stage,
        acquisition.original_source,

        campaigns.platform,
        acquisition.campaign_id,
        acquisition.campaign_name,

        acquisition.traffic_source,
        acquisition.traffic_medium,

        acquisition.is_mql,
        acquisition.is_sql,
        acquisition.is_customer,

        acquisition.page_views,
        acquisition.engaged_session,
        acquisition.bounced_session,

        1 as lead_count,

        case
            when acquisition.is_mql = true then 1
            else 0
        end as mql_count,

        case
            when acquisition.is_sql = true then 1
            else 0
        end as sql_count,

        case
            when acquisition.is_customer = true then 1
            else 0
        end as customer_conversion_count

    from customer_acquisition as acquisition

    inner join dates
        on acquisition.lead_created_date = dates.full_date

    inner join campaigns
        on acquisition.campaign_id = campaigns.campaign_id

    inner join channels
        on lower(trim(acquisition.traffic_source)) = channels.channel_name

    left join customers
        on acquisition.lead_id = customers.lead_id

)

select *
from final