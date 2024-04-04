



--Dropping columns that can not be used

ALTER TABLE [RynairReviews].[dbo].[ryanair_reviews]
DROP COLUMN Comment

ALTER TABLE [RynairReviews].[dbo].[ryanair_reviews]
DROP COLUMN Comment_title


--Count of seat types by traveller type

SELECT 
 CASE 
  WHEN Type_of_traveller IS NULL THEN 'Unidentified'
  ELSE Type_of_traveller
 END AS 'Traveller type', Seat_type,
 COUNT(*) AS Count
FROM [RynairReviews].[dbo].[ryanair_reviews]
GROUP BY Type_of_traveller,Seat_type
ORDER BY COUNT(*) DESC

--Trip verification

SELECT Trip_verified, COUNT(*)
FROM [RynairReviews].[dbo].[ryanair_reviews]
GROUP BY Trip_verified

--Fixing syntax problems to have three possibilities(Trip verified, No information,Not verified) 

SELECT Verification,COUNT(*) AS Count
FROM (SELECT
 CASE 
   WHEN Trip_verified ='Verified Review' THEN 'Trip Verified'
   WHEN Trip_verified ='NotVerified' THEN 'Not Verified'
   WHEN Trip_verified ='Unverified' THEN 'Not Verified'
   WHEN Trip_verified IS NULL THEN 'No Information'
   ELSE Trip_verified 
  END AS Verification
FROM [RynairReviews].[dbo].[ryanair_reviews]) AS subquery
GROUP BY Verification
ORDER BY COUNT(*) DESC

--Recomend Ryanair

SELECT Recommended,COUNT(*) AS Count
FROM [RynairReviews].[dbo].[ryanair_reviews]
GROUP BY Recommended

--Recomendation percentage 

SELECT 
    ROUND(COUNT(CASE WHEN Recommended = 'yes' THEN 1 END) * 100.0 / COUNT(*),2) AS Recommendation_Percentage
FROM 
    [RynairReviews].[dbo].[ryanair_reviews];


--Recomended seat_types

SELECT Seat_Type,COUNT(Recommended)AS Count,Recommended
FROM [RynairReviews].[dbo].[ryanair_reviews]
GROUP BY Seat_Type,Recommended
ORDER BY COUNT(Recommended) DESC

 --TOP 10 recomended flights

  SELECT TOP(10) Origin,Destination,COUNT(*) AS Review_count,Recommended
   FROM [RynairReviews].[dbo].[ryanair_reviews]
    WHERE Recommended = 'yes'
   GROUP BY Origin, Destination,Recommended
   ORDER BY COUNT(*) DESC

   --TOP 10 Not recomended flights

   SELECT TOP(10) Origin,Destination,COUNT(*) AS Review_count,Recommended
   FROM [RynairReviews].[dbo].[ryanair_reviews]
    WHERE Recommended = 'no'
   GROUP BY Origin, Destination,Recommended
   ORDER BY COUNT(*) DESC

--Reviews publication after the flight (daf:days after flight)
--Afternote:can 100+ days can be counted as trustfull review?

SELECT DATEDIFF(day,Date_Flown,Date_Published)AS Daf,
COUNT(*) AS Review_count
FROM [RynairReviews].[dbo].[ryanair_reviews]
GROUP BY DATEDIFF(day,Date_Flown,Date_Published)

--Count of reviews per passanger country

SELECT Passenger_Country, COUNT(*) AS Count
FROM [RynairReviews].[dbo].[ryanair_reviews]
GROUP BY Passenger_Country
ORDER BY COUNT(*) DESC

--TOP 10 Popular origin 
--Afternote:two ways how to abriviate the airoport (full name, short) example: Copenhagen/CPH

SELECT TOP(10) Origin, COUNT(*) AS Count
FROM [RynairReviews].[dbo].[ryanair_reviews]
GROUP BY Origin
ORDER BY COUNT(*) DESC

--TOP 10 Popular destinations
--Afternote:Same count of missing data as previous. Should it be excluded?

SELECT TOP(10) Destination, COUNT(*) AS Count
FROM [RynairReviews].[dbo].[ryanair_reviews]
GROUP BY Destination
ORDER BY COUNT(*) DESC

--Counting how many reviews are not verified+no origin+no destination+no date
--Recomendation to delete

SELECT 
    SUM(
        CASE 
            WHEN Trip_verified IS NULL 
			AND Origin IS NULL 
			AND Destination IS NULL 
			AND Date_Flown IS NULL THEN 1
            ELSE 0
        END
    ) AS Foulty_reviews
FROM 
    [RynairReviews].[dbo].[ryanair_reviews];


	DELETE FROM [RynairReviews].[dbo].[ryanair_reviews]
