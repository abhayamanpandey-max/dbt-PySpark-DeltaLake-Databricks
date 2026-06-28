{% snapshot customer_snapshot %}

{{
    config(
      target_schema='silver',
      unique_key='customer_sk',
      strategy='check',
      check_cols=['loyalty_tier', 'email', 'phone', 'first_name', 'last_name'],
    )
}}

select 
    customer_sk,
    customer_code,
    first_name,
    last_name,
    gender,
    email,
    phone,
    loyalty_tier,
    signup_date
from {{ ref('bronze_customer') }}

{% endsnapshot %}