select s.customer_id,SUM(m.price) as Total from sales s join menu m on s.product_id=m.product_id group by customer_id
