select 
lpad(date_part('week', order_datetime),2,'0') as week,
date_trunc('week', order_datetime) as week_start,
date_part('year', date_trunc('week', order_datetime)) as year,
date_part('year', date_trunc('week', order_datetime)) || '/' || lpad(date_part('week', order_datetime),2,'0') as link,
sum(sales) as sales_usd,
count(id) as orders,
sum(sales) / count(id) as avg_order_value_usd
from orders
group by 1,2,3,4
order by 4 desc