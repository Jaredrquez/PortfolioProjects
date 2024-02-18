SELECT *
FROM PortfolioProjectFinal.dbo.CovidDeaths

SELECT *
FROM PortfolioProjectFinal..CovidVaccinations

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectFinal..CovidDeaths
ORDER BY 1,2

--Looking at total cases compared to total deaths in the United States

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjectFinal..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at at the total cases compared to the population in the United States

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
FROM PortfolioProjectFinal..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at countries with highest inflection rate compared to population

SELECT Location, max(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS CovidPercentage
FROM PortfolioProjectFinal..CovidDeaths
GROUP BY location, population
ORDER BY CovidPercentage DESC

--Showing countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProjectFinal..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing highest death count for each continent

SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProjectFinal..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS deathpercentage
FROM PortfolioProjectFinal..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjectFinal..CovidDeaths AS dea
JOIN PortfolioProjectFinal..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjectFinal..CovidDeaths AS dea
JOIN PortfolioProjectFinal..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP table
-- If changed is wanted then use DROP TABLE IF EXISTS "table name" at the beginning

--DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjectFinal..CovidDeaths AS dea
JOIN PortfolioProjectFinal..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS	
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjectFinal..CovidDeaths AS dea
JOIN PortfolioProjectFinal..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null