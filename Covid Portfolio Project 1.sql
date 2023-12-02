select *
from PortfolioProject..['Covid deaths$']
where continent is not null
order by 3, 4

--select *
--from PortfolioProject.. ['Covid Vaccinations$']
--order by 3, 4

-- Select data that we are using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.. ['Covid deaths$']
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your Country

SELECT Location, date, total_cases, total_deaths,
  (CONVERT(FLOAT, total_deaths) / NULLIF(CONVERT(FLOAT, total_cases), 0)) * 100.0 
  AS DeathPercentage
FROM  PortfolioProject..['Covid deaths$']
WHERE location LIKE '%states%'
ORDER BY 1, 2;



-- Looking at Total Cases vs Population
-- shows what percentage of population get Covid

Select Location, date, total_cases, population, (Convert(float, total_cases) / NULLIF(Convert(float, population), 0)) * 100 
as DeathPercentage
from PortfolioProject.. ['Covid deaths$']
--where location like '%states%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population,
    MAX(total_cases) AS HighestInfectionCount,
    (MAX(total_cases) / Population) * 100 AS PercentPopulationInfected
FROM  PortfolioProject..['Covid deaths$']
-- WHERE Location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;


-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM  PortfolioProject..['Covid deaths$']
-- WHERE Location LIKE '%states%'
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Let's Break things down by Continent

-- Showing Continents by Highest Death Counts per Population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM  PortfolioProject..['Covid deaths$']
-- WHERE Location LIKE '%states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers

-- Looking at Death Percentage per Day
SELECT  date, SUM(new_cases) AS total_cases,
SUM(CAST(new_deaths AS INT)) AS total_deaths,
    CASE
     WHEN SUM(new_cases) <> 0 THEN
  (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
        ELSE
            0  -- or NULL, depending on how you want to handle division by zero
    END AS DeathPercentage
FROM
    PortfolioProject..['Covid deaths$']
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP By  date
ORDER BY  date;

--Overall Death Percentage

SELECT  SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
    CASE
     WHEN SUM(new_cases) <> 0 THEN
  (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
        ELSE
            0  -- or NULL, depending on how you want to handle division by zero
    END AS DeathPercentage
FROM
    PortfolioProject..['Covid deaths$']
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP By  date
ORDER BY 1, 2;

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population,
  vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['Covid deaths$'] dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- USE CTE
With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,
  vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['Covid deaths$'] dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,
  vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['Covid deaths$'] dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population,
  vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['Covid deaths$'] dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;