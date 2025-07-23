SELECT COUNT(*) FROM netflix;

-- Diff. type of content in netflix

SELECT DISTINCT type as content_type
FROM netflix;

-- 15 Business Problems

-- 1. Count the number of Movies vs TV Shows.

-- Method 1
SELECT 
		type,
        COUNT(*) AS Cnt_of
FROM netflix
GROUP BY type;

-- Method 2
SELECT 
		COUNT( DISTINCT CASE WHEN type = 'Movie' THEN show_id END ) AS Movie_Count,
        COUNT( DISTINCT CASE WHEN type = 'Tv Show' THEN show_id END ) AS TV_Show_Count
FROM netflix;

-- 2. Find the most common rating for movies and TV shows.

SELECT 
		type,
		rating,
        Count_of_Rating
FROM ( SELECT 
				type,
				rating,
				COUNT(*) as Count_of_Rating,
				RANK() OVER ( PARTITION BY type ORDER BY COUNT(*) DESC ) AS rnk
		FROM netflix 
        GROUP BY 1, 2) AS temp_tbl
WHERE rnk = 1;

-- 3. List all movies released in a specific year (e.g., 2020).

SELECT *
FROM netflix
WHERE release_year = 2020
		AND type = 'movie';
        
-- 4. Find the top 5 countries with the most content on Netflix. V.V.IMP

WITH RECURSIVE split_cte AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', 1), ',', -1)) AS country,
        1 AS part,
        country AS full
    FROM netflix
    WHERE country IS NOT NULL

    UNION ALL

    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(full, ',', part + 1), ',', -1)) AS country,
        part + 1,
        full
    FROM split_cte
    WHERE part < LENGTH(full) - LENGTH(REPLACE(full, ',', '')) + 1
)

SELECT country, COUNT(*) AS total
FROM split_cte
GROUP BY country
ORDER BY total DESC
LIMIT 5;

-- 5. Identify the longest movie.


-- Method 1
SELECT 
		title,
        duration
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(LEFT( duration, locate(" ", duration, 1)-1) AS UNSIGNED) DESC LIMIT 1;

-- Method 2 

/*
Syntax

SUBSTRING_INDEX(str, delim, count)
🔧 Parameters:
str: The full string you want to extract from.

delim: The delimiter to split on (e.g., ' ', ',', '-')

count:

If positive, returns the first count parts (from the left).

If negative, returns the last count parts (from the right).*/

/*Examples
Let’s say this is your string:

sql
'90 min'

1. Get the first word (before the space):

SELECT SUBSTRING_INDEX('90 min', ' ', 1);
-- Result: '90'
2. Get the second word:

SELECT SUBSTRING_INDEX('90 min', ' ', -1);
-- Result: 'min'
3. Get the first 2 parts (useful for 3-part strings):

SELECT SUBSTRING_INDEX('United States, China, United Kingdom', ',', 2);
-- Result: 'United States, China'
4. Get the last 2 countries:

SELECT SUBSTRING_INDEX('United States, China, United Kingdom', ',', -2);
-- Result: 'China, United Kingdom'*/

SELECT 
		title,
        duration
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC LIMIT 1;

-- 6. Find content added in the last 5 years.

SELECT *
FROM netflix
WHERE STR_TO_DATE( date_added, '%M %d, %Y' ) >= CURDATE() - INTERVAL 5 YEAR ;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT 
		show_id,
        type,
        title,
        director
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons.

SELECT *
FROM netflix
WHERE type = 'TV Show'
		AND
	  CAST( LEFT(duration, LOCATE(' ', duration, 1) - 1 ) AS UNSIGNED) > 5;
      
SELECT *
FROM netflix
WHERE type = 'TV Show'
		AND
	  CAST(SUBSTRING_INDEX( duration, ' ', 1 ) AS UNSIGNED) > 5;

-- 9. Count the number of content items in each genre.

SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.listed_in, ',', n.digit+1), ',', -1)) AS genre,
    COUNT(*) AS content_count
FROM
    netflix AS t
INNER JOIN
    (SELECT 0 digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL 
     SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS n
ON
    LENGTH(t.listed_in) - LENGTH(REPLACE(t.listed_in, ',', '')) >= n.digit
GROUP BY
    genre
ORDER BY
    content_count DESC, genre ASC;
    
/* 10.Find each year and the average numbers of content release in India on netflix. 
   return top 5 year with highest avg content release*/
   
SELECT 
		YEAR(STR_TO_DATE( date_added, '%M %d,%Y' )) AS Year,
        COUNT(*),
        ROUND(COUNT(*) / ( SELECT COUNT(*) FROM netflix WHERE country = 'India' )*100, 2) AS AVG_Cntnt_Count
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 3 DESC;

-- 11. List all movies that are documentaries.

SELECT *
FROM netflix
WHERE LOWER(listed_in) LIKE '%documentaries%';

-- 12. Find all content without a director.

SELECT *
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years.

SELECT title,
		release_year
FROM netflix
WHERE casts LIKE '%Salman Khan%'
		AND
        release_year >= YEAR(CURDATE()) - 10;
        
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(n.casts, ',', numbers.n), ',', -1)) AS actor_name,
    COUNT(*) AS movie_count
FROM
    netflix AS n
INNER JOIN
    (
        -- Generate a series of numbers to split the comma-separated string
        -- Adjust the upper limit (e.g., 50) if you expect a movie to have more than 50 cast members
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
        SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
        SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL
        SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL
        SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL
        SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL
        SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35 UNION ALL
        SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40 UNION ALL
        SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL SELECT 45 UNION ALL
        SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48 UNION ALL SELECT 49 UNION ALL SELECT 50
    ) AS numbers
ON
    -- Condition to ensure we only split up to the number of commas present
    CHAR_LENGTH(n.casts) - CHAR_LENGTH(REPLACE(n.casts, ',', '')) >= numbers.n - 1
WHERE
    n.type = 'Movie' -- Ensure we only count movies
    AND n.country LIKE '%India%' -- Filter for content produced in India (use LIKE for potential multiple countries)
    AND n.casts IS NOT NULL
    AND n.casts != ''
GROUP BY
    actor_name
ORDER BY
    movie_count DESC
LIMIT 10;

/* 15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

SELECT 
    CASE
        WHEN LOWER(description) LIKE '%kill%' or LOWER(description) LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS Remarks,
    COUNT(show_id) AS total
FROM netflix
GROUP BY Remarks;