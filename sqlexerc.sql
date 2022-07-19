SELECT *
FROM actor
WHERE actor_id >= 10 AND (first_name LIKE '%b' OR first_name LIKE '%a')

SELECT COUNT(*)
FROM actor;   --200

SELECT COUNT(DISTINCT first_name)
FROM actor;   --128


SELECT actor_id,first_name
FROM actor
LIMIT 6;  --it returs the first 6 results

SELECT *
FROM customer
WHERE first_name LIKE 'T%' AND last_name LIKE '%t' OR (first_name LIKE 'B%' OR last_name LIKE'%b' );

--What are the d/t rental durations that the store allows?
SELECT DISTINCT rental_duration
FROM film
ORDER BY 1 DESC;

--What are the IDs of the last 3 customers return a rental?
SELECT customer_id, return_date
FROM rental
WHERE return_date IS NOT NULL
  ORDER BY return_date DESC
  LIMIT 3;

  --How many films are rated NC-17 and PG or PG-13
SELECT COUNT(*)
FROM film
WHERE rating= 'NC-17' OR rating = 'PG' OR rating = 'PG-13';

--HOW many d/t customers have entires in the rental table?
SELECT COUNT(DISTINCT customer_id)
FROM rental;  --599

--**********************
--LIKE & NOT LIKE
SELECT COUNT(*)
FROM customer
WHERE first_name NOT LIKE 'A%';

SELECT *
FROM actor 
WHERE first_name LIKE 'A___';

--BETWEEN
SELECT *
FROM customer 
WHERE customer_id BETWEEN 5 AND 10;

--IN and NOT IN
SELECT *
FROM customer 
WHERE first_name IN ('Jennifer','Elizabeth', 'Susan')

SELECT *
FROM customer 
WHERE first_name NOT IN ('Jennifer','Elizabeth', 'Susan')


--IN with in sub query
--it returns someone who doesn't rent a film 
SELECT *
FROM customer
WHERE customer_id NOT IN(
   SELECT customer_id 
   FROM rental);
  
  --it returns only the customer_id who doesn't return the rented film  
SELECT customer_id ,return_date
FROM rental
WHERE return_date IS NULL;

--it returns full information about the customer_id who doesn't return the rented film
SELECT *
FROM customer 
WHERE customer_id IN (
    SELECT customer_id
    FROM rental
    WHERE return_date IS NULL
);

--SUM
--it returns total amount of payment
SELECT sum(amount)
FROM payment;
--it returns the sum of payment for individual customer
SELECT customer_id , SUM(amount)
FROM payment
GROUP BY customer_id;

--COUNT
SELECT COUNT(DISTINCT customer_id)
FROM payment;

--CAST
--it returns how much a customer pays per day
SELECT customer_id, CAST(payment_date AS DATE),SUM(amount)
FROM payment
WHERE customer_id = 3
GROUP BY customer_id, CAST(payment_date AS DATE)
ORDER BY payment_date DESC;

--HAVING
SELECT customer_id 
     ,CAST(payment_date AS DATE)
	 ,SUM(amount)
FROM payment
GROUP BY customer_id, CAST(payment_date AS DATE)
HAVING SUM(amount) > 10
ORDER BY customer_id;

--
SELECT customer_id, count(payment_id)
FROM payment
GROUP BY customer_id
ORDER BY COUNT(payment_id) DESC;

--the amount of rent by a customer
SELECT customer_id, COUNT(rental_id) 
FROM rental 
GROUP BY customer_id
ORDER BY customer_id;


SELECT customer_id, COUNT(rental_id) 
FROM rental 
GROUP BY customer_id
ORDER BY  COUNT(rental_id) DESC
LIMIT 10;

--AVG
SELECT customer_id, ROUND(AVG(amount), 2) 
FROM payment
GROUP BY customer_id
ORDER BY ROUND(AVG(amount), 2) DESC

--JOIN
SELECT city.country_id, country,
    COUNT(city) numbrt_of_cities
FROM city
    INNER JOIN country
	ON city.country_id=country.country_id
GROUP BY city.country_id, country
ORDER BY numbrt_of_cities DESC

--how money cities in Ethiopia
SELECT city.country_id, country,
    COUNT(city) number_of_cities
FROM city 
    INNER JOIN country
	ON city.country_id=country.country_id
WHERE country='Ethiopia'
GROUP BY  city.country_id ,country;


--number of cities for each coutry and country names
SELECT ct.country_id, country, COUNT(city) AS number_of_cities
FROM country cr
    LEFT JOIN city ct
	ON cr.country_id =ct.country_id 
GROUP BY ct.country_id, country 
ORDER BY COUNT(city) DESC;

--return list of customers that haven't rentedany more so far? 
SELECT c.*
FROM customer c
  LEFT JOIN rental r
  ON c.customer_id= r.customer_id
