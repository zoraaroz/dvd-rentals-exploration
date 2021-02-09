/* Query 1 - query used for question 1 */
SELECT DATE_PART('month',DATE_TRUNC('month',rental_date)) AS rental_month,
       DATE_PART('year',DATE_TRUNC('year',rental_date))   AS rental_year,
       s.store_id,
       COUNT(r.rental_id) AS rental_count
 FROM  rental r
 JOIN  staff s
 ON    r.staff_id = s.staff_id
 GROUP BY 1,2,3 -- group by month, year and store id
 ORDER BY 2 -- order by year


/* Query 2 - query used for question 2 */
/* CTE to determine the top 10 customers*/
WITH top_ten AS (SELECT c.first_name || ' ' || c.last_name AS full_name,
                        c.customer_id,
                        COUNT(p.payment_id) payment_count,
                        SUM(p.amount) payment_total
                 FROM   customer c
                 JOIN   payment p
                 ON     c.customer_id = p.customer_id
                 GROUP BY 1,2
                 ORDER BY 4 DESC
                 LIMIT 10)
/* query to determine the total payment per month for the top 10 customers*/
SELECT DATE_TRUNC('month',p.payment_date) month_year, top_ten.full_name,
       COUNT(p.payment_id) payment_count,
       SUM(p.amount) payment_total
FROM   top_ten
JOIN   payment p
ON     top_ten.customer_id = p.customer_id
GROUP BY 1, 2 -- group by date, customer
ORDER BY 2; -- order by full name


/* Query 3 - query used for question 3 */
/* CTE to determine the top 10 customers*/
WITH         top_ten AS (SELECT c.first_name || ' ' || c.last_name AS full_name,
            		        c.customer_id,
            		        COUNT(p.payment_id) payment_count,
            		        SUM(p.amount) payment_total
            		 FROM   customer c
            		 JOIN   payment p
            		 ON     c.customer_id = p.customer_id
            		 GROUP BY 1,2 -- group by customer, customer_id
            		 ORDER BY 4 DESC -- order by total payment
            		 LIMIT 10),
/* CTE to determine thhe total payment per month for the top 10 customers*/
     top_ten_payment AS (SELECT DATE_TRUNC('month',p.payment_date) month_year, 
				top_ten.full_name,
            			SUM(p.amount) payment_total
            		 FROM   top_ten
            		 JOIN   payment p
            		 ON     top_ten.customer_id = p.customer_id
            		 GROUP BY 1, 2 -- group by date, customer
            		 ORDER BY 2,1) -- order by customer, date
/* query to determine the difference to the next month's payment for each customer*/
SELECT month_year, full_name, lead_difference
FROM   (SELECT month_year, full_name,
               LEAD(payment_total) OVER (PARTITION BY full_name) - payment_total AS lead_difference
	FROM   top_ten_payment) sub
WHERE  lead_difference IS NOT NULL -- exclude NULL values (last month for each customer)
ORDER BY 2,1; -- order by customer, date


/* Query 4 - query used for question 4 */
SELECT f.title title, cat_sub.name category, COUNT(r.rental_id) rental_count
FROM   (SELECT name, category_id
	      FROM category
	      WHERE name IN ('Animation','Children','Classics','Comdey','Family','Music')) cat_sub
JOIN   film_category fc
ON     fc.category_id = cat_sub.category_id
JOIN   film f
ON     f.film_id = fc.film_id
JOIN   inventory i
ON     f.film_id = i.film_id
JOIN   rental r
ON     i.inventory_id = r.inventory_id
GROUP BY 1,2 -- group by title, category
ORDER BY 2,1; -- order by category, title
