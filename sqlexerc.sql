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

GROUP WORK
--question 1
--A)Write ALL the queries we need to rent out a given movie. (Hint: these are the business logics that go into this task: first confirm that the given movie is in stock, and then INSERT a row into the rental and the payment tables. You may also need to check whether the customer has an outstanding balance or an overdue rental before allowing him/her to rent a new DVD).
--confirm that the given movie is in stock
SELECT title,film_id
FROM film
WHERE title='Airport Pollock'  --its exist in stock

--inserting data for new customer  
SELECT *
FROM customer
WHERE first_name='Linda' and last_name = 'Jones' --it doesn't exist

INSERT INTO customer (customer_id,store_id, first_name, last_name, email,address_id,activebool,active)
       VALUES (600,2, 'Linda', 'Jones','linda.jones@sakilacustomer.org',605,true,1);

--inserting data into rental table
SELECT *
FROM inventory
order by inventory_id DESC 

INSERT INTO inventory (inventory_id, film_id, store_id)
        VALUES (4582, 8, 2);
SELECT *
FROM rental
ORDER by rental_id desc

INSERT INTO rental (rental_id,rental_date, inventory_id, customer_id,staff_id)
        VALUES (16050, '2022-07-09 04:02:15',4582 ,600, 2);
		
SELECT *
FROM payment
ORDER BY payment_id desc

INSERT INTO payment (payment_id, customer_id, staff_id, rental_id,amount,payment_date)
        VALUES (32099, 600, 2, 16050,2.99,'2022-07-09 04:02:15');		

--B)write ALL the queries we need to process return of a rented movie. (Hint: update the rental table and add the return date by first identifying the rental_id to update based on the inventory_id of the movie being returned.)
SELECT *
FROM rental
ORDER by rental_id desc

UPDATE rental
SET 
    return_date = '2022-07-09 06:30:35'
WHERE
    rental_id = 16050;

 --question 2
--A)Which movie genres are the most and least popular? And how much revenue have they each generated for the business?
--the most popular and the highest revenue with the least popular and the lowest revenue
WITH highest AS (SELECT ct.category_id,name,COUNT(rental_rate) number_of_rental_rate,SUM(amount) revenue
FROM category ct
   INNER JOIN film_category fc
   ON ct.category_id = fc.category_id 
   INNER JOIN film f
   ON f.film_id = fc.film_id
    INNER JOIN inventory iv
   ON f.film_id = iv.film_id
   INNER JOIN rental r
   ON r.inventory_id = iv.inventory_id
   INNER JOIN payment p
   ON p.rental_id = r.rental_id 
   GROUP BY ct.category_id,name
ORDER BY SUM(amount) DESC
LIMIT 1 ),
lowest AS (SELECT ct.category_id,name,COUNT(rental_rate) number_of_rental_rate,SUM(amount) revenue
           FROM category ct
                INNER JOIN film_category fc
                ON ct.category_id = fc.category_id 
                INNER JOIN film f
                ON f.film_id = fc.film_id
                INNER JOIN inventory iv
                ON f.film_id = iv.film_id
                INNER JOIN rental r
                ON r.inventory_id = iv.inventory_id
                INNER JOIN payment p
                ON p.rental_id = r.rental_id
         GROUP BY ct.category_id,name
         ORDER BY SUM(amount) 
         LIMIT 1 ) 
SELECT * 
FROM highest
UNION ALL
SELECT * 
FROM lowes      

--the most popular movie
SELECT ct.category_id,name,COUNT(rental_rate) number_of_rental_rate
FROM category ct
   INNER JOIN film_category fc
   ON ct.category_id = fc.category_id 
   INNER JOIN film f
   ON f.film_id = fc.film_id
GROUP BY ct.category_id,name
ORDER BY COUNT(rental_rate) DESC 
LIMIT 1 

--the least popular movie
SELECT DISTINCT(fc.category_id),name,COUNT(rental_rate) number_of_rental_rate
FROM category ct
   INNER JOIN film_category fc
   ON ct.category_id = fc.category_id 
   INNER JOIN film f
   ON f.film_id = fc.film_id
GROUP BY fc.category_id,name
ORDER BY COUNT(rental_rate) 
LIMIT 1 

--****
--the most popular and the highest revenue

