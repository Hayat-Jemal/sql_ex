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

