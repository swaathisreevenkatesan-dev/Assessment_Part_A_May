--Business Context
--One of our clients runs an iGaming website. They’d like to focus on the spend and retention of new
--users. There has been some predictive modeling work done on this, but further analysis and
--dashboarding is necessary.

--SQL Queries
--Whats the primary key of the table?
select count(*), count(distinct CONCAT(CONCAT(user_id, period),cast(fs_date as varchar)))
from reporting_batch.swaathi_test_data;

--a. Find the average amount of first time spend (fts_amount) by acquisition_channel.
select acquisition_channel, avg(fs_amount) as fs_amount
from (select user_id, max(acquisition_channel) as acquisition_channel, max(fs_amount) as fs_amount
from reporting_batch.swaathi_test_data
group by 1)
group by 1;


--b. Rank top 5 distinct users within each tier by total revenue (revenue).
with cte as (
select tier, user_id, sum(revenue) as revenue
from reporting_batch.swaathi_test_data
group by 1,2)
select *
from (select tier, user_id, revenue, row_number() over ( partition by tier order by revenue desc) as rank_num
from cte )a
where rank_num<=5
order by tier asc;

--c. How would you characterize the difference, if any, of the early engagement (first 3 days, first 7 days) between the different acquisition channels?
with cte as (
select a.acquisition_channel,
count(distinct a.user_id) as users,
-- Logins
sum(case when cast(logins_f3d as double)>0 then cast(logins_f3d as double) end) as logins_f3d,
sum(case when cast(logins_f7d as double)>0 then cast(logins_f7d as double) end) as logins_f7d,
-- Games
sum(case when cast(games_f3d as double)>0 then cast(games_f3d as double) end) as games_f3d,
sum(case when cast(games_f7d as double)>0 then cast(games_f7d as double) end) as games_f7d,
-- Spends in usd
sum(case when cast(spend_usd_f3d as double)>0 then cast(spend_usd_f3d as double) end) as spend_usd_f3d,
sum(case when cast(spend_usd_f7d as double)>0 then cast(spend_usd_f7d as double) end) as spend_usd_f7d,

-- retention
round((cast(count(distinct case when cast(period as date)>a.fs_date and cast(period as date)<=a.fs_date + interval '7' day then a.user_id end) as double) / cast(count(distinct a.user_id ) as double))*100,4) as days_retention_7,
round((cast(count(distinct case when cast(period as date)>a.fs_date and cast(period as date)<=a.fs_date + interval '3' day then a.user_id end) as double) / cast(count(distinct a.user_id ) as double))*100,4) as days_retention_3

from (select user_id, acquisition_channel, fs_date,
max(logins_f3d) as logins_f3d,
max(logins_f7d) as logins_f7d,
max(games_f3d) as games_f3d,
max(games_f7d) as games_f7d,
max(spend_usd_f3d) as spend_usd_f3d,
max(spend_usd_f7d) as spend_usd_f7d
from reporting_batch.swaathi_test_data
group by 1,2,3) a
left join ( select user_id, period, fs_date
from reporting_batch.swaathi_test_data
group by 1,2,3)b on a.user_id=b.user_id and a.fs_date=b.fs_date
group by 1)
select acquisition_channel,
users,
cast(logins_f3d as double)/cast(users as double) as total_logins_in_first_3_days,
cast(logins_f7d as double)/cast(users as double) as total_logins_in_first_7_days,
cast(games_f3d as double)/cast(users as double) as total_games_in_first_3_days,
cast(games_f7d as double)/cast(users as double) as total_games_in_first_7_days,
cast(spend_usd_f3d as double)/cast(users as double) as total_spend_usd_in_first_3_days,
cast(spend_usd_f7d as double)/cast(users as double) as total_spend_usd_in_first_7_days,
days_retention_7
from cte

