# Netflix Movies and TV Shows Data Analysis using SQL

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.


## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select 
      type,
	  count(*)
from netflix_titles
group by type
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select title from netflix_titles
where release_year = '2020'
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TOP 5 country, COUNT(*) AS total_content
FROM (
    SELECT TRIM(value) AS country  -- Remove leading/trailing spaces
    FROM netflix_titles
    CROSS APPLY STRING_SPLIT(country, ',')
) AS t1
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT * 
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT * 
FROM netflix_titles
WHERE TRY_CONVERT(DATE, date_added, 107) >= DATEADD(YEAR, -5, GETDATE());
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select * from netflix_titles
where director = 'Rajiv Chilaka'
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT * 
FROM netflix_titles
WHERE type = 'TV Show' 
AND TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    TRIM(value) AS genre, 
    COUNT(*) AS total_content
FROM netflix_titles
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value)
ORDER BY total_content DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT TOP 5 
    YEAR(CAST(date_added AS DATE)) AS release_year,
    COUNT(*) * 1.0 / COUNT(DISTINCT type) AS avg_content_release
FROM netflix_titles
WHERE country LIKE '%India%'
AND date_added IS NOT NULL
GROUP BY YEAR(CAST(date_added AS DATE))
ORDER BY avg_content_release DESC;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select title as 'Documentary', release_year from netflix_titles
where listed_in = 'Documentaries'
order by release_year
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
Select * from netflix_titles
where director is NULL
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT title as 'Movies', release_year 
FROM netflix_titles
WHERE type = 'Movie'
AND casts LIKE '%Salman Khan%'
AND YEAR(CAST(date_added AS DATE)) >= YEAR(GETDATE()) - 10
order by release_year
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
select top 10
TRIM(value) AS actor, 
    COUNT(*) as Number_of_times
FROM netflix_titles
CROSS APPLY STRING_SPLIT(casts, ',')
where country = 'India'
GROUP BY TRIM(value)
ORDER BY Number_of_times DESC;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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

```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Aniket Dhaniskar

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

Thank you for your support, and I look forward to connecting with you!
