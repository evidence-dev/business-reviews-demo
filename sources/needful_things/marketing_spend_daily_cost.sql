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