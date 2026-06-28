with bronze_sales as (
    select 
        sales_id,
        product_sk,
        customer_sk, 
        date_sk, 
        {{ multiply('unit_price','quantity')}} as calculated_gross_amount,
        gross_amount,
        net_amount,
        payment_method
    from {{ ref('bronze_sales') }}
),
bronze_products as (
    select 
        product_sk, 
        product_name, 
        category
    from {{ ref('bronze_product') }}
),
bronze_customers as (
    select 
        customer_sk, 
        gender,
        customer_code, 
        first_name,
        email
    from {{ ref('bronze_customer') }}
),
joined_query as (
select 
    bronze_sales.sales_id,
    bronze_sales.gross_amount,
    bronze_product.product_name,
    bronze_product.category,
    bronze_sales.customer_sk,
    bronze_customer.gender,
    bronze_customer.customer_code,
    bronze_customer.first_name,
    bronze_customer.email,
    bronze_sales.payment_method
from bronze_sales
join 
   bronze_product ON bronze_sales.product_sk = bronze_product.product_sk
join
   bronze_customer ON bronze_sales.customer_sk = bronze_customer.customer_sk
)

select 
    sum(gross_amount) as total_gross_amount,
    category,
    gender
from joined_query
group by 
    category,
    gender
order by 
    total_gross_amount desc  
