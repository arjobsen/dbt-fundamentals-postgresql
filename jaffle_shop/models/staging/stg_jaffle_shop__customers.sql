with
source as (
    select * from{{ source('jaffle_shop', 'customers') }}
--  select * from dbt_user_raw_jaffle_shop.customers
),
renamed as (
    select
        id as customer_id,
        first_name,
        last_name
    from source
)
select * from renamed
