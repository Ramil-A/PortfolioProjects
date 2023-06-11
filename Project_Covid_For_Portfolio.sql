-- Select data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Total cases vs Total Deaths, Percentage of Death in Poland

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Poland'
Order by 1,2

-- Total cases vs Population, Percentage of population infected

Select location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
From PortfolioProject..CovidDeaths
Where location = 'Poland'
Order by 1,2

-- Countries with highest infection rate comparing to population

Select location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'Poland'
Group by location, population
Order by PercentPopulationInfected desc


-- Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Poland'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Poland'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death, SUM(CAST(total_deaths AS decimal(12,2))) / SUM(CAST(total_cases AS decimal(12,2)))*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--Total Population vs Vaccination

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Cast(v.new_vaccinations as float)) OVER (Partition by d.location Order by d.location
, d.date) As Rolling_People_Vaccinated, Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	And d.date = v.date
Where d.continent is not null
Order by 2,3


-- Using CTE

With PopulationVSVaccination (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
As
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Cast(v.new_vaccinations as float)) OVER (Partition by d.location Order by d.location
, d.date) As Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	And d.date = v.date
Where d.continent is not null
--Order by 2,3
)

Select *, (Rolling_People_Vaccinated/Population)*100
From PopulationVSVaccination


-- Temp Table

Drop Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float,
Rolling_People_Vaccinated float
)

Insert into #Percent_Population_Vaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Cast(v.new_vaccinations as float)) OVER (Partition by d.location Order by d.location
, d.date) As Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	And d.date = v.date
Where d.continent is not null
--Order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
From #Percent_Population_Vaccinated


-- Creating View to store data for later BI

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Cast(v.new_vaccinations as float)) OVER (Partition by d.location Order by d.location
, d.date) As Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	And d.date = v.date
Where d.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated