-- Link to the dataset: https://ourworldindata.org/covid-deaths

SELECT *
FROM PortfolioProject..covid_death
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..covid_vac
ORDER BY 3,4

-- looking at total cases vs total deaths
-- death probability if you live at Turkey (my country)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..covid_death
WHERE location = 'Turkey'
ORDER BY 1,2

-- looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS case_percentage
FROM PortfolioProject..covid_death
WHERE location = 'Turkey'
ORDER BY 1,2

-- Infection rate vs population in whole world

SELECT location, population, MAX(total_cases) AS highest_infection, MAX((total_cases/population))*100 AS inf_perc
FROM PortfolioProject..covid_death
GROUP BY location, population
ORDER BY inf_perc DESC

-- Total Deaths by the Continents

SELECT continent, MAX(cast(Total_deaths as int)) as totaldeath
FROM PortfolioProject..covid_death
WHERE continent is not NULL
GROUP BY continent
ORDER BY totaldeath DESC

-- USING CTE
WITH POPvsVAC (Continent, location,date, population, new_vaccinations, current_total_vac) AS
(
-- join two table
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,
cd.date) AS current_total_vac
FROM PortfolioProject..covid_death cd
JOIN PortfolioProject..covid_vac cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
--ORDER BY 2,3 
SELECT *, (current_total_vac/population)*100
FROM POPvsVAC

-- USING TEMP TABLE

DROP TABLE IF EXISTS #VaccPercent
CREATE TABLE #VaccPercent
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Current_total_vac numeric,
)

INSERT INTO #VaccPercent
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,
cd.date) AS current_total_vac
FROM PortfolioProject..covid_death cd
JOIN PortfolioProject..covid_vac cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *, (current_total_vac/population)*100
FROM #VaccPercent

-- Create View
USE PortfolioProject;
GO
CREATE VIEW VaccPercent AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,
cd.date) AS current_total_vac
FROM PortfolioProject..covid_death cd
JOIN PortfolioProject..covid_vac cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *
FROM VaccPercent
