
Select * from PortfolioProject..covidDeaths
where continent is not null
order by 3,4

Select * from PortfolioProject..CovidVaccinations
order by 3,4

-- Converting the blank spaces to null
SELECT 
    NULLIF(TRIM(continent), '') AS continent
FROM PortfolioProject..covidDeaths

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeaths
order by 1

-- Looking at total cases vs total deaths
-- Likelihood of death in your country

Select location, date, total_cases, total_deaths, (convert(float,total_deaths)/nullif(convert(float,total_cases),0))*100 as DeathPercentage
from PortfolioProject..covidDeaths
where location like '%india%'
order by 1

-- Looking at Total Cases Vs Population
-- It shows what percentage of people got covid cases
Select location, date, total_cases, population, (convert(float,total_cases)/nullif(convert(float,population),0))*100 as CovidInfectedPercentage
from PortfolioProject..covidDeaths
where location like '%india%'
order by 1

--Q1. Looking at Countries with Highest Infection Rate compared to Population
-- replace with MAX function the above query instead 
Select location, population,
MAX(convert(float,total_cases)) as Maximum_totalcases,
MAX(convert(float,total_cases)/nullif(convert(float,population),0))*100 as InfectedRatePercentage
from PortfolioProject..covidDeaths
where continent is not null
group by location,population
order by InfectedRatePercentage desc

-- Q2. Showing Countries/Continent with highest death count per population 
-- here we will use max for total deaths and use groupby 
-- TO remove continents list from "location" column 

Select location,NULLIF(TRIM(continent), '') AS continent,max(cast(total_deaths as int)) as Max_totaldeaths
from PortfolioProject..covidDeaths
where continent is not null -- after writing not null it is still showing the continent this means that all the blank spaces are not null
group by location,continent
order by Max_totaldeaths desc

-- Showing Continents with the highest death count per population
Select continent,max(cast(total_deaths as int)) as Max_totaldeaths
from PortfolioProject..covidDeaths
where continent is null -- this query shows there are no null values in location
group by continent
order by Max_totaldeaths desc  

update PortfolioProject..covidDeaths
set continent = 'World' where total_deaths = 7053524

-- GLOBAL NUMBERS
-- Looking for new cases and new deaths numbers daily
Select convert(date,date)as date, sum(cast(new_cases as int)) as daily_cases, sum(cast(new_deaths as int)) as daily_deaths,
--convert(date,date)as date (it will be used in select statements if required for deaths number date wise)
COALESCE(SUM(CAST(new_deaths AS bigint)) / NULLIF(SUM(CAST(new_cases AS int)), 0) * 100, 0) AS total_death_percentage 
from PortfolioProject..covidDeaths
where continent is not null
group by convert(date,date)
order by 1,2

-- Using covid vaccines table and covid deaths table for analysis
-- Total Population Vs Vaccines
Select dea.continent, dea.location, convert(date,dea.date) as date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- BY Using CTE to calculate percentage of people vaccineted with respect to population  
WITH PopvsVac(Continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, convert(date,dea.date) as date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
 -- order by 2,3

)

Select *, (convert(bigint,RollingPeopleVaccinated)/population)* 100 as VaccinatedPercentage
from PopvsVac

CREATE VIEW PopulationVaccinated as 

Select dea.continent, dea.location, convert(date,dea.date) as date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
 -- order by 2,3

 Select * from PopulationVaccinated
