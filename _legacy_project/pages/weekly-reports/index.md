# All Reports

```orders_by_week
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
```

Click a week below to see the report for that week.

The most recent week's report is <a href="{orders_by_week[0].link}">here</a>.


<DataTable data={orders_by_week} link=link>
    <Column id=week/>
    <Column id=week_start/>
    <Column id=link/>
    <Column id=year/>
</DataTable>