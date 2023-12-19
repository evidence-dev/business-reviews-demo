select
  lpad(date_part('week', order_datetime),2,'0') as week,
  date_trunc('week', order_datetime) as week_start,
  date_part('year', date_trunc('week', order_datetime)) as year
from orders
group by 1,2,3
order by 2 desc