use mavenflix
select * from subscription;

-- Data Cleaning Part

-- create new created date column

alter table subscription add column new_created_date date;

-- create new canceled date column

alter table subscription add column new_canceled_date date;


-- update the new column with the correct data type

-- for created date

SET SQL_SAFE_UPDATES = 0;
UPDATE subscription 
SET 
    new_created_date = STR_TO_DATE(created_date, '%d-%m-%Y');
SET SQL_SAFE_UPDATES = 1;

-- for canceled date

SET SQL_SAFE_UPDATES = 0;
UPDATE subscription 
SET 
    new_canceled_date = CASE
        WHEN
            canceled_date IS NOT NULL
                AND canceled_date != ''
        THEN
            STR_TO_DATE(canceled_date, '%d-%m-%Y')
        ELSE NULL
    END;
SET SQL_SAFE_UPDATES = 1;

-- Drop Original Created date and canceled date column

alter table subscription drop column created_date

alter table subscription drop column canceled_date

select * from subscription;

-- Problem Statments.

-- Identify the MavenFlix customers subscription trends and patterns.

--  • Total Paid Subscription

SELECT 
    COUNT(was_subscription_paid)
FROM
    subscription
WHERE
    was_subscription_paid = 'Yes';
    
    

--  • Total Unpaid Subscription

SELECT 
    COUNT(was_subscription_paid)
FROM
    subscription
WHERE
    was_subscription_paid = 'No'
    
    
    

--  • Total Customer Paid Subscription

SELECT COUNT(DISTINCT customer_id) as paid_subscription_customer 
FROM subscription
WHERE was_subscription_paid = 'Yes'



--  • Subscriptions trends over time

SELECT 
    DATE_FORMAT(new_created_date, '%Y-%m') AS monthly_trend,
    COUNT(DISTINCT customer_id) AS subscribers
FROM
    subscription
WHERE
    was_subscription_paid = 'Yes'
GROUP BY 1



--  • Percentage of customers with 5 month or more subscriptions

with cte as (
		select customer_id, 
		IFNULL(DATEDIFF(new_canceled_date, new_created_date), 0)/30 as total_months_subscription
		from subscription )
        
select 
round((count(case when total_months_subscription >=5 then customer_id end) * 100.0 / count(distinct customer_id)),2) as 5_months_subscriptions_percent
from cte


--  • Which month had the highest and lowest retention subscriber retention

with monthly_subs as (
		SELECT count(customer_id) as new_customer,
        date_format(new_created_date, '%Y-%m') as subs_month
        from subscription
        group by 2
),
monthly_cancl as (
		SELECT count(customer_id) as cancl_customer,
        date_format(new_canceled_date, '%Y-%m') as cancl_month
        from subscription
        where new_canceled_date is not null
        group by 2
),



monthly_retention as (
		select subs_month,
        new_customer,
        coalesce(cancl_customer, 0) as cancl_customer,
        (new_customer - coalesce(cancl_customer, 0) / new_customer) / 100 as retention_rate
        from monthly_subs
        left join monthly_cancl
        on subs_month = cancl_month
)

select subs_month, new_customer, cancl_customer, round(retention_rate,2)
from monthly_retention
order by retention_rate desc










--  • Numbers of Active Paying Subscribers

SELECT COUNT(customer_id) AS active_subscriber_count
FROM subscription
WHERE new_canceled_date IS NULL AND was_subscription_paid = 'Yes'



--  • Total Amount Generated from Paid Subscribers

SELECT SUM(subscription_cost) AS paid_subscriber_generated_amount 
FROM subscription
WHERE was_subscription_paid = 'Yes'









