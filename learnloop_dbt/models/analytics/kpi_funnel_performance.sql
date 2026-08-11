with sessions as (

    select
        session_date_key as date_key,
        campaign_key,
        channel_key,
        sum(session_count) as sessions

    from {{ ref('fact_website_sessions') }}

    group by 1, 2, 3

),

leads as (

    select
        date_key,
        campaign_key,
        channel_key,

        sum(lead_count) as leads,
        sum(mql_count) as mqls,
        sum(sql_count) as sqls,
        sum(customer_conversion_count) as customers

    from {{ ref('fact_leads') }}

    group by 1, 2, 3

),

final as (

    select
        leads.date_key,
        leads.campaign_key,
        leads.channel_key,

        coalesce(sessions.sessions, 0) as sessions,
        leads.leads,
        leads.mqls,
        leads.sqls,
        leads.customers,

        /* Session → Lead */
        leads.leads
            / nullif(sessions.sessions, 0)
            as session_to_lead_rate,

        /* Lead → MQL */
        leads.mqls
            / nullif(leads.leads, 0)
            as lead_to_mql_rate,

        /* MQL → SQL */
        leads.sqls
            / nullif(leads.mqls, 0)
            as mql_to_sql_rate,

        /* SQL → Customer */
        leads.customers
            / nullif(leads.sqls, 0)
            as sql_to_customer_rate,

        /* Lead → Customer */
        leads.customers
            / nullif(leads.leads, 0)
            as lead_to_customer_rate

    from leads

    left join sessions
        on leads.date_key = sessions.date_key
        and leads.campaign_key = sessions.campaign_key
        and leads.channel_key = sessions.channel_key

)

select *
from final