with cte as (
select count(distinct a.user_id) as users,
-- Logins
sum(case when cast(logins_f3d as double)>0 then cast(logins_f3d as double) end) as logins_f3d,
sum(case when cast(logins_f7d as double)>0 then cast(logins_f7d as double) end) as logins_f7d,
-- Games
sum(case when cast(games_f3d as double)>0 then cast(games_f3d as double) end) as games_f3d,
sum(case when cast(games_f7d as double)>0 then cast(games_f7d as double) end) as games_f7d,
-- Spends in usd
sum(case when cast(spend_usd_f3d as double)>0 then cast(spend_usd_f3d as double) end) as spend_usd_f3d,
sum(case when cast(spend_usd_f7d as double)>0 then cast(spend_usd_f7d as double) end) as spend_usd_f7d,

-- retention
round((cast(count(distinct case when cast(period as date)>a.fs_date and cast(period as date)<=a.fs_date + interval '7' day then a.user_id end) as double) / cast(count(distinct a.user_id ) as double))*100,4) as days_retention_7,
round((cast(count(distinct case when cast(period as date)>a.fs_date and cast(period as date)<=a.fs_date + interval '3' day then a.user_id end) as double) / cast(count(distinct a.user_id ) as double))*100,4) as days_retention_3

from (select user_id, acquisition_channel, fs_date,
max(logins_f3d) as logins_f3d,
max(logins_f7d) as logins_f7d,
max(games_f3d) as games_f3d,
max(games_f7d) as games_f7d,
max(spend_usd_f3d) as spend_usd_f3d,
max(spend_usd_f7d) as spend_usd_f7d
from reporting_batch.swaathi_test_data
group by 1,2,3) a
left join ( select user_id, period, fs_date
from reporting_batch.swaathi_test_data
group by 1,2,3)b on a.user_id=b.user_id and a.fs_date=b.fs_date)
select users,
cast(logins_f3d as double)/cast(users as double) as total_logins_in_first_3_days,
cast(logins_f7d as double)/cast(users as double) as total_logins_in_first_7_days,
cast(games_f3d as double)/cast(users as double) as total_games_in_first_3_days,
cast(games_f7d as double)/cast(users as double) as total_games_in_first_7_days,
cast(spend_usd_f3d as double)/cast(users as double) as total_spend_usd_in_first_3_days,
cast(spend_usd_f7d as double)/cast(users as double) as total_spend_usd_in_first_7_days,
days_retention_7
from cte;


-- d. Calculate the retention rate of users on Day 7.
-- This is the level of data - user_id, period, fs_date



select round((cast(count(distinct case when cast(period as date)>fs_date and cast(period as date)<=fs_date + interval '7' day then a.user_id end) as double) / cast(count(distinct a.user_id ) as double))*100,4) as days_retention_7,
round((cast(count(distinct case when cast(period as date)>fs_date and cast(period as date)=fs_date + interval '7' day then a.user_id end) as double) / cast(count(distinct a.user_id ) as double))*100,4) as day_7th_retention
from (select  user_id, fs_date
from reporting_batch.swaathi_test_data
group by 1,2)a
left join (select user_id, period
from reporting_batch.swaathi_test_data
group by 1,2) b on a.user_id=b.user_id;


select date_trunc('month',fs_date) as fs_date,
round((cast(count(distinct case when cast(period as date)>fs_date and cast(period as date)<=fs_date + interval '7' day then a.user_id end) as double) / cast(count(distinct a.user_id ) as double))*100,4) as days_retention_7,
round((cast(count(distinct case when cast(period as date)>fs_date and cast(period as date)=fs_date + interval '7' day then a.user_id end) as double) / cast(count(distinct a.user_id ) as double))*100,4) as day_7th_retention
from (select  user_id, fs_date
from reporting_batch.swaathi_test_data
group by 1,2)a
left join (select user_id, period
from reporting_batch.swaathi_test_data
group by 1,2) b on a.user_id=b.user_id
group by 1 order by 1 asc;


-- e. Show the schema of the database tables.

describe reporting_batch.swaathi_test_data;
