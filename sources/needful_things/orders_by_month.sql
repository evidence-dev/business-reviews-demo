select
strftime(order_datetime, '%B') as month,
date_part('year', order_datetime) as year,
sum(sales) as sales_usd,
count(id) as orders,
sum(sales) / count(id) as avg_order_value_usd
from orders
group by 1,2
order by 2 desc, 1 desc