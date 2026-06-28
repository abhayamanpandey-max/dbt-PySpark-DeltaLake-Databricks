with products as (

    select * from {{ ref('stg_products') }}

)

select
    product_sk,
    product_code,
    product_name,
    department,
    category,
    supplier_sk,
    list_price,
    uom

from products
