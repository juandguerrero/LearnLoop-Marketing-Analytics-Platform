with source as (

    select
        raw_data:data as enrollments

    from {{ source('raw', 'learnloop_course_enrollments') }}

),

flattened as (

    select
        enrollment_record.value as enrollment

    from source,
    lateral flatten(
        input => source.enrollments
    ) as enrollment_record

)

select
    enrollment:enrollment_id::varchar as enrollment_id,
    enrollment:customer_id::varchar as customer_id,
    enrollment:subscription_id::varchar as subscription_id,

    enrollment:course_id::varchar as course_id,
    enrollment:course_name::varchar as course_name,
    enrollment:course_category::varchar as course_category,

    try_to_date(
        enrollment:enrollment_date::varchar
    ) as enrollment_date,

    enrollment:progress_percentage::number(5, 2)
        as progress_percentage,

    enrollment:completed::boolean as completed

from flattened