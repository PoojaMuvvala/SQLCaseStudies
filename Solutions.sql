-- What is the total amount each customer spent at the restaurant?
select s.customer_id,SUM(m.price) as Total from sales s join menu m on s.product_id=m.product_id group by customer_id

-- How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date) as #count from sales group by customer_id

-- What was the first item from the menu purchased by each customer?
select s.customer_id,m.product_id,m.product_name from sales s join menu m on s.product_id=m.product_id order by s.order_date
