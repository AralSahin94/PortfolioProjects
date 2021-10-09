-- Small SQL preparation for Power BI data import --

-- Dataset can be found in the project folder --

-- Growing Revenues --

WITH hotels AS (
SELECT * FROM PortfolioProject.dbo.hotel_2018 UNION 
SELECT * FROM PortfolioProject.dbo.hotel_2019 UNION 
SELECT * FROM PortfolioProject.dbo.hotel_2020)

SELECT
arrival_date_year,
hotel,
ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr),2) AS revenue
FROM hotels
GROUP BY arrival_date_year, hotel

-- Join market segment and meal cost data with general table --

WITH hotels AS (
SELECT * FROM PortfolioProject.dbo.hotel_2018 UNION 
SELECT * FROM PortfolioProject.dbo.hotel_2019 UNION 
SELECT * FROM PortfolioProject.dbo.hotel_2020)

SELECT * FROM hotels
LEFT JOIN market_segment
	ON hotels.market_segment = market_segment.market_segment
LEFT JOIN meal_cost
	ON hotels.meal = meal_cost.meal
