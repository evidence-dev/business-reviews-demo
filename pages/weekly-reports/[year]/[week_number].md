<script>
  let month = weeks_to_months_lookup.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)[0].month ?? 'unknown'
  let week_start = ((weeks_to_days_lookup.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)[0] ?? 'unknown').week_start ?? 'unknown').toString().slice(0,10)
  
  import CommentaryBlock from '$lib/CommentaryBlock.svelte';
</script>

{#if week_start == 'unknown' }

No data

{:else}

# Business Review - {$page.params.year} W{$page.params.week_number}

Week commencing {week_start}.

## Summary

```weeks_to_months_lookup
select
  strftime(order_datetime, '%B') as month,
  date_part('year', order_datetime) as year,
  lpad(date_part('week', order_datetime),2,'0') as week,
from orders
group by 1,2,3
order by 2 desc, 3 desc
```

```weeks_to_days_lookup
select
  lpad(date_part('week', order_datetime),2,'0') as week,
  date_trunc('week', order_datetime) as week_start,
  date_part('year', date_trunc('week', order_datetime)) as year
from orders
group by 1,2,3
order by 2 desc
```



```orders_by_week
select 
lpad(date_part('week', order_datetime),2,'0') as week,
date_part('year', order_datetime) as year,
date_part('year', order_datetime) || '/' || lpad(date_part('week', order_datetime),2,'0') as link,
sum(sales) as sales_usd,
count(id) as total_orders,
sum(sales) / count(id) as avg_order_value_usd,
lag(sales_usd) over (order by link) as last_week_sales_usd,
sales_usd / last_week_sales_usd -1 as sales_growth_pct0,
lag(total_orders) over (order by link) as last_week_total_orders,
total_orders*1.0 / last_week_total_orders*1.0 -1 as orders_growth_pct0,
lag(avg_order_value_usd) over (order by link) as last_week_avg_order_value_usd,
avg_order_value_usd / last_week_avg_order_value_usd -1 as avg_order_value_growth_pct0
from orders
group by 1,2,3
order by 3 desc
```

```orders_by_month
select
strftime(order_datetime, '%B') as month,
date_part('year', order_datetime) as year,
sum(sales) as sales_usd,
count(id) as orders,
sum(sales) / count(id) as avg_order_value_usd
from orders
group by 1,2
order by 2 desc, 1 desc
```

```orders_by_month_by_category
select
strftime(order_datetime, '%B') as month,
date_part('year', order_datetime) as year,
category,
sum(sales) as sales_usd,
count(id) as orders,
sum(sales) / count(id) as avg_order_value_usd
from orders
group by 1,2,3
order by 2 desc, 1 desc, 4 desc
```

### Overall Month to Date

Sales for {month} to date are <Value data={orders_by_month.filter(d => d.month == month).filter(d => d.year == $page.params.year)} column=sales_usd/>:
<ul>
{#each orders_by_month_by_category.filter(d => d.month == month).filter(d => d.year == $page.params.year) as category}
<li>{category.category}: <Value data={category} column=sales_usd/></li>
{/each}
</ul>



### Last Week


<BigValue
  title="Sales"
  data={orders_by_week.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  value=sales_usd
  comparison=sales_growth_pct0
  comparisonTitle="vs. Last Week"
/>

<BigValue
  title="Orders"
  data={orders_by_week.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  value=total_orders
  comparison=orders_growth_pct0
  comparisonTitle="vs. Last Week"
/>

<BigValue
  title="Avg. Order Value"
  data={orders_by_week.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  value=avg_order_value_usd
  comparison=avg_order_value_growth_pct0
  comparisonTitle="vs. Last Week"
/>


<CommentaryBlock
  section='Summary'
  week_start={week_start}
/>



## Marketing


<CommentaryBlock
  section='Marketing'
  week_start={week_start}
/>

## Ops

```delivery_performance
select
  lpad(date_part('week', delivery_time),2,'0') as week,
  date_part('year', delivery_time) as year,
  case 
    when delivery_time > delivery_slot_end then 'late'
    when delivery_time < delivery_slot_start then 'early'
    else 'on time' end as delivery_status,
  count(id) as num_deliveries
from deliveries
group by 1,2,3
```

<DataTable data={delivery_performance.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}>
  <Column id="delivery_status"/>
  <Column id="num_deliveries"/>
</DataTable>


<CommentaryBlock
  section='Ops'
  week_start={week_start}
/>


## Finance

The total amount of cash at hand is $2,127,100, as of {week_start}.

<CommentaryBlock
  section='Finance'
  week_start={week_start}
/>

{/if}