SELECT ct.category_id,name,COUNT(rental_rate) number_of_rental_rate,SUM(amount) revenue
FROM category ct
   INNER JOIN film_category fc
   ON ct.category_id = fc.category_id 
   INNER JOIN film f
   ON f.film_id = fc.film_id
    INNER JOIN inventory iv
   ON f.film_id = iv.film_id
   INNER JOIN rental r
   ON r.inventory_id = iv.inventory_id
   INNER JOIN payment p
   ON p.rental_id = r.rental_id
GROUP BY ct.category_id,name
ORDER BY SUM(amount) DESC

--it returns the least popular and the lowest revenue

SELECT ct.category_id,name,COUNT(rental_rate) number_of_rental_rate,SUM(amount) revenue
FROM category ct
   INNER JOIN film_category fc
   ON ct.category_id = fc.category_id 
   INNER JOIN film f
   ON f.film_id = fc.film_id
    INNER JOIN inventory iv
   ON f.film_id = iv.film_id
   INNER JOIN rental r
   ON r.inventory_id = iv.inventory_id
   INNER JOIN payment p
   ON p.rental_id = r.rental_id
GROUP BY ct.category_id,name
ORDER BY SUM(amount) 

--it returns the highest revenue
SELECT ct.category_id,name, SUM(amount) revenue
FROM category ct
   INNER JOIN film_category fc
   ON ct.category_id = fc.category_id 
   INNER JOIN film f
   ON f.film_id = fc.film_id
   INNER JOIN inventory iv
   ON f.film_id = iv.film_id
   INNER JOIN rental r
   ON r.inventory_id = iv.inventory_id
   INNER JOIN payment p
   ON p.rental_id = r.rental_id
GROUP BY ct.category_id,name
ORDER BY SUM(amount) DESC 
LIMIT 1

--B)What are the top 10 most popular movies? And how many times have they each been rented out thus far?
select title,rental_rate, COUNT(rental_id) 
from film f
   INNER JOIN inventory iv
   ON f.film_id = iv.film_id
   INNER JOIN rental r
   ON r.inventory_id = iv.inventory_id
GROUP BY f.film_id
ORDER BY rental_rate DESC
LIMIT 10

--C)Which genres have the highest and the lowest average rental rate?
--the highest average rental rate Genere
SELECT name, ROUND(AVG(rental_rate),2) avg_number_of_rental_rate
FROM category ct
   INNER JOIN film_category fc
   ON ct.category_id = fc.category_id 
   INNER JOIN film f
   ON f.film_id = fc.film_id
GROUP BY name
ORDER BY AVG(rental_rate) DESC    
LIMIT 1      --Games

--the lowest average rental rate Genere
SELECT name, ROUND(AVG(rental_rate),2) avg_number_of_rental_rate
FROM category ct
   INNER JOIN film_category fc
   ON ct.category_id = fc.category_id 
   INNER JOIN film f
   ON f.film_id = fc.film_id
GROUP BY name
ORDER BY AVG(rental_rate)  
LIMIT 1  --Action

--D)How many rented movies were returned late? Is this somehow correlated with the genre of a movie?
WITH date_difference AS (SELECT * ,DATE(return_date)-DATE(rental_date) As date_differ		 
   FROM rental),
   date_return AS (SELECT rental_duration, date_differ
				     FROM film f
                     LEFT JOIN inventory i
	                 ON f.film_id = i.film_id
	                 LEFT JOIN date_difference dd
	                 ON dd.inventory_id = i.inventory_id
	                 WHERE date_differ > rental_duration )
    SELECT COUNT(date_return) AS late_return
    FROM date_return

    --E)What are the top 5 cities that rent the most movies? How about in terms of total sales volume?
SELECT a.city_id,city,
       count(r.rental_id) no_of_rented_customer
FROM city
    INNER JOIN address  a
	ON city.city_id = a.city_id
	INNER JOIN customer cst
	ON cst.address_id = a.address_id
	INNER JOIN rental r
	ON r.customer_id = cst.customer_id
GROUP BY a.city_id,city
ORDER BY count(r.rental_id) DESC
LIMIT 5

