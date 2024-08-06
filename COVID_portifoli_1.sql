SELECT*
FROM Portfolio.dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 3,4

--SELECT*
--FROM Portfolio.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Portfolio.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Case vs Total Deaths 
/*
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)
FROM Portfolio.dbo.CovidDeaths
ORDER BY 1,2

UPDATE Portfolio.dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = 0;

UPDATE Portfolio.dbo.CovidDeaths
SET total_deaths = NULL
WHERE total_deaths = 0;
*/


-- Shows likelihood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM Portfolio.dbo.CovidDeaths
WHERE continent is not null
AND LOCATION like '%states%'
ORDER BY 1,2

-- looking at total case vc population 
-- shows what percentage of population got Covid 
SELECT location, date, total_cases, Population, (total_cases/Population) * 100 AS PercentagePopulationInfection
FROM Portfolio.dbo.CovidDeaths
WHERE continent is not null
AND LOCATION like '%states%'
ORDER BY 1,2

-- Looking ar Countries with Highest Infaction Rate Compered to Population 

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population)) * 100 AS PercentagePopulationInfection
FROM Portfolio.dbo.CovidDeaths
--WHERE LOCATION like '%states%'
WHERE continent is not null
GROUP BY location, Population
ORDER BY PercentagePopulationInfection DESC

-- Showing Countries with Highest Death Count per Population 
SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM Portfolio.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount DESC

-- let's break things down by continent 
SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM Portfolio.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing de continents with the highest count per population 

SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM Portfolio.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers by date
SELECT date,
    SUM(new_cases) AS TotalNewCases, 
    SUM(new_deaths) AS TotalNewDeaths,
    (SUM(new_deaths) / NULLIF(CAST(SUM(new_cases) AS FLOAT), 0)) * 100 AS DeathPercentage
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Global Numbers (total )

SELECT
    SUM(new_cases) AS TotalNewCases, 
    SUM(new_deaths) AS TotalNewDeaths,
    (SUM(new_deaths) / NULLIF(CAST(SUM(new_cases) AS FLOAT), 0)) * 100 AS DeathPercentage
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2 


SELECT * 
FROM Portfolio.dbo.CovidDeaths dea 
JOIN Portfolio.dbo.CovidVaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date 

-- Looking at Total Population vc Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM Portfolio.dbo.CovidDeaths as dea 
JOIN Portfolio.dbo.CovidVaccinations as vac 
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE dea.continent is not null 
ORDER by 2,3 

-- 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio.dbo.CovidDeaths as dea 
JOIN Portfolio.dbo.CovidVaccinations as vac 
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE dea.continent is not null 
ORDER by 2,3 

--CTE
WITH PopvsVac as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.CovidDeaths as dea 
JOIN Portfolio.dbo.CovidVaccinations as vac 
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE dea.continent is not null 
)
SELECT*, (CAST(RollingPeopleVaccinated AS FLOAT)/population)*100
FROM PopvsVac
ORDER BY location, date;

--temp table 
DROP TABLE if EXISTS #PercentagePopulationVaccinated 
CREATE TABLE #PercentagePopulationVaccinated 
(
Continent NVARCHAR(255),
Location NVARCHAR (255),
Date datetime, 
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC, 
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.CovidDeaths as dea 
JOIN Portfolio.dbo.CovidVaccinations as vac 
    ON dea.location = vac.location
    AND dea.date = vac.date 
--WHERE dea.continent is not null 

SELECT*, (CAST(RollingPeopleVaccinated AS FLOAT)/population)*100
FROM #PercentagePopulationVaccinated

--creating view to store data for later vizualizations 

-- Criação da view
DROP VIEW PercentPopulationVaccinated;
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    -- Cálculo da soma acumulada de vacinas
    SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location 
              ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.CovidDeaths AS dea 
JOIN Portfolio.dbo.CovidVaccinations AS vac 
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL;


SELECT * 
FROM sys.views 
WHERE name = 'PercentPopulationVaccinated';
-- Mudar para o banco de dados Portfolio
USE Portfolio;
GO

-- Primeiro, exclua a view existente se ela já estiver lá (se aplicável)
IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated;
GO

-- Criação da view
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    -- Cálculo da soma acumulada de vacinas
    SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location 
              ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.CovidDeaths AS dea 
JOIN Portfolio.dbo.CovidVaccinations AS vac 
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL;

-- Mudar para o banco de dados Portfolio
USE Portfolio;
GO

-- Primeiro, exclua a view existente se ela já estiver lá (se aplicável)
IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated;
GO

-- Criação da view
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    -- Cálculo da soma acumulada de vacinas
    SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location 
              ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.CovidDeaths AS dea 
JOIN Portfolio.dbo.CovidVaccinations AS vac 
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL;
GO


SELECT*
FROM PercentPopulationVaccinated
