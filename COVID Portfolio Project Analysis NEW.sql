SELECT *
FROM dbo.CovidDeaths
WHERE continent is not null
order by 3,4;

--SELECT *
--FROM dbo.CovidVaccinations
--Order By 3,4

-- Select Data that we are going to be using

SELECT  location, date, total_cases, new_cases, total_deaths, population
FROM dbo.coviddeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of Dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS  DeathPercentage
FROM dbo.coviddeaths
WHERE location like '%states%'
AND continent is not null
Order By 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percentofpopulationinfected
FROM dbo.coviddeaths
--WHERE location like '%states%'
Order By 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS  HighestInfectionCount, MAX((total_cases/population))*100 AS percentofpopulationinfected
FROM dbo.coviddeaths
--WHERE location like '%states%'
Group By Location, population
Order By 4 Desc;


--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.coviddeaths
--WHERE location like '%states%'
WHERE continent is not null
Group By Location
Order By TotalDeathCount Desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.coviddeaths
--WHERE location like '%states%'
WHERE continent is not null
Group By continent
Order By TotalDeathCount Desc;



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS  DeathPercentage
FROM dbo.coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY Date
Order By 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS  DeathPercentage
FROM dbo.coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY Date
Order By 1,2;

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not Null
Order By 2,3

-- Adding a running count using Windows Function (Partition BY)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS rollingpeoplevaccinated
FROM dbo.CovidDeaths dea 
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not Null
Order By 2,3


-- Adding a running count using Windows Function (Partition BY) And using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS rollingpeoplevaccinated
FROM dbo.CovidDeaths dea 
--, (RollingPeopleVaccinated/population)*100
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not Null
--Order By 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Adding a running count using Windows Function (Partition BY) And using Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS rollingpeoplevaccinated
FROM dbo.CovidDeaths dea 
--, (RollingPeopleVaccinated/population)*100
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not Null
--Order By 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS rollingpeoplevaccinated
FROM dbo.CovidDeaths dea 
--, (RollingPeopleVaccinated/population)*100
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not Null
--Order By 2,3


SELECt *
FROM PercentPopulationVaccinated
