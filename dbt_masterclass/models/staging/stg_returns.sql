with source as (

    select * from {{ ref('fact_returns') }}

)

select
    sales_id,
    date_sk,
    store_sk,
    product_sk,
    returned_qty,
    return_reason,
    cast(refund_amount as decimal(10,2)) as refund_amount

from source
