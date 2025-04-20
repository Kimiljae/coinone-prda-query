-- user별 2월 거래 일자 
with trade_base as (
	select 
	user_id 
	,min(trade_date) min_trade_dt 
	from trade_log 
	group by 1
)
-- Base Data 
, otd as (
	select 
	v.user_id
	,visit_date 
	,user_sex
	,user_age_group
	,signup_date
	,trade_date as dt
	,min_trade_dt 
	,orderer_channel
	,symbol
	,quantity -- 거래 수
	,trade_volume -- 거래 금액 
	,round(trade_fee,0) -- 거래 수수료 
	 -- ,round(1.000*trade_fee/nullif(trade_volume,0),4) as fee_ra -- 0.2% 수수료 정책 Check 
	from visit_log v
	left join trade_log t on v.user_id = t.user_id 
	left join trade_base b on v.user_id = b.user_id
	left join user_info ui on v.user_id = ui.user_id 
)  
-- dt 기준으로 거래 금액 상위 10% 유저 
, rn_base as (
	select 
	*,percent_rank() over(partition by dt order by total_fee desc ) as fee_rn
	from 
	(
	select 
	dt
	,user_id
	,sum(quantity) as trade_cnt
	,round(sum(trade_volume),0) as total_fee
	from otd
	group by 1,2
	) r
	where total_fee is not null 
)
-- 단위 : 백만으로 상위 10%, 상위 20% 거래 금액 및 총 거래 비중 
select 
dt
,count(distinct user_id) as user_cnt
,round(sum(trade_cnt)/1000000,0) as total_trade_cnt
,round(sum(case when fee_rn between 0 and 0.1 then trade_cnt end)/1000000,2) as top10_trade_cnt
,round(sum(case when fee_rn between 0 and 0.2 then trade_cnt end)/1000000,2) as top20_trade_cnt
,round(1.00*sum(case when fee_rn between 0 and 0.1 then trade_cnt end) /sum(trade_cnt),2) as top10_cnt_ratio
,round(1.00*sum(case when fee_rn between 0 and 0.2 then trade_cnt end) /sum(trade_cnt),2) as top20_cnt_ratio
,round(sum(total_fee)/1000000,0) as total_fee
,round(sum(case when fee_rn between 0 and 0.1 then total_fee end)/1000000,2) as top10_fee
,round(sum(case when fee_rn between 0 and 0.2 then total_fee end)/1000000,2) as top20_fee
,round(1.00*sum(case when fee_rn between 0 and 0.1 then total_fee end)/sum(total_fee),2) as top10_fee_ratio
,round(1.00*sum(case when fee_rn between 0 and 0.2 then total_fee end)/sum(total_fee),2) as top20_fee_ratio
from rn_base
group by 1
order by 1