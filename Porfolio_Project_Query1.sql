SELECT * 
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM Portfolio_Project..CovidVaccinations
--ORDER BY 3,4

--Select Data we're using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases v Total Deaths

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE LOCATION LIKE '%states%'
ORDER BY 1,2

--Looking at Total Cases v Population
--Shows percentage that has gotten COVID
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentofPopulationInfected
FROM Portfolio_Project..CovidDeaths
WHERE LOCATION LIKE '%states%'
ORDER BY 1,2


--Highest Infection Rate v Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentofPopulationInfected
FROM Portfolio_Project..CovidDeaths
--WHERE LOCATION LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected DESC

--Countries with Highest Death Count Per Population
SELECT Location, MAX(cast(Total_deaths as bigint)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Breakdown by Continent
SELECT continent, MAX(cast(Total_deaths as bigint)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count Per Population
SELECT continent, MAX(cast(Total_deaths as bigint)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as bigint)) AS Total_Deaths, SUM(cast(new_deaths as bigint))/SUM(cast(new_cases as bigint))*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- USE CTE
WITH PopvsVac ( continent,location,date,population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table
DROP TABLE IF EXISTS #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
New_Vaccincations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #percentPopulationVaccinated

-- Creating View to Store Data for Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3
