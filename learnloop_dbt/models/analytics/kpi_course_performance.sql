with enrollments as (

    select
        enrollment_date_key as date_key,
        course_key,

        count(*) as enrollment_records,

        sum(enrollment_count) as enrollments,
        sum(completion_count) as completions,
        sum(incomplete_enrollment_count) as incomplete_enrollments,

        avg(progress_percentage) as avg_progress_percentage,

        count(distinct customer_key) as customers

    from {{ ref('fact_course_enrollments') }}

    group by
        enrollment_date_key,
        course_key

),

courses as (

    select
        course_key,
        course_id,
        course_name,
        course_category

    from {{ ref('dim_course') }}

),

final as (

    select
        enrollments.date_key,
        enrollments.course_key,

        courses.course_id,
        courses.course_name,
        courses.course_category,

        enrollments.enrollment_records,
        enrollments.enrollments,
        enrollments.completions,
        enrollments.incomplete_enrollments,
        enrollments.customers,

        enrollments.avg_progress_percentage,

        enrollments.completions
            / nullif(enrollments.enrollments, 0)::float
            as completion_rate

    from enrollments

    inner join courses
        on enrollments.course_key = courses.course_key

)

select *
from final