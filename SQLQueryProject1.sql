SELECT *
FROM covid_portfolio..covid_deaths
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM covid_portfolio..covid_deaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying of covid per country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_portfolio..covid_deaths
WHERE location LIKE '%states%'
AND continent is not null
order by 1,2


-- Looking at Total Cases vs Population
Select location, date, population,total_cases, (total_cases/population)*100 AS PercentagePopulationCovid
FROM covid_portfolio..covid_deaths
WHERE location LIKE '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercentagePopulationInfected
FROM covid_portfolio..covid_deaths
--WHERE location LIKE '%states%'
GROUP by location, population
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
FROM covid_portfolio..covid_deaths
WHERE continent is not null
GROUP by location
Order by TotalDeathCount desc

--Breaking it down by continent


--Showing continents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
FROM covid_portfolio..covid_deaths
WHERE continent is not null
GROUP by continent
Order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covid_portfolio..covid_deaths
--WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM covid_portfolio..covid_deaths dea
JOIN covid_portfolio..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
Order By 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order BY dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVAccinated/population)*100
FROM covid_portfolio..covid_deaths dea
JOIN covid_portfolio..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order BY dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVAccinated/population)*100
FROM covid_portfolio..covid_deaths dea
JOIN covid_portfolio..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order BY dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVAccinated/population)*100
FROM covid_portfolio..covid_deaths dea
JOIN covid_portfolio..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order By 2,3

SELECT *
FROM PercentPopulationVaccinated
ORDER BY location

--1.

Select SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covid_portfolio..covid_deaths
--WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2

--2. We take these out as they are not included in the above queriers and want to stay consistent.

SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM covid_portfolio..covid_deaths
WHERE continent is null
	AND location not in ('World', 'European Union','International')
GROUP By location
Order By TotalDeathCount desc

--3.

Select location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercentagePopulationInfected
FROM covid_portfolio..covid_deaths
--WHERE location LIKE '%states%'
GROUP by location, population
order by PercentagePopulationInfected desc

--4.

Select location, population,date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercentagePopulationInfected
FROM covid_portfolio..covid_deaths
--WHERE location LIKE '%states%'
GROUP by location, population, date
order by PercentagePopulationInfected desc
