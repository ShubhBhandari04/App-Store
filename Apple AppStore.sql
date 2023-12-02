-- Check the number of unique apps in both tableAppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description

-- Check for any missing values in key filesAppleStore

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS null

-- Find out the number of app per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

-- Get an overview of the apps ratings

SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
	   avg(user_rating) AS AvgRating
FROM AppleStore

-- START--

-- Determine whether paid apps have higher ratings than free apps

SELECT CASE 
           WHEN price > 0 THEN 'Paid'
		   ELSE 'Free'
		END AS App_Type,
		avg(user_rating) AS Avg_Rating

From AppleStore
GROUP BY 
    CASE 
        WHEN price > 0 THEN 'Paid'
        ELSE 'Free'
    END;


-- Check if apps with more supported languages have higher rating

SELECT language_bucket,
    AVG(user_rating) AS Avg_Rating
FROM (
    SELECT 
           CASE
           WHEN lang_num < 10 THEN '<10 languages'
		   WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
		   ELSE '>30 language'
		END AS language_bucket,
		user_rating
From AppleStore
) AS subquery
GROUP BY language_bucket
ORDER BY Avg_Rating DESC


-- Check genres with low rating

SELECT TOP 10
       prime_genre,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC

-- Check if there is correlation between the lenght if the app description and the user rating 

WITH DescriptionBucketCTE AS (
 SELECT CASE 
            WHEN len(b.app_desc) < 300 THEN 'Short'
            WHEN len(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
            ELSE 'Long'
        END AS description_length_bucket,
        user_rating_ver AS average_rating
FROM AppleStore AS a
JOIN appleStore_description AS b ON a.id = b.id
)
SELECT description_length_bucket,
       AVG(average_rating) AS average_rating
FROM DescriptionBucketCTE
GROUP BY description_length_bucket
ORDER BY average_rating DESC;


-- Check the top-rating apps for each genre

SELECT 
    Prime_genre,
    track_name,
    user_rating
FROM (
    SELECT 
        Prime_genre,
        track_name,
        user_rating,
        RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
    FROM
        AppleStore
) AS a
WHERE
    a.rank = 1;
