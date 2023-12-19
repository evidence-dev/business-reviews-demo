# Weekly Business Reviews

This project demonstrates using Evidence to create content for a Weekly Business Review, it:

1. **Automatically pre-populates a new report for each week**, using data from the database.
1. **Allows business users to add commentary** to the report, to explain any unusual events or trends.
1. **Can be shared via URL, PDF or copy-pasted** into another document.

```orders_by_week
select * from needful_things.orders_by_week
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