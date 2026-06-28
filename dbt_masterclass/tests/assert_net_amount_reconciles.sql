-- This test fails if any row is returned.
-- Sanity check that net_amount reconciles with gross_amount - discount_amount,
-- allowing a small rounding tolerance.

select
    sales_id,
    gross_amount,
    discount_amount,
    net_amount
from {{ ref('stg_sales') }}
where abs(net_amount - (gross_amount - discount_amount)) > 0.01
