{{ config(
    materialized = 'table'
) }}

with devices as (

    select distinct
        lower(trim(device_category)) as device_category
    from {{ ref('stg_ga4_sessions') }}
    where device_category is not null

)

select
    md5(device_category) as device_key,
    device_category

from devices