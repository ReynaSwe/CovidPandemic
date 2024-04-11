select * from dbo.CovidVaccinations

select * from dbo.CovidDeaths
where continent is NOT NULL
order by 3,4

--select data that we are going to be using

select 
	location, date, total_cases, new_cases, total_deaths, population 
from
	dbo.CovidDeaths
where
	continent is NOT NULL
order by
	1,2;

--looking at Total Cases Vs Total Deaths
--chance of death during covid
select 
	location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from
	dbo.CovidDeaths
where
	continent is NOT NULL
order by 1,2;

--filter the location

select 
	location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from
	dbo.CovidDeaths
where 
	location LIKE '%states%' AND continent is NOT NULL
order by 1,2;

--looking at Population vs Total Cases
--showing what percentage of population got covids
select 
	location, date, total_cases,  population, (total_cases/population)*100 as InfectedPopulationPecentage
from
	dbo.CovidDeaths
where 
	location LIKE '%Myanmar%' AND continent is NOT NULL
order by 1,2;

--looking for the countries with highest case compared to population

select 
	location, population, MAX(CAST(total_cases as int)) as HighestCase, MAX (total_cases/population)*100 as InfectedPopulationPecentage
from
	dbo.CovidDeaths
where
	continent is not null
Group by
	location, population
--where 
	--location LIKE '%Myanmar%'
order by 4 desc;

--looking for the countries with highest death count per population

select
	location, MAX(CAST(Total_deaths as int)) as DeathCount
FROM
	dbo.CovidDeaths
WHERE
	continent is not null
GROUP BY
	location
Order by
	2 desc;

--Breaking things down by continent

select
	continent , MAX(CAST(Total_deaths as int)) as DeathCount
FROM
	dbo.CovidDeaths
WHERE
	continent is not null
GROUP BY
	continent
Order by
	2 desc;

--Global Cases

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS decimal(10,2))) AS Total_deaths,
	SUM(CAST(new_deaths AS decimal(10,2)))/SUM(new_cases)*100 as DeathPercentage
FROM 
    dbo.CovidDeaths
WHERE
    continent IS NOT NULL
Order by
      1;

-- Total Population Vs Vaccination


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as (
SELECT
    D.continent,
    D.location,
    D.date,
    D.population,
    V.new_vaccinations,
    SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition by D.location ORDER BY  D.date) as RollingPeopleVaccinated --, (total_vaccinations/population)*100
FROM
    dbo.CovidDeaths D
JOIN
    dbo.CovidVaccinations V
ON
    D.location = V.location
    AND D.date = V.date
WHERE
	D.continent IS NOT NULL)

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
FROM PopvsVac

--Temp Table
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
SELECT
    D.continent,
    D.location,
    D.date,
    D.population,
    V.new_vaccinations,
    SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition by D.location ORDER BY  D.date) as RollingPeopleVaccinated --, (total_vaccinations/population)*100
FROM
    dbo.CovidDeaths D
JOIN
    dbo.CovidVaccinations V
ON
    D.location = V.location
    AND D.date = V.date
WHERE
	D.continent IS NOT NULL


SELECT
	*, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
FROM #PercentPopulationVaccinated


--Creating view to store data for visualizations
Create View VaccinatedPopulationPercentage as
SELECT
    D.continent,
    D.location,
    D.date,
    D.population,
    V.new_vaccinations,
    SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition by D.location ORDER BY  D.date) as RollingPeopleVaccinated --, (total_vaccinations/population)*100
FROM
    dbo.CovidDeaths D
JOIN
    dbo.CovidVaccinations V
ON
    D.location = V.location
    AND D.date = V.date
WHERE
	D.continent IS NOT NULL