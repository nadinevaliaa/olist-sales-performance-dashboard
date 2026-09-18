# KPI 1: Weekday vs Weekend (order_purchase_timestamp) payment statistics
# KP1 2: Number of orders with review score 5 and payment type as credit card
# KPI 3: Average delivery days
# KPI 4: Average item price
# KPI 5: Cancellation rate

# KPI 1: Weekday vs Weekend (order_purchase_timestamp) payment 
SELECT * FROM olist.orders;
SELECT * FROM olist.order_payments;

SELECT kpi1.day_end,
	CONCAT(round(kpi1.total_payment / (SELECT SUM(payment_value) FROM order_payments) * 100, 2)
, '%') AS percentage_payment_values
FROM
	(SELECT ord.day_end, SUM(pmt.payment_value) AS total_payment
    FROM order_payments AS pmt
    JOIN
(select distinct order_id,
case
when weekday(order_purchase_timestamp) in (5,6) then "Weekend"
else "Weekday"
end as Day_end
from orders) as ord
on ord.order_id = pmt.order_id
group by ord.day_end) as kpi1 ;

# KP1 2: Number of orders with review score 5 and payment type as credit card
select
count(pmt.order_id) as Total_Orders
from
order_payments pmt
inner join order_reviews rev on pmt.order_id = rev.order_id
where
rev.review_score = 5
and pmt.payment_type = 'credit_card' ;

# KPI 3: Average Delivery Days
SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        0
    ) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

# KPI 4: Average Item Price
SELECT
    ROUND(AVG(price), 2) AS avg_item_price
FROM order_items;

# KPI 5: Order cancellation rate
SELECT
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN order_status = 'canceled' THEN 1
            ELSE 0
        END
    ) AS canceled_orders,
    ROUND(
        SUM(
            CASE
                WHEN order_status = 'canceled' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM orders;
