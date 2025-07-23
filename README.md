# 📊 Netflix Uncovered: SQL Insights

![](https://github.com/AritroPaul23/Netflix-Data-Analysis/blob/main/Netflix_Logo_PMS.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## 📌 Project Highlights

🗃️ Cleaned and structured raw Netflix data for analysis

🧾 Solved real-world business queries using MySQL

📈 Uncovered trends across genres, release years, ratings, and more

🧩 Delivered actionable insights and key takeaways

💡 Focused on practical SQL skills, data storytelling, and analytical thinking

## 🛠️ Tech Stack
   💻 MySQL – Data Querying & Analysis

   🧹 SQL – Data Cleaning & Transformation

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schemas of netflix

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
( 
	show_id	VARCHAR(10),
	type VARCHAR(10),	
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(1000),
	country	VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(300)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
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
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT 
  type,
  rating,
  Count_of_Rating
FROM
( SELECT 
    type,
    rating,
    COUNT(*) as Count_of_Rating,
    RANK() OVER ( PARTITION BY type ORDER BY COUNT(*) DESC ) AS rnk
FROM netflix 
    GROUP BY 1, 2) AS temp_tbl
WHERE rnk = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT *
FROM netflix
WHERE release_year = 2020
      AND type = 'movie';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
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
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE STR_TO_DATE( date_added, '%M %d, %Y' ) >= CURDATE() - INTERVAL 5 YEAR ;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT 
  show_id,
  type,
  title,
  director
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
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
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
  YEAR(STR_TO_DATE( date_added, '%M %d,%Y' )) AS Year,
  COUNT(*),
  ROUND(COUNT(*) / ( SELECT COUNT(*) FROM netflix WHERE country = 'India' )*100, 2) AS AVG_Cntnt_Count
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 3 DESC;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix
WHERE LOWER(listed_in) LIKE '%documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT
  title,
  release_year
FROM netflix
WHERE
  casts LIKE '%Salman Khan%'
  AND
  release_year >= YEAR(CURDATE()) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
  CASE
  WHEN LOWER(description) LIKE '%kill%' or LOWER(description) LIKE '%violence%' THEN 'Bad'
  ELSE 'Good'
  END AS Remarks,
  COUNT(show_id) AS total
FROM netflix
GROUP BY Remarks;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## 𝐔𝐧𝐯𝐞𝐢𝐥𝐢𝐧𝐠 𝐊𝐞𝐲 𝐓𝐫𝐞𝐧𝐝𝐬 𝐟𝐫𝐨𝐦 𝐍𝐞𝐭𝐟𝐥𝐢𝐱 𝐃𝐚𝐭𝐚 𝐀𝐧𝐚𝐥𝐲𝐬𝐢𝐬 🚀

A recent deep dive into Netflix’s content catalog reveals valuable insights for content strategists and entertainment professionals:

🌍 𝐂𝐨𝐧𝐭𝐞𝐧𝐭 𝐕𝐨𝐥𝐮𝐦𝐞 𝐛𝐲 𝐂𝐨𝐮𝐧𝐭𝐫𝐲:
The U.S. leads with 𝟯,𝟲𝟵𝟬 titles, followed by India (𝟭,𝟬𝟰𝟲) and the UK (𝟴𝟬𝟲) — showcasing major production hubs and 𝐭𝐚𝐫𝐠𝐞𝐭 𝐦𝐚𝐫𝐤𝐞𝐭𝐬.

🎭 𝐓𝐨𝐩 𝐆𝐞𝐧𝐫𝐞𝐬:
International Movies (𝟮,𝟳𝟱𝟮), Dramas (𝟮,𝟰𝟮𝟳), and Comedies (𝟭,𝟲𝟳𝟰) dominate, reflecting global appeal and 𝙘𝙤𝙣𝙨𝙞𝙨𝙩𝙚𝙣𝙩 𝙫𝙞𝙚𝙬𝙚𝙧 𝙞𝙣𝙩𝙚𝙧𝙚𝙨𝙩.

🔞 𝐃𝐨𝐦𝐢𝐧𝐚𝐧𝐜𝐞 𝐨𝐟 𝐌𝐚𝐭𝐮𝐫𝐞 𝐂𝐨𝐧𝐭𝐞𝐧𝐭:
TV-MA is the most common rating — seen in 𝟮,𝟬𝟲𝟮 𝗺𝗼𝘃𝗶𝗲𝘀 and 𝟭,𝟭𝟰𝟱 𝗧𝗩 𝘀𝗵𝗼𝘄𝘀 — pointing to high demand for 𝙖𝙙𝙪𝙡𝙩-𝙛𝙤𝙘𝙪𝙨𝙚𝙙 𝙥𝙧𝙤𝙜𝙧𝙖𝙢𝙢𝙞𝙣𝙜. 🎬

📺 𝐓𝐕 𝐒𝐡𝐨𝐰 𝐋𝐨𝐧𝐠𝐞𝐯𝐢𝐭𝐲:
Only 𝟵𝟵 out of 𝟮,𝟲𝟳𝟲 𝗧𝗩 𝘀𝗵𝗼𝘄𝘀 have surpassed 𝟓 𝐬𝐞𝐚𝐬𝐨𝐧𝐬 — just 𝟯.𝟳%, underscoring the challenge of sustaining 𝙡𝙤𝙣𝙜-𝙩𝙚𝙧𝙢 𝙖𝙪𝙙𝙞𝙚𝙣𝙘𝙚 𝙚𝙣𝙜𝙖𝙜𝙚𝙢𝙚𝙣𝙩. 🎯

🧠 𝐂𝐨𝐧𝐭𝐞𝐧𝐭 𝐓𝐨𝐧𝐞 𝐂𝐥𝐚𝐬𝐬𝐢𝐟𝐢𝐜𝐚𝐭𝐢𝐨𝐧:
Based on keywords like "kill" and "violence", 8,465 items were categorized as "Good" and 342 as "Bad", offering a measurable lens on content tone.

🇮🇳 𝐓𝐨𝐩 𝐈𝐧𝐝𝐢𝐚𝐧 𝐀𝐜𝐭𝐨𝐫𝐬 𝐢𝐧 𝐌𝐨𝐯𝐢𝐞𝐬:
𝘼𝙣𝙪𝙥𝙖𝙢 𝙆𝙝𝙚𝙧 (40), 𝙎𝙝𝙖𝙝 𝙍𝙪𝙠𝙝 𝙆𝙝𝙖𝙣 (34), 𝙖𝙣𝙙 𝙉𝙖𝙨𝙚𝙚𝙧𝙪𝙙𝙙𝙞𝙣 𝙎𝙝𝙖𝙝 (31) top the list, highlighting their strong presence in 𝐈𝐧𝐝𝐢𝐚𝐧 𝐜𝐢𝐧𝐞𝐦𝐚.

These trends offer a data-backed view into what’s driving hashtag#Netflix’s content strategy, audience preferences, and the evolving media landscape. 📈

What’s your take on building long-lasting, impactful content in today’s fast-paced streaming world? Share your thoughts! 👇

### Stay Updated and Join the Community

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/aritropaul23/)

## Author

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

Feel free to ⭐ star the repo if you find it helpful, and fork it to explore further!
Let’s decode Netflix with SQL! 🚀
