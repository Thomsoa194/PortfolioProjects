SELECT * 
FROM years
ORDER by year DESC

-- What were the 10 highest rated reviews in 2017?

SELECT reviews.reviewid, title, artist, score, pub_date, content
FROM reviews
JOIN content 
	ON content.reviewid = reviews.reviewid
WHERE pub_year = 2017
ORDER BY score DESC;

-- Which day of the week is most popular for a review?
SELECT DayOfWeek, COUNT(*) as Count
FROM review_day_of_week
GROUP BY DayOfWeek
ORDER BY 2 DESC;


-- Which day of the week recieves the highest average review?
CREATE VIEW review_day_of_week AS 
SELECT pub_weekday, 
CASE WHEN pub_weekday = 0 THEN 'Monday'
	WHEN pub_weekday = 1 THEN 'Tuesday'
	WHEN pub_weekday = 2 THEN 'Wednesday'
	WHEN pub_weekday = 3 THEN 'Thursday'
	WHEN pub_weekday = 4 THEN 'Friday'
	WHEN pub_weekday = 5 THEN 'Saturday'
	WHEN pub_weekday = 6 THEN 'Sunday'
	END AS 'DayOfWeek',
	score,
	title, 
	artist,
	reviewid
FROM reviews;

SELECT DayOfWeek, AVG(score)
FROM review_day_of_week
GROUP BY DayOfWeek
ORDER BY 2 DESC;



-- Which genre recieves the highest average review?

SELECT genre, AVG(score)
FROM reviews
JOIN genres	
	ON genres.reviewid = reviews.reviewid
WHERE genre IS NOT NULL
GROUP BY genre
ORDER BY 2 DESC

-- What is the highest review score by label?

SELECT label, MAX(score)
FROM reviews
JOIN labels 
 ON labels.reviewid = reviews.reviewid
GROUP BY 1
ORDER BY 2 DESC

SELECT title, artist
FROM reviews
GROUP BY title, artist

-- Which author type publishes the most reviews?

SELECT author_type, COUNT(*) as 'Number of reviews'
FROM reviews
WHERE author_type IS NOT NULL
GROUP BY author_type
ORDER BY 2 DESC






