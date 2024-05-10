-- 1. What is the total amount each customer spent at the restaurant?
select 
s.customer_id,
SUM(m.price) as Total 
from sales s join menu m 
on s.product_id=m.product_id 
group by customer_id

-- 2. How many days has each customer visited the restaurant?
select customer_id,
count(distinct order_date) as #count
from sales 
group by customer_id;


--3. What was the first item from the menu purchased by each customer?

WITH table1 AS(
    SELECT
        s.customer_id,
        m.product_id,
        m.product_name,
        s.order_date,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS Rank
    FROM 
        sales s 
    JOIN 
        menu m ON s.product_id = m.product_id
)
SELECT customer_id,product_name from table1 where Rank =1


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1
  m.product_name as Most_Purchased_Product,
  COUNT(s.product_id) as No_of_times_Purchased
 from sales s join menu m 
 on m.product_id = s.product_id
  group by s.product_id,m.product_name 
  Order by COUNT(s.product_id) desc

-- 5. Which item was the most popular for each customer?

SELECT customer_id, product_name 
FROM (
    SELECT s.customer_id, m.product_name, COUNT(m.product_name) AS product_count,
           RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(m.product_name) DESC) AS rank_num
    FROM sales s 
    JOIN menu m ON s.product_id = m.product_id 
    GROUP BY s.customer_id, m.product_name
) AS X 
WHERE rank_num = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH master_dining_table AS (
    SELECT 
        s.customer_id,
        s.order_date,
        mm.join_date,
        m.product_name,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS first_time
    FROM 
        sales s 
        JOIN menu m ON s.product_id = m.product_id
        JOIN members mm ON mm.customer_id = s.customer_id 
    WHERE 
        s.order_date >= mm.join_date
)

SELECT 
    customer_id, 
    order_date, 
    product_name 
FROM 
    master_dining_table 
WHERE 
    first_time = 1;

-- 7. Which item was purchased just before the customer became a member?

WITH master_dining_table AS (
    SELECT 
        s.customer_id,
        s.order_date,
        mm.join_date,
        m.product_name,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date desc) AS last_time_before_member
    FROM 
        sales s 
        JOIN menu m ON s.product_id = m.product_id
        JOIN members mm ON mm.customer_id = s.customer_id 
    WHERE 
        s.order_date < mm.join_date
)

SELECT 
    customer_id, 
    order_date, 
    product_name
FROM 
    master_dining_table 
WHERE 
    last_time_before_member = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
    
    SELECT 
        s.customer_id,
        COUNT(m.product_name) as total_items,
        SUM(m.price) as Amount_Spent

    FROM 
        sales s 
        JOIN menu m ON s.product_id = m.product_id
        JOIN members mm ON mm.customer_id = s.customer_id 
    WHERE 
        s.order_date < mm.join_date
    group by s.customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select s.customer_id,
sum(case when m.product_name = 'sushi' then m.price*20
     else m.price*10
     end ) as total_points
from sales s join menu m on s.product_id=m.product_id 
group by s.customer_id 
ORDER by s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January? 

SELECT 
        s.customer_id,
        SUM(
            case 
            WHEN m.product_name='sushi' then m.price*20
            when m.product_name!= 'sushi' and s.order_date>=mm.join_date AND DATEDIFF(DAY,mm.join_date,s.order_date)<=6 then m.price*20
            else m.price*10 
            end) as total_points
    FROM 
        sales s 
        JOIN menu m ON s.product_id = m.product_id
        JOIN members mm ON mm.customer_id = s.customer_id where order_date<= '2021-01-31' group by s.customer_id

-- Bonus Questions --

--Join all the tables so that the Danny's team get insights without referencing all tables seperately.

SELECT 
s.customer_id,
s.order_date,
m.product_name,
m.price,
case 
when s.order_date>=mm.join_date then 'Y' 
else 'N' 
end as  member
from sales s join menu m on s.product_id=m.product_id
join members mm on s.customer_id=mm.customer_id

-- Rank all the things

with datatable as(
SELECT 
s.customer_id,
s.order_date,
m.product_name,
m.price,
case 
when s.order_date>=mm.join_date then 'Y' 
else 'N' 
end as  member
from sales s join menu m on s.product_id=m.product_id
join members mm on s.customer_id=mm.customer_id)

Select *,
case 
when member='N' then null
else rank() OVER (Partition by customer_id,member order by order_date) end as ranking
 from datatable