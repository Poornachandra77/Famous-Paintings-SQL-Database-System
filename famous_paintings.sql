SELECT * FROM artist;
SELECT * FROM canvas_size;
SELECT * FROM image_link;
SELECT * FROM museum_hours;
SELECT * FROM museum;
SELECT * FROM product_size;
SELECT * FROM subject;
SELECT * FROM work;

1) Fetch all the paintings which are not displayed on any museums?
SELECT * FROM work WHERE museum_id is NULL;

2) Are there museums without any paintings?

SELECT * FROM museum m 
JOIN work w ON m.museum_id = w.museum_id
WHERE w.name is Null

3) How many paintings have an asking price of more than their regular price? 

SELECT Count(work_id) FROM product_size
WHERE sale_price > regular_price

4) Identify the paintings whose asking price is less than 50% of its regular price

SELECT * FROM product_size
WHERE sale_price < 0.5*regular_price

5) Which canva size costs the most?

SELECT cs.label, ps.sale_price
FROM canvas_size cs JOIN product_size ps
ON cs.size_id::text = ps.size_id
ORDER BY ps.sale_price DESC
LIMIT 1

OR 

with ps as (SELECT *, rank() over(order by sale_price DESC) as rnk
FROM product_size) 

SELECT cs.label as canva, ps.sale_price 
FROM ps JOIN canvas_size cs
ON cs.size_id::text = ps.size_id
WHERE rnk = 1

6) Delete duplicate records from work, product_size, subject and image_link tables

DELETE FROM work 
	WHERE ctid NOT IN (select min(ctid)
						from work
						group by work_id );	
						
DELETE FROM product_size 
	WHERE ctid NOT IN (select min(ctid)
						from product_size
						group by work_id,size_id );	

DELETE FROM subject 
	WHERE ctid NOT IN (select min(ctid)
						from subject
						group by work_id)

DELETE FROM image_link 
	WHERE ctid NOT IN (select min(ctid)
						from image_link
						group by work_id)
						
7) Identify the museums with invalid city information in the given dataset
SELECT * FROM museum
WHERE city ~ '^[0-9]'

8) Museum_Hours table has 1 invalid entry. Identify it and remove it.
DELETE FROM museum_hours 
where ctid NOT IN 
	(SELECT min(ctid) From museum_hours
	 GROUP BY museum_id,day)
	 
9) Fetch the top 10 most famous painting subject

with rank as (SELECT s.subject, COUNT(1) as no_of_paintings, rank() over(order by COUNT(*) DESC) as rank
FROM work w JOIN subject s
ON w.work_id = s.work_id
GROUP BY s.subject)

SELECT * FROM rank where rank <=10
	
10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT name,city FROM museum_hours mh1
JOIN museum m ON m.museum_id = mh1.museum_id
Where day ='Sunday'
AND Exists(SELECT 1 FROM museum_hours mh2
			Where mh2.museum_id = mh1.museum_id 
		    AND day='Monday')
			
11) How many museums are open every single day?

SELECT COUNT(*) FROM (
						SELECT COUNT(*) FROM museum_hours
						GROUP BY museum_id 
						Having COUNT(*) = 7
					 )
					 
12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
with tp as (
	SELECT m.museum_id,COUNT(1), rank() over(order by count(1) desc) as rnk
	FROM museum m JOIN work w
	ON w.museum_id = m.museum_id
	GROUP BY m.museum_id
)
				   
SELECT m.name FROM tp JOIN museum m ON m.museum_id = tp.museum_id WHERE rnk <=5

OR

select m.name as museum, m.city,m.country,x.no_of_painintgs
	from (	select m.museum_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			group by m.museum_id) x
	join museum m on m.museum_id=x.museum_id
	where x.rnk<=5;					 
						
13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

with top_artists as (
	SELECT a.artist_id , COUNT(*) as no_of_paintings, rank() over(order by COUNT(*) desc) as rnk
	FROM artist a JOIN work w 
	ON a.artist_id = w.artist_id
	GROUP BY a.artist_id
)

SELECT a.full_name as artist, a.nationality,top_artists.no_of_paintings 
FROM top_artists JOIN artist a  
ON a.artist_id = top_artists.artist_id
where rnk <=5

OR

select a.full_name as artist, a.nationality,x.no_of_painintgs
	from (	select a.artist_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join artist a on a.artist_id=w.artist_id
			group by a.artist_id) x
	join artist a on a.artist_id=x.artist_id
	where x.rnk<=5;




