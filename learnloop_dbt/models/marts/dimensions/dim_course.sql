with courses as (

    select
        course_id,
        course_name,
        course_category

    from {{ ref('stg_course_enrollments') }}

),

deduplicated_courses as (

    select
        course_id,
        max(course_name) as course_name,
        max(course_category) as course_category

    from courses

    group by course_id

),

final as (

    select
        md5(
            coalesce(
                to_varchar(course_id),
                ''
            )
        ) as course_key,

        course_id,
        course_name,
        course_category

    from deduplicated_courses

)

select *
from final