Select *
From [Portfolio Project 1]..CovidDeaths
Where continent is not NULL
Order by 3,4

--Select *
--From [Portfolio Project 1]..CovidVaccinations
--Order by 3,4

--Select data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project 1]..CovidDeaths
Where continent is not NULL
Order by 1,2

--Compare Total Cases vs total deaths
--U.S. percentage of deaths if virus is contracted
 
Select Location, date, total_cases, total_deaths,
(Convert(float,total_deaths)/Nullif(Convert(float,total_cases),0))*100 as DeathPercentage
From [Portfolio Project 1]..CovidDeaths
Where Location like '%states%'
Order by 1,2

--U.S. Total Cases vs Population
--Population of U.S. that has contracted virus

Select Location, date, population, total_cases,
(Convert(float,total_cases)/Nullif(Convert(float,population),0))*100 as PerPopulationInfected
From [Portfolio Project 1]..CovidDeaths
Where Location like '%states%'
Order by 1,2

--Countries with high infection rates compared to their population
--Not date specific, overall

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(Convert(float,total_cases)/Nullif(Convert(float,population),0))*100 as PerPopulationInfected
From [Portfolio Project 1]..CovidDeaths
--Where Location like '%states%'
Where continent is not NULL
Group by Location, population
Order by PerPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(Convert(float,total_cases)/Nullif(Convert(float,population),0))*100 as PerPopulationInfected
From [Portfolio Project 1]..CovidDeaths
--Where Location like '%states%'
Where continent is not NULL
Group by Location, population
Order by PerPopulationInfected desc

-- Brokendown by Continent

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project 1]..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project 1]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
--Rolling count, bigint to account for current(2024) numbers

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project 1]..CovidDeaths dea
Join [Portfolio Project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project 1]..CovidDeaths dea
Join [Portfolio Project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
  

-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project 1]..CovidDeaths dea
Join [Portfolio Project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project 1]..CovidDeaths dea
Join [Portfolio Project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

