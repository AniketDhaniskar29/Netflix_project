EXEC sp_rename 'netflix_titles.[cast]', 'casts', 'COLUMN';

select * from netflix_titles
---------------------------------------------------------------------
select 
      count(*) as total_count
from netflix_titles
---------------------------------------------------------------------
select 
     distinct type
from netflix_titles
---------------------------------------------------------------------

--  Business Problems

-- Problem 1 - Count the number of Movies vs TV Shows

select 
      type,
	  count(*)
from netflix_titles
group by type

-- Problem 2 - Find the most common rating for movies and TV shows

with RatingCounts AS (
     select
	      type,
		  rating,
		  count(*) as rating_count
from netflix_titles
group by type, rating
),
RankedRating as (
      select
	    type,
	    rating,
	    rating_count,
	    rank() over (partition by type order by rating_count desc) as rank
from RatingCounts
)
select 
      type,
	  rating as most_frequent
from RankedRating
where rank = 1;

-- problem 3 -  List all movies released in a specific year (e.g., 2020)

select title from netflix_titles
where release_year = '2020'

-- Problem 4 - Find the top 5 countries with the most content on Netflix

SELECT TOP 5 country, COUNT(*) AS total_content
FROM (
    SELECT TRIM(value) AS country  -- Remove leading/trailing spaces
    FROM netflix_titles
    CROSS APPLY STRING_SPLIT(country, ',')
) AS t1
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC;


-- Problem 5 -  Identify the longest movie

SELECT * 
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) DESC;


-- Problem 6 - Find content added in the last 5 years

SELECT * 
FROM netflix_titles
WHERE TRY_CONVERT(DATE, date_added, 107) >= DATEADD(YEAR, -5, GETDATE());

-- Probelm 7 - Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix_titles
where director = 'Rajiv Chilaka'


-- Problem 8 - List all TV shows with more than 5 seasons

SELECT * 
FROM netflix_titles
WHERE type = 'TV Show' 
AND TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

-- Problem 9 - Count the number of content items in each genre

SELECT 
    TRIM(value) AS genre, 
    COUNT(*) AS total_content
FROM netflix_titles
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value)
ORDER BY total_content DESC;


-- Problem 10 - Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT TOP 5 
    YEAR(CAST(date_added AS DATE)) AS release_year,
    COUNT(*) * 1.0 / COUNT(DISTINCT type) AS avg_content_release
FROM netflix_titles
WHERE country LIKE '%India%'
AND date_added IS NOT NULL
GROUP BY YEAR(CAST(date_added AS DATE))
ORDER BY avg_content_release DESC;


-- Problem 11 - List all movies that are documentaries

select title as 'Documentary', release_year from netflix_titles
where listed_in = 'Documentaries'
order by release_year

-- Problem 12 - Find all content without a director

Select * from netflix_titles
where director is NULL

-- Problem 13 - Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT title as 'Movies', release_year 
FROM netflix_titles
WHERE type = 'Movie'
AND casts LIKE '%Salman Khan%'
AND YEAR(CAST(date_added AS DATE)) >= YEAR(GETDATE()) - 10
order by release_year

-- problem 14 - Find the top 10 actors who have appeared in the 
--highest number of movies produced in India.

select top 10
TRIM(value) AS actor, 
    COUNT(*) as Number_of_times
FROM netflix_titles
CROSS APPLY STRING_SPLIT(casts, ',')
where country = 'India'
GROUP BY TRIM(value)
ORDER BY Number_of_times DESC;


-- Problem 15 - Categorize the content based on the presence of the keywords 'kill' 
--and 'violence' in the description field. Label content containing these keywords 
--as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

select 
      case 
	      when description like '%kill%' or description like '%violence%' then 'Bad'
		  else 'Good'
		End as content_category,
		count(*) as total_count
from netflix_titles
group by
      case   
	      when description like'%kill%' or description like '%violence%' then 'Bad'
	      else 'Good'
	  end;
