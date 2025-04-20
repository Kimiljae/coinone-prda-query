-- user별 2월 거래 일자 
with trade_base as (
	select 
	user_id 
	,min(trade_date) min_dt
	,min(week(trade_date)) as min_week
	,max(trade_date) last_dt
	,max(week(trade_date)) as max_week
	from trade_log 
	group by 1
)
-- base data
, otd as (
	select 
	t.user_id 
	,user_sex
	,user_age_group
	,signup_date
	,case when year(signup_date) < 2024 then 'base'
	  when year(signup_date) = 2024 then 'new'
	  else null end as sign_group
	,trade_date as dt
	,date_format(trade_date,'%m') as months
	,week(trade_date) as yw
	,min_dt
	,orderer_channel
	,symbol -- 가상화폐
	,quantity -- 거래 수
	,trade_volume -- 거래 금액 
	,round(trade_fee,0) -- 거래 수수료 
	,round(1.000*trade_fee/nullif(trade_volume,0),4) as fee_ra -- 0.2% 고정
	from trade_log t
	left join trade_base b on t.user_id = b.user_id
	left join user_info ui on t.user_id = ui.user_id 
) 

-- month 기준으로 거래 금액 상위 10% 유저 
, rn_base as (
	select 
	*
	,percent_rank() over(partition by months order by total_fee desc ) as fee_rn
	from 
	(
	select 
	months
	,user_id
	,sign_group
	,round(sum(trade_volume),0) as total_fee
	from otd
	group by 1,2,3
	) r
	where total_fee is not null 
)

-- loyalty_group : 2월 기준 거래 금액 상위 10% 
,loyalty_group as ( 
select 
user_id
from rn_base
where fee_rn between 0 and 0.2
)

-- retention_base에 활용할 max week 정의 
,max_week AS (
  select max(week(trade_date, 1)) - 1 as max_w from trade_log
)

-- 유저별 week 단위 retention 여부 체크   
,retention_base AS (
  select 
  user_id
  ,yw
  ,max_w
  ,max_w - yw + 1 as retention_index
  from otd 
  join max_week on 1=1 
  group by 1,2,3
)
-- 유저별 week 단위 retention 1,0 Flag 
,retention_flag as ( 
select
user_id
,max(case when retention_index = 1 then 1 else 0 end) as 'w1_index'
,max(case when retention_index = 2 then 1 else 0 end) as 'w2_index'
,max(case when retention_index = 3 then 1 else 0 end) as 'w3_index'
,max(case when retention_index = 4 then 1 else 0 end) as 'w4_index'
from retention_base
group by 1
)

-- group segment, retention segment 정의 
, final_base as ( 
select
otd.user_id 
,case when sign_group = 'base' and l.user_id is not null then 'loyalty'
	  when sign_group = 'new' and l.user_id is not null then 'potential'
	  when sign_group = 'new' and l.user_id is null then 'new'
	  else 'base' end as group_segment
,case when f.w1_index = 0 then '1w_churn' 
	 when f.w1_index = 1 and f.w2_index = 1 and f.w3_index = 1 and f.w4_index = 1 then '4w_retention'
	 when f.w1_index = 1 and f.w2_index = 1 and f.w3_index = 1 then '3w_retention'
	 when f.w1_index = 1 and f.w2_index = 1 then '2w_retention'
	 when f.w1_index = 1 then '1w_retention'
	 else 'base' end as retention_segment
from otd
left join retention_flag  f on otd.user_id = f.user_id 
left join loyalty_group l on otd.user_id = l.user_id 
group by 1,2,3
)
select 
*
from final_base
order by group_segment,retention_segment