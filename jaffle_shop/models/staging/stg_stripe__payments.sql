with
source as (
    select * from{{ source('stripe', 'payments') }}
--  select * from dbt_user_raw_stripe.payments
),
transformed as (
    select
        id as payment_id,
        orderid as order_id,
        paymentmethod as payment_method,
        status as payment_status,

        -- amount is stored in cents, convert it to dollars
        amount / 100 as amount,
        created as created_at,
        _batched_at
    from source
)
select * from transformed
