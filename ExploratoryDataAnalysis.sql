Select *
From SQL_Data_Exploration..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From SQL_Data_Exploration..CovidVaccinations
--order by 3,4

-- Select Data
Select Location, date, total_cases, new_cases, total_deaths, population
From SQL_Data_Exploration..CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Calculate Deathrates
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From SQL_Data_Exploration..CovidDeaths
Where location like '%New Zealand%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
Select Location, date, total_cases, Population, (total_cases/population)*100 as PopulationInfected
From SQL_Data_Exploration..CovidDeaths
Where location like '%New Zealand%' and continent is not null
order by 1,2

-- Countries with highest infection rate compared to population
Select Location, Population, MAX(cast(total_cases as int)) as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopulationInfected
From SQL_Data_Exploration..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with highest deathrate
Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population)*100) as PercentPopulationDeaths
From SQL_Data_Exploration..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentPopulationDeaths desc

-- Deaths per continent
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From SQL_Data_Exploration..CovidDeaths
Where continent is null
Group by Location
order by TotalDeathCount desc

-- Population Deathrate per continent
Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population)*100) as PercentPopulationDeaths
From SQL_Data_Exploration..CovidDeaths
Where continent is null
Group by Location
order by PercentPopulationDeaths desc

-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From SQL_Data_Exploration..CovidDeaths
where continent is not null
order by 1, 2

-- Total Population vs Vaccinations using CTE
With PopVsVac (Continent, Location, Data, Population, New_Vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccinations/population)*100 as PopulationPercentageVaccinated
From SQL_Data_Exploration..CovidDeaths dea
Join SQL_Data_Exploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaccinations/Population)*100 as PecentagePopulationVaccinated
From PopVsVac
order by 2, 3

-- Creating View to store data for visualizations
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccinations/population)*100 as PopulationPercentageVaccinated
From SQL_Data_Exploration..CovidDeaths dea
Join SQL_Data_Exploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated