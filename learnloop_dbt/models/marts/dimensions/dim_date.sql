with date_bounds as (

    select
        min(date_value) as min_date,
        max(date_value) as max_date

    from (

        select performance_date as date_value
        from {{ ref('int_marketing_performance') }}

        union all

        select lead_created_date
        from {{ ref('int_customer_acquisition') }}

        union all

        select first_payment_date
        from {{ ref('int_customer_revenue') }}
        where first_payment_date is not null

        union all

        select last_payment_date
        from {{ ref('int_customer_revenue') }}
        where last_payment_date is not null

        union all

        select subscription_start_date
        from {{ ref('int_subscription_metrics') }}
        where subscription_start_date is not null

    ) as all_dates

),

generated_dates as (

    select
        dateadd(
            day,
            seq4(),
            min_date
        )::date as full_date,

        max_date

    from date_bounds,
         table(
             generator(
                 rowcount => 5000
             )
         )

),

date_spine as (

    select
        full_date

    from generated_dates

    where full_date <= max_date

),

final as (

    select
        to_number(
            to_char(full_date, 'YYYYMMDD')
        ) as date_key,

        full_date,

        year(full_date) as year,

        quarter(full_date) as quarter_number,

        'Q' || quarter(full_date) as quarter_name,

        month(full_date) as month_number,

        monthname(full_date) as month_name,

        day(full_date) as day_of_month,

        dayofweekiso(full_date) as day_of_week_number,

        dayname(full_date) as day_name,

        weekiso(full_date) as week_of_year,

        case
            when dayofweekiso(full_date) in (6, 7)
                then true
            else false
        end as is_weekend,

        date_trunc('month', full_date)::date as month_start_date,

        last_day(full_date, 'month') as month_end_date,

        date_trunc('quarter', full_date)::date as quarter_start_date,

        last_day(full_date, 'quarter') as quarter_end_date,

        date_trunc('year', full_date)::date as year_start_date,

        last_day(full_date, 'year') as year_end_date

    from date_spine

)

select *
from final