WHERE r.customer_id IS NULL;


--what is the average rental rate for each genere?
SELECT ROUND(AVG(f.rental_rate), 2), ct.name 
FROM category ct
     INNER JOIN film_category fc
	 ON ct.category_id=fc.category_id
	 INNER JOIN film f
	 ON fc.category_id= f.film_id
GROUP BY ct.name
ORDER BY AVG(f.rental_rate) DESC;

--UNION/UNION ALL, THE FASTERST IS UNION ALL BECAUSE IT DOESN'T DO ANY OPERATION, IT JUST MERGES TWO --
--EXCEPT RETURNS ONLY ROWS THAT APPEAR IN THE FIRST RESULT SET BUT DO NOT APPEAR IN THE SECOND-- 

--all the payment made by customers from beggning to end--
SELECT customer_id, SUM (amount)
FROM payment
GROUP BY customer_id
ORDER BY 2; 

SELECT *
FROM payment; 

--customer spending  is between 0 & 30 and between 30 & 60--
SELECT 
    customer_id, 
    Total_spend,
    CASE WHEN Total_spend <= 30 THEN 'Bronze'
         WHEN Total_spend >30 AND Total_spend <= 60 THEN 'Silver'
         WHEN Total_spend >60 AND Total_spend <= 90 THEN 'Gold'
         WHEN Total_spend >90 THEN 'Diamond'
    END AS Customer_grading
FROM (
        SELECT customer_id, SUM (amount) AS Total_spend
        FROM payment
        GROUP BY customer_id
        ORDER BY 2 ) sub;

   -- best practice to save memory space and our time, an optimized or efficient query--
 
 SELECT 
    customer_id, 
    Total_spend,
    CASE WHEN Total_spend <= 30 THEN 'Bronze'
         WHEN Total_spend <= 60 THEN 'Silver'
         WHEN Total_spend <= 90 THEN 'Gold'
         ELSE 'Diamond'
    END AS Customer_grading
FROM (
        SELECT customer_id, SUM (amount) AS Total_spend
        FROM payment
        GROUP BY customer_id  
         ORDER BY 2 ) sub;    

 -- Creating temporary table, writing codes this way is cleaner and helps to do additional analysis--
--Common Table Expressions (CTE) --
WITH sub AS (SELECT customer_id, SUM (amount) AS Total_spend
        FROM payment
        GROUP BY customer_id
        ORDER BY 2 )
        
SELECT 
    customer_id, 
    Total_spend,
    CASE WHEN Total_spend <= 30 THEN 'Bronze'
         WHEN Total_spend <= 60 THEN 'Silver'
         WHEN Total_spend <= 90 THEN 'Gold'
         ELSE 'Diamond'
    END AS Customer_grading
FROM sub;      

--create more temporary table--
--use the same WITH and separate the tables using coma-- 
WITH sub AS (SELECT customer_id, SUM (amount) AS Total_spend
        FROM payment
        GROUP BY customer_id
        ORDER BY 2 ), 
        customer_grading AS (SELECT 
                                   customer_id, 
                                   Total_spend,
                             CASE WHEN Total_spend <= 30 THEN 'Bronze'
                             WHEN Total_spend <= 60 THEN 'Silver'
                             WHEN Total_spend <= 90 THEN 'Gold'
                             ELSE 'Diamond'
                          END AS Customer_grading
FROM sub)

SELECT customer_grading, COUNT (customer_grading)
FROM customer_grading
GROUP BY Customer_grading
ORDER BY 2;

--WINDOW FUNCTIONS--
SELECT customer_id, DATE(payment_date), SUM (amount) AS Total_spend
FROM payment 
GROUP BY 1, 2; 

SELECT *
,SUM (amount) OVER (PARTITION BY customer_id) AS Total_spend
FROM payment 
ORDER BY customer_id;

SELECT *
,SUM (amount) OVER (PARTITION BY staff_id) AS Total_spend
FROM payment 
ORDER BY staff_id;

SELECT staff_id,
       payment_date
,SUM (amount) OVER (--PARTITION BY staff_id
    ORDER BY payment_date) AS Total_spend
FROM payment 

--ORDER BY DATE(payment_date) DESC;
SELECT staff_id,
       DATE(payment_date)
,SUM (amount) OVER (PARTITION BY staff_id ORDER BY payment_date) AS Total_spend,
ROW_NUMBER () OVER (ORDER BY payment_date) AS row_no
FROM payment; 

SELECT customer_id,
       amount,
      SUM (amount) OVER (ORDER BY customer_id) AS Total_spend,
      ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY amount) AS row_no,
      RANK () OVER (PARTITION BY customer_id ORDER BY amount) AS Rk,
      DENSE_RANK () OVER (PARTITION BY customer_id ORDER BY amount ) AS Dr
FROM payment; 