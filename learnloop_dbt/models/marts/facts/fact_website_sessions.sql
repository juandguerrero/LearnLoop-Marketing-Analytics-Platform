{{ config(
    materialized = 'table'
) }}

with sessions as (

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

campaigns as (

    select
        campaign_key,
        campaign_id,
        platform

    from {{ ref('dim_campaign') }}

),

channels as (

    select
        channel_key,
        channel_name

    from {{ ref('dim_channel') }}

),

devices as (

    select
        device_key,
        device_category

    from {{ ref('dim_device') }}

),

dates as (

    select
        date_key,
        full_date

    from {{ ref('dim_date') }}

),

ranked_customers as (

    select
        customer_key,
        customer_id,
        user_id,
        first_payment_date,

        row_number() over (
            partition by user_id
            order by
                first_payment_date asc nulls last,
                customer_id asc
        ) as customer_rank

    from {{ ref('dim_customer') }}

    where user_id is not null

),

customers as (

    select
        customer_key,
        user_id

    from ranked_customers

    where customer_rank = 1

),

final as (

    select
        md5(
            coalesce(
                to_varchar(sessions.session_id),
                ''
            )
        ) as session_key,

        dates.date_key as session_date_key,

        campaigns.campaign_key,

        channels.channel_key,

        devices.device_key,

        customers.customer_key,

        sessions.session_id,
        sessions.user_id,
        sessions.session_date,

        campaigns.platform,

        sessions.campaign_id,
        sessions.campaign_name,

        sessions.traffic_source,
        sessions.traffic_medium,
        sessions.country,
        sessions.device_category,
        sessions.landing_page,

        sessions.page_views,
        sessions.engaged_session,
        sessions.bounced_session,

        1 as session_count,

        case
            when sessions.engaged_session = true then 1
            else 0
        end as engaged_session_count,

        case
            when sessions.bounced_session = true then 1
            else 0
        end as bounced_session_count

    from sessions

    inner join dates
        on sessions.session_date = dates.full_date

    inner join campaigns
        on sessions.campaign_id = campaigns.campaign_id

    inner join channels
        on lower(trim(sessions.traffic_source)) = channels.channel_name

    inner join devices
        on lower(trim(sessions.device_category)) = devices.device_category

    left join customers
        on sessions.user_id = customers.user_id

)

select *
from final