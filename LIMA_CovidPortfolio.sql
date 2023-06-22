SELECT * 
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4 

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
order by 1,2

-- Looking at total cases vs population
SELECT Location, date, total_cases, Population, (total_cases/population) * 100 as PercentagePopInfected
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
order by 1,2

-- Looking at countries with the highest infection rates compared to their populations
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentagePopInfected
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
GROUP BY Location, Population
order by PercentagePopInfected desc

-- Showing countries with the highest death count per population 
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY Location
order by TotalDeathCount desc

--Correct version 
--SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--Where continent is null
--GROUP BY location
--order by TotalDeathCount desc

--Tableau friendly
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
--Group by date
order by 1,2

--SELECT * 
--FROM PortfolioProject..CovidDeaths dea
--JOIN PortfolioProject..CovidVaccinations vac
--ON dea.location = vac.location
--AND dea.date = vac.date

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
, 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

-- TEMP TABLE 
-- ADD drop table for ease
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3