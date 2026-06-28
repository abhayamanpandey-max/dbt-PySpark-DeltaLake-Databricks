with source as (

    select * from {{ ref('dim_date') }}

)

select
    date_sk,
    cast(date as date) as calendar_date,
    day,
    month,
    month_name,
    quarter,
    year,
    day_of_week,
    day_name,
    is_weekend,
    is_month_end,
    is_month_start,
    is_quarter_end,
    is_quarter_start

from source
