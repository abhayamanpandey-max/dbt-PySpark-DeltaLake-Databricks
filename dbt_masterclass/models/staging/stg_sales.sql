with source as (

    select * from {{ ref('fact_sales') }}

)

select
    sales_id,
    date_sk,
    store_sk,
    product_sk,
    customer_sk,
    promotion_sk,
    quantity,
    cast(unit_price as decimal(10,2)) as unit_price,
    cast(gross_amount as decimal(10,2)) as gross_amount,
    cast(discount_amount as decimal(10,2)) as discount_amount,
    cast(net_amount as decimal(10,2)) as net_amount,
    payment_method

from source
