Create database faasos;
use faasos;

drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'2021-01-01'),
(2,'2021-01-03'),
(3,'2021-01-08'),
(4,'2021-01-15');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1, 1, '2021-01-01 18:15:34', '20km', '32 minutes', ''),
(2, 1, '2021-01-01 19:10:54', '20km', '27 minutes', ''),
(3, 1, '2021-01-03 00:12:37', '13.4km', '20 mins', 'NaN'),
(4, 2, '2021-01-04 13:53:03', '23.4', '40', 'NaN'),
(5, 3, '2021-01-08 21:10:57', '10', '15', 'NaN'),
(6, 3, null, null, null, 'Cancellation'),
(7, 2, '2020-01-08 21:30:45', '25km', '25mins', null),
(8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', null),
(9, 2, null, null, null, 'Customer Cancellation'),
(10, 1, '2020-01-11 18:50:20', '10km', '10minutes', null)
;
set sql_safe_updates=0;
update driver_order
set pickup_time = '2021-01-08 21:30:45'
where pickup_time= '2020-01-08 21:30:45';

update driver_order
set pickup_time= '2021-01-10 00:15:02'
where pickup_time= '2020-01-10 00:15:02';

update driver_order
set pickup_time= '2021-01-11 18:50:20'
where pickup_time='2020-01-11 18:50:20';

drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1, 101, 1, '', '', '2021-01-01 18:05:02'),
(2, 101, 1, '', '', '2021-01-01 19:00:52'),
(3, 102, 1, '', '', '2021-01-02 23:51:23'),
(3, 102, 2, '', 'NaN', '2021-01-02 23:51:23'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 2, '4', '', '2021-01-04 13:23:46'),
(5, 104, 1, null, '1', '2021-01-08 21:00:29'),
(6, 101, 2, null, null, '2021-01-08 21:03:13'),
(7, 105, 2, null, '1', '2021-01-08 21:20:29'),
(8, 102, 1, null, null, '2021-01-09 23:54:33'),
(9, 103, 1, '4', '1,5', '2021-01-10 11:22:59'),
(10, 104, 1, null, null, '2021-01-11 18:34:49'),
(10, 104, 1, '2,6', '1,4', '2021-01-11 18:34:49')
;

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

-- how many rolls were ordered?
select count(order_id) from customer_orders;
select count(roll_id) from customer_orders;

-- how many unique customer orders were placed?
select * from customer_orders;
select  count(distinct customer_id) from customer_orders;

-- how many successful orders were delivered by the driver?
select * from driver_order;
select driver_id, count(distinct order_id) from driver_order
where cancellation not in ('Cancellation','Customer Cancellation')
group by driver_id;

-- how many of each type of roll was delivered?

select * from driver_order;
select c.roll_id,count(c.order_id) from(
select b.order_id,customer_orders.roll_id from(
select a.* from(
select *, case when cancellation in('Cancellation','Customer Cancellation') then  'c' else 'nc' end as order_status from driver_order) as a 
where order_status='nc') as b
join customer_orders
on b.order_id=customer_orders.order_id) as c
group by 1;

-- how many veg and non veg rolls were ordered by each customer?
select * from customer_orders;

select customer_orders.customer_id,customer_orders.roll_id,rolls.roll_name,count(customer_orders.roll_id)
from customer_orders
join rolls
on customer_orders.roll_id=rolls.roll_id
group by 1,2,3
order by roll_name;

-- maximum number of rolls delivered in a single order
select * from driver_order;
select order_id,count(roll_id) from
(select * from customer_orders where order_id in
(
select a.order_id from
(select * , case when cancellation in ('Cancellation','Customer Cancellation') then 'c' else 'nc' end as order_status
from driver_order)a
where order_status='nc'))b
group by 1
order by 2 desc
limit 1;

-- for each customer, how many delivered rolls had atleast 1 change and how many had no change?
select * from driver_order;
select * from customer_orders;

with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(select order_id,customer_id,roll_id, case when not_include_items is null or not_include_items='' then '0' else not_include_items 
end as new_not_include_items, case when extra_items_included is null or extra_items_included='NaN'
or extra_items_included='' then '0' 
else extra_items_included end as new_extra_items_included, order_date from customer_orders),


temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(select order_id,driver_id,pickup_time,distance,duration, case when cancellation in ('Cancellation', 'customer cancellation') then 'c' else 'nc' end as New_cancellation_status
from driver_order)

select change_status,count(order_id) from(
select * , case when not_include_items !='0' or extra_items_included !='0' then 'change' else 'no change' end as Change_status
from(
select * from temp_customer_orders where order_id in (select order_id from temp_driver_order where new_cancellation = 'nc'))a)b
group by 1;

