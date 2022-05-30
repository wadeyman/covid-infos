select * 
from [Covid Deaths].dbo.['covid deaths$']
where continent is not null
order by 3,4

--select *
--from [Covid Deaths]..['covid vaccinations$']
--order by 3,4

-- Select data that we will use
Select Location, date, total_cases, new_cases, total_deaths, population
from dbo.['covid deaths$'] 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- eg %states anything with states at the back, string not cap sensi
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.['covid deaths$'] 
where location like '%States%' -- %sign used for estimating the string we finding
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.['covid deaths$'] 
where location like 'Singapore'
order by 1,2

-- Look at Total cases vs Population 
-- shows what percent of popln got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as poplnpercent
from dbo.['covid deaths$']
-- where Location in ('Singapore', 'United states')
order by Location, date	

-- Look for country with highest infection rate compared to popln
select location,population, max(total_cases) as maxinfectcount, max((total_cases/population))*100 as maxinfectpoplnrate
from dbo.['covid deaths$']
group by location, population
order by maxinfectpoplnrate desc

select location,population, max(total_cases) as maxinfectcount, max((total_cases/population))*100 as maxinfectpoplnrate
from dbo.['covid deaths$']
where location = 'United States'
group by location, population

-- Breaking things down by continent
select continent, max(cast(total_deaths as int)) as mostdeathcount
from dbo.['covid deaths$']
where continent is not null
group by continent
order by mostdeathcount desc

-- show countries  with highest Death Count per population
-- cast to convert values in colummn  to data type
select location, max(cast(total_deaths as int)) as mostdeathcount
from dbo.['covid deaths$']
group by location
order by mostdeathcount desc

-- only Americas
select location, max(cast(total_deaths as int)) as mostdeathcount, continent
from dbo.['covid deaths$']
where continent like '%America'
group by location, continent
order by mostdeathcount desc

-- global numbers, daily
select date, sum(new_cases) as newcases,sum(cast(new_deaths as int)) as deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercent
from dbo.['covid deaths$']
where continent is not null
group by date
order by date

-- use CTE, need to ensure the created table has correct cols
with PopVsVac (continent, location, date, population, New_Vaccinations, RollingPplVaccinated)
as 
(
-- look at total population vs vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over 
(partition by dea.location order by dea.location,dea.date) as RollingPplVaccinated
from dbo.['covid deaths$'] dea
join dbo.['covid vaccinations$'] vac 
on dea.location = vac.location and 
dea.date = vac.date
where dea.continent is not null
--order by location, date
)
Select *, (RollingPplVaccinated/Population)*100 as RollingVaccPerc 
from PopVsVac
where location = 'Albania'