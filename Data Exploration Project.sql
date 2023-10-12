--Select *
--From PortfolioProject..CovidDeaths$
--order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is NOT NULL
order by 1,2





-- Total cases Vs Total Deaths 

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
order by 1,2




-- Looking at the total cases vs Population

select location, date, population, total_cases,(total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths$
order by 1,2




--Looking at Countries with highest infection rate compared to Population 

select location, population, Max(total_cases) as HighestInfection,Max((total_cases/population))*100 as CovidPercentage
from PortfolioProject..CovidDeaths$
Group by location, population
order by CovidPercentage desc





-- Showing countries with Highest Death Count per Population

select location, Max(Cast(total_deaths as int )) as TotalDeaths
from PortfolioProject..CovidDeaths$
where continent is NOT NULL
Group by location
order by TotalDeaths desc





-- LETs break things down by Continent

-- Showing the continents with highest death counts

Select continent, Max(Cast(total_deaths as int )) as TotalDeaths
From PortfolioProject..CovidDeaths$
where continent is NOT NULL
Group by continent
order by TotalDeaths desc






-- GLOBAL NUMBERS

select  date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100    --total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2






-- Working on Covid vaccination

-- Looking at Total Populations vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.Location, dea.date) as RPC
--, 
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3





-- USE CTE

with PopvsVac (Continent, Location, date, population, New_vaccinations, RPV)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.Location, dea.date) as RPC
--, 
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RPV/population)*100
From PopvsVac





--TEMP Table

Drop Table if exists #PercentageVaccinated
Create table #PercentageVaccinated
(
Continent nvarchar (255), 
Location nvarchar(255), 
date datetime, 
population numeric, 
New_vaccinations numeric, 
RPV numeric
)

Insert Into #PercentageVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.Location, dea.date) as RPC
--, 
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RPV/population)*100
From #PercentageVaccinated





-- Creating View to store data for later Visualization
Create View PercentageVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.Location, dea.date) as RPC
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
from PercentageVaccinated