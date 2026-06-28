with source as (

    select * from {{ ref('dim_customer') }}

)

select
    customer_sk,
    customer_code,
    first_name,
    last_name,
    first_name || ' ' || last_name as customer_full_name,
    gender,
    lower(email) as email,
    phone,
    loyalty_tier,
    cast(signup_date as date) as signup_date

from source