--to check the exact result
WITH sub AS (SELECT a.city_id,city,
       count(r.rental_id) no_of_rented_customer
FROM city
    INNER JOIN address  a
	ON city.city_id = a.city_id
	INNER JOIN customer cst
	ON cst.address_id = a.address_id
	INNER JOIN rental r
	ON r.customer_id = cst.customer_id
GROUP BY a.city_id,city
ORDER BY count(r.rental_id) )
SELECT sum(no_of_rented_customer)
FROM sub

--the top 5 cities in terms of total sales volume
SELECT a.city_id,city, 
	   SUM(p.amount) 
FROM city
    INNER JOIN address  a
	ON city.city_id = a.city_id
	INNER JOIN customer cst
	ON cst.address_id = a.address_id
	INNER JOIN rental r
	ON r.customer_id = cst.customer_id
	INNER JOIN payment p
	ON p.rental_id = r.rental_id
GROUP BY a.city_id,city
ORDER BY SUM(p.amount) DESC
LIMIT 5

--F)let's say you want to give discounts as a reward to your loyal customers and those who return movies they rented on time. So, who are your 10 best customers in this respect?
--with out customer_id
WITH date_difference AS (
     SELECT *, DATE(return_date),DATE(rental_date),DATE(return_date)-DATE(rental_date) As date_differ
     FROM rental
     INNER JOIN customer c
     ON c.customer_id = rental.customer_id	),	
   movies_return_date AS (
    SELECT  first_name,last_name, rental_duration,date_differ
    FROM film f
    INNER JOIN inventory i
    ON f.film_id = i.film_id
    INNER JOIN date_difference dd
    ON dd.inventory_id = i.inventory_id
    WHERE date_differ <= rental_duration)     
SELECT *
FROM movies_return_date
GROUP BY rental_duration,date_differ,first_name,last_name
ORDER BY date_differ
LIMIT 10

--with customer_id
WITH date_difference AS (SELECT DATE(return_date),DATE(rental_date),DATE(return_date)-DATE(rental_date) As date_differ ,
						 inventory_id,first_name,last_name,rental.customer_id 
   FROM rental
	  INNER JOIN customer c
	  ON c.customer_id = rental.customer_id	),	
   movies_return_date AS (SELECT  first_name,last_name, rental_duration,date_differ,customer_id
				     FROM film f
                     INNER JOIN inventory i
	                 ON f.film_id = i.film_id
	                 INNER JOIN date_difference dd
	                 ON dd.inventory_id = i.inventory_id
				     WHERE date_differ <= rental_duration)     
    SELECT *
    FROM movies_return_date
	GROUP BY DISTINCT customer_id,rental_duration,date_differ,first_name,last_name
	ORDER BY date_differ
	LIMIT 10

    --G)What are the 10 best rated movies? Is customer rating somehow correlated with revenue?
--Which actors have acted in most number of the most popular or highest rated movies?
--the most popular movie
SELECT film.title, film.rental_rate, CONCAT(first_name, ' ', last_name) Actor_name
FROM film
INNER JOIN film_actor on
film.film_id = film_actor.film_id
INNER JOIN actor on
film_actor.actor_id = actor.actor_id
ORDER BY rental_rate DESC
LIMIT 10
-- WITH most_popular_movies AS (select  title,rental_rate,f.film_id
-- from film f
--    INNER JOIN inventory iv
--    ON f.film_id = iv.film_id
--    INNER JOIN rental r
--    ON r.inventory_id = iv.inventory_id
-- GROUP BY f.film_id
-- ORDER BY rental_rate DESC
-- LIMIT 10),
-- actors AS (
-- SELECT actor_id,first_name,last_name,title,rental_rate
-- FROM actor a
-- JOIN film_actor USING (actor_id)
-- JOIN most_popular_movies mpm USING  (film_id)
-- GROUP BY actor_id,first_name,last_name,film_id,title,rental_rate
-- ORDER BY rental_rate)
-- SELECT *
-- FROM actors
	
--H)Rentals and hence revenues have been falling behind among young families. In order to reverse this, you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT DISTINCT(title), category.name
FROM category
INNER JOIN film_category ON film_category.category_id = category.category_id
INNER JOIN film ON film.film_id=film.film_id
WHERE category.name='Family'

--I)How much revenue has each store generated so far?
SELECT store_id, SUM(amount) revenue
FROM payment
JOIN staff USING (staff_id)
GROUP BY store_id