-- how many delivered orders had both exclusions and extra items?
with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(select order_id,customer_id,roll_id, case when not_include_items is null or not_include_items='' then '0' else not_include_items 
end as new_not_include_items, case when extra_items_included is null or extra_items_included='NaN'
or extra_items_included='' then '0' 
else extra_items_included end as new_extra_items_included, order_date from customer_orders),

temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(select order_id,driver_id,pickup_time,distance,duration, case when cancellation in ('Cancellation', 'customer cancellation') then 'c' else 'nc' end as New_cancellation_status
from driver_order)

select chg_no_chg,count(order_id) from(
select *, case when not_include_items!='0' and extra_items_included!='0' then 'change' else 'no change' end as chg_no_chg from(
select * from temp_customer_orders where order_id in(
select order_id from temp_driver_order where new_cancellation ='nc'))a)b
group by 1;

-- what was total number of rolls ordered for each hour of the day?
select hour_bucket, count(order_id) from
(select a.*, concat((hour_value0), '-' , (hour_value1)) as hour_bucket from
(select *,date(order_date) as date_only,time(order_date) as time_only ,
extract(hour from order_date) as hour_value0, extract(hour from order_date)+1 as hour_value1 from customer_orders)a)b
group by 1;

-- What was the number of orders for each day of the week?
select day,count(distinct(order_id)) from
(select *,dayname(date(order_date)) as Day from customer_orders)a
group by 1;


-- What was the average time in minutes it took for each driver to arrive at the Fasoos HQ to pickup the order?


select k.driver_id, sum(k.mint_diff)/count(k.order_id) as Avg from(
select * from(
select *,row_number () over (partition by order_id order by mint_diff) as ranking from(
select a.*, timestampdiff(minute,a.order_date,a.pickup_time) as mint_diff from(
select c.order_id,c.customer_id,c.roll_id,c.not_include_items,c.extra_items_included,c.order_date,
d.driver_id,d.pickup_time
from customer_orders c
join driver_order d
on c.order_id=d.order_id
where d.pickup_time is not null)a)n)m
where ranking=1)k
group by 1;

--  Is there any relationship between the number of rolls and how long the order takes to prepare?
with roll_count_table as(
select customer_orders.order_id,count(roll_id) as counting from customer_orders group by 1),

Timing_table as (
select a.*, timestampdiff(minute,a.order_date,a.pickup_time) as mint_diff from(
select c.order_id,c.customer_id,c.roll_id,c.not_include_items,c.extra_items_included,c.order_date,
d.driver_id,d.pickup_time
from customer_orders c
join driver_order d
on c.order_id=d.order_id
where d.pickup_time is not null)a)

select w.*, (w.mint_diff/w.counting) from(
select b.* from 
(select *,row_number() over (partition by order_id order by mint_diff) as rnks from(
select R.Order_id,r.counting,t.mint_diff
from roll_count_table as r
join timing_table as t
on r.order_id=t.order_id)a)b
where rnks=1)w;

-- Linear relationship

-- What was the average distance travelled for each customer?
select * from driver_order;

select * from customer_orders;

select customer_id,(sum(dist)/count(order_id)) average from(
select * from(
select *, row_number() over (partition by order_id) as ranking from (
select *, trim(replace(distance,'km',''))as Dist from(
select * from(
select customer_orders.*, 
driver_order.distance from customer_orders
join driver_order
on customer_orders.order_id=driver_order.order_id
where distance!='null')a
where distance!='null')b)c)d
where ranking=1)e
group by 1;

-- what was the difference between highest and shortest delivery time for all orders?
 
 select max(new_duration)-min(new_duration) from(
 select *, case when duration like'%min%' then left(duration,locate('m',duration)-1) else duration end as new_duration 
 from driver_order where duration is not null
 order by new_duration desc)a;
 
 -- what was the average speed for each driver for each delivery an do you notice any trend for these values?
 
select driver_id,avg(speed) from(
select *,(new_distance*60/new_duration) as speed from(
 select * , trim(replace (distance,'km','')) new_distance, 
 case when duration like '%min%' then left(duration,locate('m',duration)-1) else duration end as New_duration
 from driver_order
 where duration is not null)a)b
 group by 1;
 
 -- what is the successful delivery percentage of each driver?


 select *, (success*100/total_orders) as success_per from(
 select driver_id, sum(delivery_type) as success, count(delivery_type) as total_orders from(
 select driver_id, case when cancellation like '%cancel%' then '0' else '1' end as delivery_type
 from driver_order)a
 group by 1)b;
 