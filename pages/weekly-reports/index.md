# All Reports

```orders_by_week2
select * from needful_things.orders_by_week2
```

Click a week below to see the report for that week.

The most recent week's report is <a href="{orders_by_week2[0].link}">here</a>.


<DataTable data={orders_by_week2} link=link>
    <Column id=week/>
    <Column id=week_start/>
    <Column id=link/>
    <Column id=year/>
</DataTable>