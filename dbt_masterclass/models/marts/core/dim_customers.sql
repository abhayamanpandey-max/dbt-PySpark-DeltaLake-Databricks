with customers as (

    select * from {{ ref('stg_customers') }}

)

select
    customer_sk,
    customer_code,
    customer_full_name,
    first_name,
    last_name,
    gender,
    email,
    phone,
    loyalty_tier,
    signup_date,
    datediff(current_date(), signup_date) as days_since_signup

from customers
