/*1) Fetch all the paintings which are not displayed on any museums?*/

select w.name from work as w where  not exists(
	select m.name from museum as m where w.museum_id=w.museum_id
)

/*2) Are there museuems without any paintings?*/

select count(museum_id) from museum where name='null'

/*2) 3) How many paintings have an asking price of more than their regular price? 
*/
	select count(w.work_id) from work as w
	join product_size as p on p.work_id=w.work_id where p.sale_price > p.regular_price

/*4) Identify the paintings whose asking price is less than 50% of its regular price*/

select Distinct(p.work_id) ,w.name from product_size as p
join work as w on p.work_id=w.work_id where p.sale_price > (p.regular_price/2)


/*5) Which canva size costs the most?*/
/*Delete duplicate records from work, product_size, subject and image_link tables	*/

/*Identify the museums with invalid city information in the given dataset*/

select name,city from museum
where city IS NULL 
    OR city ~ '[^a-zA-Z ]'

/*8 Museum_Hours table has 1 invalid entry. Identify it and remove it.*/
/*9) Fetch the top 10 most famous painting subject*/

select subject,count(subject) as count from subject
 group by subject order by count desc limit 10

/*Identify the museums which are open on both Sunday and Monday. Display museum name, city.*?
*/
select m.name as museum_name, m.city from museum_hours mh1
	join museum m on m.museum_id=mh1.museum_id
where day='Sunday'
and exists (
	select 1 from museum_hours mh2
	where mh2.museum_id=mh1.museum_id and mh2.day='Monday'
)

/*How many museums are open every single day?*/

select * from museum_hours
SELECT m.museum_id, m.name
FROM museum AS m
JOIN museum_hours AS mh ON m.museum_id = mh.museum_id
WHERE mh.day IN ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')
GROUP BY m.museum_id, m.name
HAVING COUNT(DISTINCT mh.day) = 7;


/*12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)*/

select * from work 

select museum_id, count(name) as count from work  where museum_id is not null
group by museum_id order by count desc limit 5 

with ctem as (

	select m.name, count(w.work_id) as pcount,
	row_number() over(order by count(w.work_id) desc) as rownum
	from museum as m join work as w on m.museum_id=w.museum_id group by m.name
)
select name,pcount,rownum from ctem where rownum<=5

/*13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)*/


	select a.full_name, count(w.work_id) as painting_count,
	row_number()over(order by count(w.work_id) desc ) as rownum
	from artist as a join work as w on a.artist_id=w.artist_id group by a.full_name limit 5

/* another method using cte*/
	
with acount as (
	select a.full_name, count(w.work_id) as painting_count,
	row_number()over(order by count(w.work_id) desc ) as rownum
	from artist as a join work as w on a.artist_id=w.artist_id group by a.full_name
)
select full_name as artist_name, painting_count from 
acount where rownum<=5

/*14) Display the 3 least popular canva sizes*/

with cte as(	
select c.size_id, count(w.work_id)as count,c.label,
DENSE_RANK()over (order by count(w.work_id) asc) as rownum
	from canvas_size as c
	join product_size as p on c.size_id=cast(p.size_id as bigint)
	join work as w on w.work_id=p.work_id
	WHERE p.size_id ~ '^[0-9]+$'
	group by c.size_id,c.label
	)
select size_id, count,label, rownum from cte
where rownum<=3

/*15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
*/

select m.name as Museum_name, m.state , mh.day,
to_timestamp(open, 'HH:MI AM')as open_time
,to_timestamp(close, 'HH:MI PM')as close_time,
to_timestamp(close, 'HH:MI PM') - to_timestamp(Open, 'HH:MI AM') as duration
from museum as m
join museum_hours as mh on m.museum_id=mh.museum_id 
order by duration desc limit 1

/*Another method*/
	
select * from(
select m.name as Museum_name, m.state , mh.day,
to_timestamp(open, 'HH:MI AM')as open_time
,to_timestamp(close, 'HH:MI PM')as close_time,
to_timestamp(close, 'HH:MI PM')-to_timestamp(Open, 'HH:MI AM') as duration,
rank() over(order by to_timestamp(close, 'HH:MI PM')-to_timestamp(Open, 'HH:MI AM') desc) as rownum
from museum as m
join museum_hours as mh on m.museum_id=mh.museum_id) x
where x.rownum<=1

/*16) Which museum has the most no of most popular painting style?*/

/*Identify the artists whose paintings are displayed in multiple countries*/

select a.full_name, count(distinct m.country) as country_count from artist as a
join work as w on a.artist_id=w.artist_id
join museum as m on w.museum_id=m.museum_id 
group by a.full_name having count(distinct m.country)>=2

/*18) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.
*/
with cte_country as (
    select country,count(1),
    rank()over(order by count(1) desc) as rnk
    from museum group by country),
  cte_city as (
    select city,count(1),
    rank()over(order by count(1) desc) as rnk
    from museum group by city)
    select string_agg(distinct country, ' , '), string_agg(city, ' , ') from cte_country
    cross join cte_city 
	where cte_country.rnk=1 and
    cte_city.rnk=1

/*20) Which country has the 5th highest no of paintings?*/

with cte as(
select m.country, count(w.work_id) ,
row_number() over (order by count(w.work_id) desc) as rownum
from museum as m 
join work as w on w.museum_id=m.museum_id
group by m.country order by count desc 
)
select country from cte where rownum=5 order by count desc

select * from museum where country='Spain'
select count(work_id) from work where museum_id in ('50',56)

/*Identify the artist and the museum where the most expensive and least expensive painting is placed. 
Display the artist name, sale_price, painting name, 
museum name, museum city and canvas label*/

select a.full_name as artist_name, w.name as painting_name, ps.sale_price, m.name as museum_name,
m.city as museum_city,cs.label as canvas_label from
artist as a 
join work as w on w.artist_id=a.artist_id
join product_size as ps on ps.work_id=w.work_id
join canvas_size as cs on cast(ps.size_id as bigint)=cs.size_id
join museum as m on w.museum_id=m.museum_id
WHERE ps.size_id ~ '^[0-9]+$'
order by ps.sale_price desc limit 1





