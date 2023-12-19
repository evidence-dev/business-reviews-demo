select
  lpad(date_part('week', delivery_time),2,'0') as week,
  date_part('year', delivery_time) as year,
  case 
    when delivery_time > delivery_slot_end then 'late'
    when delivery_time < delivery_slot_start then 'early'
    else 'on time' end as delivery_status,
  count(id) as num_deliveries,
  sum(count(id)) over (partition by week,year) as total_deliveries,
  (1.0*num_deliveries) / (1.0*total_deliveries) as deliveries_pct
from deliveries
group by 1,2,3