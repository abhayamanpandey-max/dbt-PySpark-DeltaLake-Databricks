with sales as (

    select * from {{ ref('stg_sales') }}

),

returns as (

    select
        sales_id,
        sum(returned_qty) as returned_qty,
        sum(refund_amount) as refund_amount

    from {{ ref('stg_returns') }}
    group by sales_id

),

final as (

    select
        sales.sales_id,
        sales.date_sk,
        sales.store_sk,
        sales.product_sk,
        sales.customer_sk,
        sales.promotion_sk,
        sales.payment_method,
        sales.quantity,
        sales.unit_price,
        sales.gross_amount,
        sales.discount_amount,
        {{ discount_percentage('sales.gross_amount', 'sales.discount_amount') }} as discount_pct,
        sales.net_amount,
        coalesce(returns.returned_qty, 0) as returned_qty,
        coalesce(returns.refund_amount, 0) as refund_amount,
        sales.net_amount - coalesce(returns.refund_amount, 0) as net_amount_after_returns,
        case when returns.sales_id is not null then true else false end as was_returned

    from sales
    left join returns
        on sales.sales_id = returns.sales_id

)

select * from final
