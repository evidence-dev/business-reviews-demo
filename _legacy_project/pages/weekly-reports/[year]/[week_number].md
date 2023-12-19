<script>
  let month = weeks_to_months_lookup.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)[0].month ?? 'unknown'
  let week_start = ((weeks_to_days_lookup.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)[0] ?? 'unknown').week_start ?? 'unknown').toString().slice(0,10)
  let last_week_start = ((weeks_to_days_lookup.filter(d => d.week == (parseInt($page.params.week_number) - 1)).filter(d => d.year == $page.params.year)[0] ?? 'unknown').week_start ?? 'unknown').toString().slice(0,10)
  
  import CommentaryBlock from '$lib/CommentaryBlock.svelte';
  import Login from '$lib/Login.svelte';
  import WeekNav from '$lib/WeekNav.svelte';
</script>

<Login/>


<WeekNav weekNumber={$page.params.week_number} year={$page.params.year}/>

# Business Review - {$page.params.year} W{$page.params.week_number}

Week commencing {fmt(week_start, "dd mmm yyyy")}.

## Last Week's Actions

<CommentaryBlock
  section='Actions'
  week_start={last_week_start}
/>

## Summary

```sql weeks_to_months_lookup
select
  strftime(order_datetime, '%B') as month,
  date_part('year', order_datetime) as year,
  lpad(date_part('week', order_datetime),2,'0') as week,
from orders
group by 1,2,3
order by 2 desc, 3 desc
```

```sql weeks_to_days_lookup
select
  lpad(date_part('week', order_datetime),2,'0') as week,
  date_trunc('week', order_datetime) as week_start,
  date_part('year', date_trunc('week', order_datetime)) as year
from orders
group by 1,2,3
order by 2 desc
```



```sql orders_by_week
select 
lpad(date_part('week', order_datetime),2,'0') as week,
date_part('year', order_datetime) as year,
date_part('year', order_datetime) || '/' || lpad(date_part('week', order_datetime),2,'0') as link,
sum(sales) as sales_usd,
count(id) as total_orders,
sum(sales) / count(id) as avg_order_value_usd,
lag(sales_usd) over (order by link) as last_week_sales_usd,
sales_usd / last_week_sales_usd -1 as sales_growth,
lag(total_orders) over (order by link) as last_week_total_orders,
total_orders*1.0 / last_week_total_orders*1.0 -1 as orders_growth,
lag(avg_order_value_usd) over (order by link) as last_week_avg_order_value_usd,
avg_order_value_usd / last_week_avg_order_value_usd -1 as avg_order_value_growth
from orders
group by 1,2,3
order by 3 desc
```

