select 
lpad(date_part('week', order_datetime),2,'0') as week,
date_part('year', order_datetime) as year,
date_part('year', order_datetime) || '/' || lpad(date_part('week', order_datetime),2,'0') as link,
sum(sales) as sales_usd,
count(id) as total_orders,
sum(sales) / count(id) as avg_order_value_usd,
lag(sales_usd) over (order by link) as last_week_sales_usd,
sales_usd / last_week_sales_usd -1 as sales_growth,
lag(total_orders) over (order by link) as last_week_total_orders,
total_orders*1.0 / last_week_total_orders*1.0 -1 as orders_growth,
lag(avg_order_value_usd) over (order by link) as last_week_avg_order_value_usd,
avg_order_value_usd / last_week_avg_order_value_usd -1 as avg_order_value_growth
from orders
group by 1,2,3
order by 3 desc