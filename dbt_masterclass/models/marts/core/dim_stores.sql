with stores as (

    select * from {{ ref('stg_stores') }}

)

select
    store_sk,
    store_code,
    store_name,
    city,
    state_province,
    region,
    country,
    open_date,
    sq_ft,
    datediff(current_date(), open_date) as days_in_operation

from stores
