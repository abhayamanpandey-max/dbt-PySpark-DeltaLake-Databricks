with bronze_returns as (
    select 
        sales_id,
        date_sk,
        store_sk,
        product_sk,
        returned_qty,
        return_reason,
        refund_amount
    from {{ ref('bronze_returns') }}
),
bronze_products as (
    select 
        product_sk, 
        product_name, 
        category
    from {{ ref('bronze_product') }}
),
joined_query as (
select 
    bronze_returns.sales_id,
    bronze_returns.date_sk,
    bronze_returns.store_sk,
    bronze_returns.returned_qty,
    bronze_returns.return_reason,
    bronze_returns.refund_amount,
    bronze_products.product_name,
    bronze_products.category
from bronze_returns
join 
   bronze_products ON bronze_returns.product_sk = bronze_products.product_sk
)

select 
    category,
    return_reason,
    sum(returned_qty) as total_returned_qty,
    sum(refund_amount) as total_refund_amount
from joined_query
group by 
    category,
    return_reason
order by 
    total_refund_amount desc
    