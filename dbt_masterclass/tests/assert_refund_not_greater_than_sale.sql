-- This test fails if any row is returned.
-- A refund should never exceed the net amount of the original sale.

select
    sales_id,
    net_amount,
    refund_amount
from {{ ref('fct_sales') }}
where refund_amount > net_amount
