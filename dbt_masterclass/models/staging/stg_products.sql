with source as (

    select * from {{ ref('dim_product') }}

)

select
    product_sk,
    product_code,
    product_name,
    department,
    category,
    supplier_sk,
    cast(list_price as decimal(10,2)) as list_price,
    uom

from source
