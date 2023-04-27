Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
-- From PortfolioProject..CovidVaccinations
-- order by 3,4

-- Select data that we are going to be using.

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases * 100) as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/Population * 100) as PecentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population * 100)) as PecentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Group By Location, Population
order by PecentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location, Population
order by TotalDeathCount desc


-- Breaking down by Continent
-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
order by TotalDeathCount desc

-- These numbers look okay, but appear to be missing some data. Let's see if we can fix this.

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group By Location, Population
order by TotalDeathCount desc

-- Now, the data more accurately represents what we are looking for.


-- GLOBAL NUMBERS

-- Grouped by Date

Select date , SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPecentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
order by 1,2

-- Total

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPecentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

USE PortfolioProject
GO
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated

