with customer_revenue as (

    select
        customer_id,
        lead_id,

        successful_payment_count,
        gross_revenue,
        total_refund_amount,
        total_revenue,

        first_payment_date,
        last_payment_date,

        latest_subscription_id,
        latest_subscription_status,
        latest_plan_id,
        latest_plan_name,
        latest_monthly_price,
        subscription_start_date,

        is_active_subscriber

    from {{ ref('int_customer_revenue') }}

),

customer_acquisition as (

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

        session_date as acquisition_session_date,

        campaign_id,
        campaign_name,

        traffic_source,
        traffic_medium,
        device_category,
        country,
        landing_page,

        page_views,
        engaged_session,
        bounced_session

    from {{ ref('int_customer_acquisition') }}

),

final as (

    select
        md5(
            coalesce(to_varchar(revenue.customer_id), '')
        ) as customer_key,

        revenue.customer_id,
        revenue.lead_id,

        acquisition.user_id,
        acquisition.session_id,

        acquisition.lead_created_date,
        acquisition.lifecycle_stage,
        acquisition.original_source,

        acquisition.is_mql,
        acquisition.is_sql,
        acquisition.is_customer,

        acquisition.acquisition_session_date,

        acquisition.campaign_id as acquisition_campaign_id,
        acquisition.campaign_name as acquisition_campaign_name,

        acquisition.traffic_source,
        acquisition.traffic_medium,
        acquisition.device_category,
        acquisition.country,
        acquisition.landing_page,

        acquisition.page_views,
        acquisition.engaged_session,
        acquisition.bounced_session,

        revenue.successful_payment_count,
        revenue.gross_revenue,
        revenue.total_refund_amount,
        revenue.total_revenue,

        revenue.first_payment_date,
        revenue.last_payment_date,

        revenue.latest_subscription_id,
        revenue.latest_subscription_status,
        revenue.latest_plan_id,
        revenue.latest_plan_name,
        revenue.latest_monthly_price,
        revenue.subscription_start_date,

        revenue.is_active_subscriber

    from customer_revenue as revenue

    left join customer_acquisition as acquisition
        on revenue.lead_id = acquisition.lead_id

)

select *
from final