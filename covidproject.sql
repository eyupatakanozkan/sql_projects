SELECT *
FROM  CovidProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM  CovidProject..CovidVaccinations
--ORDER BY 3,4


SELECT 
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population 
FROM 
  CovidProject..CovidDeaths 
ORDER BY 
  1, 
  2

-- looking total cases vs total deaths
SELECT 
  location, 
  date, 
  total_cases, 
  total_deaths,
  (total_deaths/total_cases*100) as DeathPercentage
FROM 
  CovidProject..CovidDeaths 
WHERE location LIKE '%turkey%'
ORDER BY 
  1, 2

--looking at total cases vs population
--shows what percentage of population got covid

SELECT 
  location, 
  date,
  population,
  total_cases, 
  format((total_cases/population*100 ),'N2') as InfectionRate
FROM 
  CovidProject..CovidDeaths 
--WHERE location LIKE '%turkey%'
ORDER BY 
  1, 2

--looking at countries with highest infection rate compared to population

SELECT 
  location, 
  population,
  max(total_cases), 
  max(total_cases/population*100 ) as InfectionRate
FROM 
  CovidProject..CovidDeaths 
--WHERE location LIKE '%turkey%'
Group By location,population
ORDER BY InfectionRate desc

--showing countries with highest death count

SELECT 
  location, 
  max(cast(total_deaths as int)) DeathCount
FROM 
  CovidProject..CovidDeaths 
Where continent is  Null
--WHERE location LIKE '%turkey%'
Group By location
ORDER BY 2 desc

--showing continents with the highest death count per population

SELECT 
  location, 
  max(cast(total_deaths as int)) DeathCount
FROM 
  CovidProject..CovidDeaths 
Where continent is  Null
--WHERE location LIKE '%turkey%'
Group By location
ORDER BY 2 desc

-- global numbers

SELECT  
SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM 
  CovidProject..CovidDeaths 
WHERE continent is not NULL
--GROUP BY date
ORDER BY 
  1,2

-- looking at total population vs vaccinations.

Select dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From CovidProject..CovidDeaths  dea
Join CovidProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  --and dea.location like  'alb%'
order by 1,2,3

-- use cte
With PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as (
Select dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From CovidProject..CovidDeaths  dea
Join CovidProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  --and dea.location like  'alb%'
--order by 1,2,3
)

Select location,date, rollingpeoplevaccinated/population*100 from PopvsVac 
order by 1


-- use temp table 
Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated 
Select dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From CovidProject..CovidDeaths  dea
Join CovidProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  --and dea.location like  'alb%'
--order by 1,2,3

Select * , rollingpeoplevaccinated/population*100 from #PercentPopulationVaccinated 
order by location,date

-- creating view to store data for visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From CovidProject..CovidDeaths  dea
Join CovidProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  --and dea.location like  'alb%'
--order by 1,2,3
Select * from PercentPopulationVaccinated