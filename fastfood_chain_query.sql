create database FastFoodchain;

use FastFoodchain;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- 1. Retrive total number of order placed 

select * from orders;

SELECT 
    COUNT(order_id) AS total_num_of_orders
FROM
    orders; 

-- 2. Calculate the total revenue (total sales )generated from pizza sales 

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price)) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- 3. Identify the highest price pizza .

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- 4 identify most common size pizza size ordered . 

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1; 

-- List top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name AS name,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category AS category,
    SUM(order_details.quantity) AS total_quantity
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY category
ORDER BY total_quantity DESC; 

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour;

-- Find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS name
FROM
    pizza_types
GROUP BY category; 

-- Group the orders by date and calculate the average number of pizzas ordered per day.

with my_cte as (SELECT 
   sum(order_details.quantity) AS num_of_pizza,
    orders.order_date AS order_date
FROM
    order_details
        JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY order_date)

select round(avg(num_of_pizza),0)  as avg_pizzas_ordered_per_day from my_cte;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name AS pizza_type,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
-- cte : commom table expession 

With my_cte_1 as(SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id
)

SELECT 
    pizza_types.category as pizza_type,
    ROUND(SUM(order_details.quantity * pizzas.price) / (select total_sales from my_cte_1) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.

with cte_3 as (SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.order_date)

select order_date,sum(revenue) over (order by order_date) as cum_revenue
from cte_3;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from (select category, name , revenue, rank() 
over (partition by category order by revenue desc) as rn 
from 
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM((order_details.quantity) * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name)as a)as b
where rn <=3;


































