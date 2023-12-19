select
  strftime(order_datetime, '%B') as month,
  date_part('year', order_datetime) as year,
  lpad(date_part('week', order_datetime),2,'0') as week,
from orders
group by 1,2,3
order by 2 desc, 3 desc