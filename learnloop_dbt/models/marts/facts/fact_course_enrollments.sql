{{ config(
    materialized = 'table'
) }}

with enrollments as (

    select
        enrollment_id,
        customer_id,
        subscription_id,
        course_id,
        enrollment_date,
        progress_percentage,
        completed

    from {{ ref('stg_course_enrollments') }}

),

courses as (

    select
        course_key,
        course_id

    from {{ ref('dim_course') }}

),

customers as (

    select
        customer_key,
        customer_id

    from {{ ref('dim_customer') }}

),

dates as (

    select
        date_key,
        full_date

    from {{ ref('dim_date') }}

),

final as (

    select
        md5(
            coalesce(
                to_varchar(enrollments.enrollment_id),
                ''
            )
        ) as enrollment_key,

        dates.date_key as enrollment_date_key,

        customers.customer_key,

        courses.course_key,

        enrollments.enrollment_id,
        enrollments.customer_id,
        enrollments.subscription_id,
        enrollments.course_id,

        enrollments.enrollment_date,
        enrollments.progress_percentage,
        enrollments.completed,

        1 as enrollment_count,

        case
            when enrollments.completed = true then 1
            else 0
        end as completion_count,

        case
            when enrollments.completed = false then 1
            else 0
        end as incomplete_enrollment_count

    from enrollments

    inner join customers
        on enrollments.customer_id = customers.customer_id

    inner join courses
        on enrollments.course_id = courses.course_id

    inner join dates
        on enrollments.enrollment_date = dates.full_date

)

select *
from final