<Hello/>

# Weekly Business Reviews

This project demonstrates using Evidence to create content for a Weekly Business Review, it:

1. **Automatically pre-populates a new report for each week**, using data from the database.
1. **Allows business users to add commentary** to the report, to explain any unusual events or trends.
1. **Can be shared via URL, PDF or copy-pasted** into another document.

```orders_by_week
select 
lpad(date_part('week', order_datetime),2,'0') as week,
date_trunc('week', order_datetime) as week_start,
date_part('year', date_trunc('week', order_datetime)) as year,
'weekly-reports' || '/' || date_part('year', date_trunc('week', order_datetime)) || '/' || lpad(date_part('week', order_datetime),2,'0') as link,
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
    <Column id=year/>
</DataTable>


## About this project

For more detail, see the [About](/about) page.