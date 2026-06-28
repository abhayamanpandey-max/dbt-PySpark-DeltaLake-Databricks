with source as (

    select * from {{ ref('dim_store') }}

)

select
    store_sk,
    store_code,
    store_name,
    city,
    state_province,
    region,
    country,
    cast(open_date as date) as open_date,
    sq_ft

from source
