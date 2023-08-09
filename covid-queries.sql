SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- Select data we are going to be using
SELECT location,population, date, total_cases, new_cases, total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying in country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS numeric) / total_cases) * 100 AS deathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
Order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT location, date, total_cases, population, (CAST(total_cases AS numeric) / population) * 100 AS covidPercentage
FROM CovidDeaths
WHERE location like '%states'
Order by 1, 2


-- Find countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HightestInfectionCount, MAX((CAST(total_cases AS numeric) / population))*100 AS infectedPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infectedPercentage desc

-- Showing Countries with Highest Death Count per location
SELECT location, MAX(total_deaths) as totalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  location
ORDER BY totalDeathCount desc;


-- Showing continents with highest death count per population
SELECT continent, MAX(total_deaths) as totalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount desc;


-- GLOBAL NUMBERS
SELECT  
	SUM(cast(new_cases as float)) as total_new_cases, 
	SUM(cast(new_deaths as float))  as total_new_deaths,
	(SUM(cast(new_deaths as float)) / SUM(cast(new_cases as float)) * 100) as deathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases != 0
ORDER BY 1, 2



-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(SELECT 
	dea.continent, 
	dea.location,
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
	--(rollingPeopleVaccinated/population)*100	
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rollingPeopleVaccinated / population)*100
FROM PopvsVac;

-- Creating view to store data for visualization 
Create View PercentPopulationVaccinated AS
-- Looking at Total Population vs Vaccinations
SELECT 
	dea.continent, 
	dea.location,
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT * FROM PercentPopulationVaccinated