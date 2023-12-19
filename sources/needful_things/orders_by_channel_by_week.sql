select 
channel,
lpad(date_part('week', order_datetime),2,'0') as week,
date_part('year', order_datetime) as year,
count(*) as num_orders,
sum(sales) as sales_usd,
from orders
where order_datetime >= '2021-01-01'
group by 1,2,3
order by 3,2,4 desc,1