WHERE 
    Trip_verified IS NULL AND 
    Origin IS NULL AND 
    Destination IS NULL AND 
   Date_Flown IS NULL;

   --Aircrafts reviewd
   --Afternote: Many values missing, no united way of writing the names(Boeing 737-800,Boeing 737 800,B737-800,737 800,Boeing 737/800)

   SELECT Aircraft,COUNT(*) AS Count
   FROM [RynairReviews].[dbo].[ryanair_reviews]
   GROUP BY Aircraft
   ORDER BY COUNT(*) DESC

   ---------------------------Rating-----------------------------------

   --Rating trend over time  by year

	SELECT 
    YEAR(Date_Published) AS Year,
   ROUND( AVG(Overall_Rating),2) AS Avg_Overall_Rating
FROM 
    [RynairReviews].[dbo].[ryanair_reviews]
GROUP BY 
    YEAR(Date_Published)
ORDER BY 
    YEAR(Date_Published);
  
   --Rating and passanger country

   SELECT Passenger_Country,COUNT(*) AS Review_count,
   ROUND(AVG(Overall_Rating),2) AS Avg_rating
   FROM [RynairReviews].[dbo].[ryanair_reviews]
   GROUP BY Passenger_Country
   ORDER BY COUNT(*) DESC

   --Rating and origin

   SELECT Origin,COUNT(*) AS Review_count,
   ROUND(AVG(Overall_Rating),2) AS Avg_rating
   FROM [RynairReviews].[dbo].[ryanair_reviews]
   GROUP BY Origin
   ORDER BY COUNT(*) DESC

   --Rating and destination

   SELECT Destination,COUNT(*) AS Review_count,
   ROUND(AVG(Overall_Rating),2) AS Avg_rating
   FROM [RynairReviews].[dbo].[ryanair_reviews]
   GROUP BY Destination
   ORDER BY COUNT(*) DESC

   --Rating and origin + destination 
   
   SELECT Origin,Destination,COUNT(*) AS Review_count,
   ROUND(AVG(Overall_Rating),2) AS Avg_rating
   FROM [RynairReviews].[dbo].[ryanair_reviews]
	GROUP BY Origin, Destination
   ORDER BY COUNT(*) DESC

   --Seat type and ovearall rating

   SELECT Seat_Type,ROUND(AVG(Overall_Rating),2) AS Avg_rating
   FROM [RynairReviews].[dbo].[ryanair_reviews]
   GROUP BY Seat_Type
   ORDER BY AVG(Overall_Rating)
  
  --Type of Traveller and overall rating

  SELECT Type_of_Traveller,ROUND(AVG(Overall_Rating),2) AS Avg_rating
   FROM [RynairReviews].[dbo].[ryanair_reviews]
   GROUP BY Type_of_Traveller
   ORDER BY AVG(Overall_Rating)

  
  --Seat Type ratings

 SELECT Seat_Type,ROUND(AVG(Seat_Comfort),2) AS Seat_Comfort,
 ROUND(AVG(Cabin_staff_service),2) AS Staff_service, 
 ROUND(AVG(Food_beverages),2) AS Food_beverages,
 ROUND(AVG(Ground_Service),2) AS Ground_Service,
 ROUND(AVG(Value_for_money),2) AS Value_for_money
 FROM [RynairReviews].[dbo].[ryanair_reviews]
 GROUP BY Seat_Type

 --Aircraft ratings

  SELECT Aircraft,COUNT(*) AS Review_count,ROUND(AVG(Seat_Comfort),2) AS Seat_Comfort,
 ROUND(AVG(Cabin_staff_service),2) AS Staff_service, 
 ROUND(AVG(Food_beverages),2) AS Food_beverages,
 ROUND(AVG(Ground_Service),2) AS Ground_Service,
 ROUND(AVG(Value_for_money),2) AS Value_for_money,
 ROUND(AVG(Overall_Rating),2) AS Overall_Rating
 FROM [RynairReviews].[dbo].[ryanair_reviews]
 GROUP BY Aircraft
 ORDER BY COUNT(*) DESC

 --Averages of differen aspects to see where could be done improvements
 --Afternote:Non of the aspects score very high, most improvement needed food and beverages

 SELECT 
    ROUND(AVG(Seat_Comfort),2) AS Avg_Seat_Comfort,
    ROUND(AVG(Cabin_staff_service),2) AS Avg_Cabin_Staff_Service,
    ROUND(AVG(Food_beverages),2) AS Avg_Food_Beverages,
	ROUND(AVG(Ground_Service),2) AS Avg_Ground_Service,
	ROUND(AVG(Value_for_money),2) AS Avg_Value_for_money
FROM 
    [RynairReviews].[dbo].[ryanair_reviews]


	 

	

