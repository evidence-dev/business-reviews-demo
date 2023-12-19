<script>
  $: month = weeks_to_months_lookup.filter(d => d.week === params.week_number).filter(d => d.year == params.year)[0] ?? 'unknown'
  $: week_start = fmt(weeks_to_days_lookup[0].week_start, "yyyy-mm-dd")
  $: last_week_start = fmt(last_week_days_lookup[0].week_start, "yyyy-mm-dd")
  
  import CommentaryBlock from '$lib/CommentaryBlock.svelte';
  import Login from '$lib/Login.svelte';
  import WeekNav from '$lib/WeekNav.svelte';
</script>

<Login/>


<WeekNav weekNumber={params.week_number} year={params.year}/>

# Business Review - {params.year} W{params.week_number}

Week commencing {week_start}.

## Last Week's Actions

<CommentaryBlock
  section='Actions'
  week_start={last_week_start}
/>

## Summary

```sql weeks_to_months_lookup
select * from needful_things.weeks_to_months_lookup
where year = ${params.year}
and week = ${params.week_number}
```



```sql weeks_to_days_lookup
select * from needful_things.weeks_to_days_lookup
where year = ${params.year}
and week = ${params.week_number}
```

```sql last_week
select * from needful_things.weeks_to_months_lookup
where year = ${params.year}
and week = ${params.week_number}-1
```

```sql last_week_days_lookup
select * from needful_things.weeks_to_days_lookup
where year = ${params.year}
and week = ${params.week_number}-1
```




```sql orders_by_week
select * from needful_things.orders_by_week1
where year = ${params.year}
and week = ${params.week_number}
```

```sql orders_by_month
select * from needful_things.orders_by_month
where year = ${params.year}
and month = '${weeks_to_months_lookup[0].month}'
```


```sql orders_by_month_by_category
select * from needful_things.orders_by_month_by_category
where year = ${params.year}
and month = '${weeks_to_months_lookup[0].month}'
```


### Overall Month to Date

Sales for {month.month} to date are <Value data={orders_by_month} column=sales_usd/>:
<ul class=markdown>
{#each orders_by_month_by_category as category}
<li class=markdown>{category.category}: <Value data={category} column=sales_usd/></li>
{/each}
</ul>

### Last Week

<BigValue
  title="Sales"
  data={orders_by_week}
  value=sales_usd
  comparison=sales_growth
  comparisonTitle="vs last week"
  comparisonFmt="pct"
/>

<BigValue
  title="Orders"
  data={orders_by_week}
  value=total_orders
  comparison=orders_growth
  comparisonTitle="vs last week"
  comparisonFmt="pct"
/>

<BigValue
  title="Avg. Order Value"
  data={orders_by_week}
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
select * from needful_things.orders_by_channel_by_week
where year = ${params.year}
and week = ${params.week_number}
```



```sql marketing_spend_daily_cost
select * from needful_things.marketing_spend_daily_cost
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
  data={weekly_cost.filter(d => d.week === params.week_number).filter(d => d.year == params.year)}
  value=total_weekly_cost_usd
  comparison=spend_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  title="Total Orders"
  data={weekly_cost.filter(d => d.week === params.week_number).filter(d => d.year == params.year)}
  value=weekly_orders
  comparison=orders_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  title="CPA"
  data={weekly_cost.filter(d => d.week === params.week_number).filter(d => d.year == params.year)}
  value=blended_cpa
  fmt=usd2
  downIsGood=true
  comparison=cpa_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BarChart 
  data={orders_by_channel_by_week}
  y=num_orders
  swapXY
  title="Orders by Channel"
  />

### CPA by Channel


<BigValue
  data={weekly_cost_by_channel.filter(d => d.week === params.week_number).filter(d => d.year == params.year).filter(d => d.channel == 'Google Paid')}
  value=cpa
  fmt=usd2
  title="Google Paid"
  comparison=cpa_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  data={weekly_cost_by_channel.filter(d => d.week === params.week_number).filter(d => d.year == params.year).filter(d => d.channel == 'Facebook Ads')}
  value=cpa
  fmt=usd2
  title="Facebook Ads"
  comparison=cpa_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  data={weekly_cost_by_channel.filter(d => d.week === params.week_number).filter(d => d.year == params.year).filter(d => d.channel == 'Tiktok Ads')}
  value=cpa
  fmt=usd2
  title="Tiktok Ads"
  comparison=cpa_growth
  comparisonTitle="vs last week"
  comparisonFmt=pct
/>

<BigValue
  data={weekly_cost_by_channel.filter(d => d.week === params.week_number).filter(d => d.year == params.year).filter(d => d.channel == 'Coupon')}
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
select * from needful_things.delivery_performance
```
<BigValue
  data={delivery_performance.filter(d => d.week === params.week_number).filter(d => d.year == params.year).filter(d => d.delivery_status == 'on time')}
  value=deliveries_pct
  title="On Time Deliveries"
/>


<DataTable data={delivery_performance.filter(d => d.week === params.week_number).filter(d => d.year == params.year)}>
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


<WeekNav weekNumber={params.week_number} year={params.year} />