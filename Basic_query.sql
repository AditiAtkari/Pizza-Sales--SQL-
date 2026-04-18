use pizzahut;
-- Basic:
-- 1.  Retrieve the total number of orders placed.
SELECT COUNT(order_id)
FROM orders;


SELECT COUNT(order_id) AS Total_orders
FROM orders; #name the table 


-- 2.  Calculate the total revenue generated from pizza sales.
SELECT SUM(order_details.quantity * pizzas.price) AS Total_sales
FROM order_details 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;

# we round off in 2 decimal number
SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS Total_sales
FROM  order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;


-- 3.  Identify the highest-priced pizza.
SELECT pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC  LIMIT 1;


-- 4. Identify the most common pizza size ordered.
SELECT  quantity, COUNT(order_details_id)
FROM order_details
GROUP BY quantity; #to count the  quentity comenly order

SELECT pizzas.size,
COUNT(order_details.order_details_id) AS ORDER_COUNT
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size ORDER BY order_count DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,
sum(order_details.quantity) as Quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name  order by  quantity desc limit 5 ;



-- Intermediate:
-- 1. Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,
sum(order_details.quantity) as Quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by quantity desc;



-- 2. Determine the distribution of orders by hour of the day.
select hour(order_time) as Hour, count(order_id) as Order_count from orders
group by hour(order_time);



-- 3. Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;


-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.

select round (avg(quantity),0) as avg_pizza_ordered_per_day from
(select orders.order_date , sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;



-- 5. Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;



-- Advanced:
-- 1. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(
        SUM(order_details.quantity * pizzas.price) /
        (
            SELECT SUM(od.quantity * p.price)
            FROM order_details od
            JOIN pizzas p ON od.pizza_id = p.pizza_id
        ) * 100,
    2) AS revenue_percentage
FROM pizza_types
JOIN pizzas 
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;


-- 2. Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over (order by order_date) as cumulative_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price)  as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders 
on orders.order_id = order_details.order_id
group by  orders.order_date) as sales;


-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from
(select category , name , revenue ,
rank() over(partition by category order by revenue desc)  as rn
from
(select pizza_types.category , pizza_types.name,
sum((order_details.quantity)* pizzas.price)as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as  a) as b
where rn <=3;

