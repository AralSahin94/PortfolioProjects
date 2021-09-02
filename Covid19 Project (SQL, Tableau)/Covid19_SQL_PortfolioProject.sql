-- Link to the dataset: https://ourworldindata.org/covid-deaths

-- covid_death and covid_vac tables are both created from the main dataset. covid_death table includes case, infection and death related columns while covid_vac includes vaccinations.
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

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_death
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT continent, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..covid_death
WHERE continent IS NOT NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY TotalDeathCount DESC

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_death
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_death
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
