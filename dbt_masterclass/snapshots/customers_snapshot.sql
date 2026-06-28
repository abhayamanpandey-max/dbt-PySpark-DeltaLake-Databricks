{% snapshot customers_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_sk',
        strategy='check',
        check_cols=['loyalty_tier', 'email', 'phone'],
    )
}}

select * from {{ ref('dim_customer') }}

{% endsnapshot %}
