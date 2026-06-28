with sales as (

    select * from {{ ref('fct_sales') }}

),

dates as (

    select * from {{ ref('dim_dates') }}

),

stores as (

    select * from {{ ref('dim_stores') }}

),

daily as (

    select
        sales.date_sk,
        sales.store_sk,
        count(distinct sales.sales_id) as total_transactions,
        sum(sales.quantity) as total_units_sold,
        sum(sales.gross_amount) as gross_revenue,
        sum(sales.discount_amount) as total_discounts,
        sum(sales.net_amount) as net_revenue,
        sum(sales.refund_amount) as total_refunds,
        sum(sales.net_amount_after_returns) as net_revenue_after_returns,
        sum(case when sales.was_returned then 1 else 0 end) as returned_transactions

    from sales
    group by sales.date_sk, sales.store_sk

)

select
    daily.date_sk,
    dates.calendar_date,
    dates.year,
    dates.month,
    dates.month_name,
    dates.is_weekend,
    daily.store_sk,
    stores.store_name,
    stores.region,
    daily.total_transactions,
    daily.total_units_sold,
    daily.gross_revenue,
    daily.total_discounts,
    daily.net_revenue,
    daily.total_refunds,
    daily.net_revenue_after_returns,
    daily.returned_transactions

from daily
left join dates on daily.date_sk = dates.date_sk
left join stores on daily.store_sk = stores.store_sk
