/*
Covid 19 Data Exploration

Date used from ourworldindata.org/covid-deaths ranging from Jan 2020 - Apr 2021

Examples of Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types, Creating Views

*/


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4



 -- Select data we will be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2



-- Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country with added death_percent column

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percent
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
order by 1,2



-- Total cases vs Population
-- Shows what percent of population infected with Covid with added PercentPopulationInfected column

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
order by 1,2



-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by location, population
order by PercentPopulationInfected DESC



-- Countries with Highest Death Count

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by location
order by TotalDeathCount desc



-- Countres with Highest Death Count per population

SELECT Location, population, MAX(CAST(total_deaths as int)) AS TotalDeathCount, MAX(CAST(total_deaths as int)/population)*100 AS PercentPopulationDead
FROM PortfolioProject..CovidDeaths
Group by Location,population
order by PercentPopulationDead DESC



---- BREAKING DATA DOWN BY CONTINENT



-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by continent
order by TotalDeathCount desc



----GLOBAL NUMBERS
-- Shows ratio of deaths per new case each day

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by date
order by 1,2



-- Total Population vs Vaccinations
-- Highlights a Rolling count of people vaccinated per country as time progresses

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
  dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query
-- With the CTE, added PercentPopulationVaccinated column

WITH PopvsVac (Continent, location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
  dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac
order by 2,3



-- Alternatively, also used temp Table to perform the same calculation

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
  dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaxed
FROM #PercentPopulationVaccinated
order by 2,3



---- Creating Views to store data for later visualizations

-- View for Rolling Count of Population Vaccinated by Country

Create View RollingCountPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
  dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM RollingCountPopulationVaccinated
order by 2,3



-- View for Highest Percent Infection rate per country

Create View HighestPercentInfectionRate AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by location, population


SELECT *
FROM HighestPercentInfectionRate
Order By PercentPopulationInfected DESC



-- View for Highest Percent Death rate per country

Create View HighestPercentDeathRate AS
SELECT Location, population, MAX(CAST(total_deaths as int)) AS TotalDeathCount, MAX(CAST(total_deaths as int)/population)*100 AS PercentPopulationDead
FROM PortfolioProject..CovidDeaths
Group by Location,population

SELECT *
FROM HighestPercentDeathRate
Order By PercentPopulationDead DESC








