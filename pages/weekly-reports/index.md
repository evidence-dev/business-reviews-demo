## All Reports

```orders_by_week
select 
lpad(date_part('week', order_datetime),2,'0') as week,
date_part('year', order_datetime) as year,
date_part('year', order_datetime) || '/' || lpad(date_part('week', order_datetime),2,'0') as link,
sum(sales) as sales_usd,
count(id) as orders,
sum(sales) / count(id) as avg_order_value_usd
from orders
group by 1,2,3
order by 3 desc
```

<DataTable data={orders_by_week} link=link>
    <Column id=link/>
</DataTable>