```sql orders_by_month
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

```sql orders_by_month_by_category
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
<ul class=markdown>
{#each orders_by_month_by_category.filter(d => d.month == month).filter(d => d.year == $page.params.year) as category}
<li class=markdown>{category.category}: <Value data={category} column=sales_usd/></li>
{/each}
</ul>

### Last Week


<BigValue
  title="Sales"
  data={orders_by_week.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  value=sales_usd
  comparison=sales_growth
  comparisonTitle="vs last week"
  comparisonFmt="pct"
/>

<BigValue
  title="Orders"
  data={orders_by_week.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  value=total_orders
  comparison=orders_growth
  comparisonTitle="vs last week"
  comparisonFmt="pct"
/>

<BigValue
  title="Avg. Order Value"
  data={orders_by_week.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  value=avg_order_value_usd
  comparison=avg_order_value_growth
  comparisonTitle="vs last week"
  comparisonFmt="pct"
/>


<CommentaryBlock
  section='Summary'
  week_start={week_start}
/>



## Marketing

```sql orders_by_channel_by_week
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
```



```sql marketing_spend_daily_cost
select
  month_begin,
  lead(month_begin) over (partition by marketing_channel order by month_begin) as next_month_begin,
  case 
    when next_month_begin is not null then datediff('day',month_begin, next_month_begin)
    else 31 end
  as days_in_month,
  marketing_channel,
  spend / days_in_month as daily_cost_usd
from marketing_spend
```

```sql daily_cost_by_channel
select
  date_trunc('day', order_datetime) as date,
  date_trunc('month', order_datetime) as month_begin,
  orders.channel,
  first(daily_cost_usd) as total_daily_cost_usd,
  count(sales) as num_orders,
  sum(sales) as total_sales_usd,
from orders
left join ${marketing_spend_daily_cost} as spend
  on marketing_channel = channel 
  and spend.month_begin = date_trunc('month', order_datetime)
group by 1,2,3
order by 1,2
```

```sql weekly_cost_by_channel
select
  lpad(date_part('week', date),2,'0') as week,
  date_part('year', date) as year,
  channel,
  sum(total_daily_cost_usd) as total_daily_cost_usd,
  sum(num_orders) as num_orders,
  sum(total_sales_usd) as total_sales_usd,
  sum(total_daily_cost_usd) / sum(num_orders) as cpa,
  lag(cpa) over (partition by channel order by year, week) as last_week_cpa,
  cpa / last_week_cpa - 1 as cpa_growth
from ${daily_cost_by_channel}
group by 1,2,3
order by 1,2,5 desc
```

```sql weekly_cost
select
  year,
  week,
  sum(total_daily_cost_usd) as total_weekly_cost_usd,
  lag(total_weekly_cost_usd) over (order by year, week) as last_week_total_weekly_cost_usd,
  total_weekly_cost_usd / last_week_total_weekly_cost_usd - 1 as spend_growth,
  sum(num_orders) as weekly_orders,
  lag(weekly_orders) over (order by year, week) as last_week_orders,
  (1.0*weekly_orders) / (1.0*last_week_orders) - 1 as orders_growth,
  sum(total_sales_usd) as weekly_sales_usd,
  lag(weekly_sales_usd) over (order by year, week) as last_week_sales_usd,
  weekly_sales_usd / last_week_sales_usd - 1 as sales_growth,
  sum(total_daily_cost_usd) / sum(num_orders) as blended_cpa,
  lag(blended_cpa) over (order by year, week) as last_week_blended_cpa,
  blended_cpa / last_week_blended_cpa - 1 as cpa_growth
from ${weekly_cost_by_channel}
group by 1,2
order by 1,2
```

<BigValue
  title="Total Marketing Spend"
  data={weekly_cost.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  value=total_weekly_cost_usd
  comparison=spend_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  title="Total Orders"
  data={weekly_cost.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  value=weekly_orders
  comparison=orders_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  title="CPA"
  data={weekly_cost.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  value=blended_cpa
  fmt=usd2
  downIsGood=true
  comparison=cpa_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BarChart 
  data={orders_by_channel_by_week.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}
  y=num_orders
  swapXY
  title="Orders by Channel"
  />

### CPA by Channel


<BigValue
  data={weekly_cost_by_channel.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year).filter(d => d.channel == 'Google Paid')}
  value=cpa
  fmt=usd2
  title="Google Paid"
  comparison=cpa_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  data={weekly_cost_by_channel.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year).filter(d => d.channel == 'Facebook Ads')}
  value=cpa
  fmt=usd2
  title="Facebook Ads"
  comparison=cpa_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  data={weekly_cost_by_channel.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year).filter(d => d.channel == 'Tiktok Ads')}
  value=cpa
  fmt=usd2
  title="Tiktok Ads"
  comparison=cpa_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  data={weekly_cost_by_channel.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year).filter(d => d.channel == 'Coupon')}
  value=cpa
  fmt=usd2
  title="Coupon"
  comparison=cpa_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>



<CommentaryBlock
  section='Marketing'
  week_start={week_start}
/>



## Ops

```sql delivery_performance
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
```
<BigValue
  data={delivery_performance.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year).filter(d => d.delivery_status == 'on time')}
  value=deliveries_pct
  title="On Time Deliveries"
/>


<DataTable data={delivery_performance.filter(d => d.week === $page.params.week_number).filter(d => d.year == $page.params.year)}>
  <Column id="delivery_status"/>
  <Column id="num_deliveries"/>
  <Column id="deliveries_pct"/>
</DataTable>


<CommentaryBlock
  section='Ops'
  week_start={week_start}
/>

# Actions

<CommentaryBlock
  section='Actions'
  week_start={week_start}
/>


<WeekNav weekNumber={$page.params.week_number} year={$page.params.year} />