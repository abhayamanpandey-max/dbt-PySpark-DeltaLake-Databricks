with dates as (

    select * from {{ ref('stg_dates') }}

)

select
    date_sk,
    calendar_date,
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

from dates
