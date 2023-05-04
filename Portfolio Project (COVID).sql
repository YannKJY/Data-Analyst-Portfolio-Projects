
-- Check Imported Data
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- Select Relevant Columns I am going to use
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in Singapore
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Singapore%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where location like '%Singapore%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to respective Population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as HighestCovidPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by 4 DESC


-- Showing Countries with the Highest Death Count
select location,  Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount DESC


-- Showing Continents with the Highest Death Count
select continent,  Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount DESC


-- Global Numbers
select SUM(new_cases) as Sum_of_new_cases, SUM(cast(new_deaths as int)) as Sum_of_new_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentageWorld
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
--order by date

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingsum_total_vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as total_vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Total_Vaccination/Population)*100 as TotalPercentageVaccinated
from PopvsVac


-- Create View for data visualisation
create view Rollingsum_total_vaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingsum_total_vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from Rollingsum_total_vaccination