  SELECT *
  FROM PortfolioProject..CovidVaccination
  Where continent is not null
  ORDER BY 3,4

  SELECT *
  FROM PortfolioProject..CovidDeaths
  ORDER BY 3,4

  --- select data that we are going to be using 

  select Location, date, total_cases, new_cases,total_deaths, population 
  from PortfolioProject..CovidDeaths
  order by 1,2

  -- Looking at total cases vs total deaths
  -- shows the likelyhood of dying if you contract covid in your country

  select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  from PortfolioProject..CovidDeaths
  where location like '%Africa%'
  order by 1,2hs
  order by 1,2

 --Looking at the to the total cases vs population

 select Location, date, total_cases,population, (total_cases/population)*100 as PopulationPercentageInfected
  from PortfolioProject..CovidDeaths
  --where location like '%state%'
  order by 1,2

  -- Looking at country with higehest infection rate compaired to population
  Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationPercentage
  from PortfolioProject..CovidDeaths
  Where continent is not null

  --where location like '%Nigeria%'
  Group by location, Population
  order by PopulationPercentage desc
    
  -- Showing Countries with highest Death count per population
  Select Location, population, MAX(total_deaths) as TotalDeathCount, Max((total_deaths/population))*100 as PopulationPercentage
  from PortfolioProject..CovidDeaths
  Where continent is not null

  --where location like '%Nigeria%'
  Group by location, Population
  --order by TotalDeathCoun desc 

    -- Showing Countries with highest Death count per population
  Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
  from PortfolioProject..CovidDeaths
  Where continent is not null
--where location like '%Nigeria%'
  Group by Location
  Order by TotalDeathCount desc 


  --LET'S BREAK THINGS DOWN BY CONTINENT

  Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
  from PortfolioProject..CovidDeaths
  Where continent is not null
--where location like '%Nigeria%'
  Group by continent
  Order by TotalDeathCount desc 
  

  Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
  from PortfolioProject..CovidDeaths
  Where continent is null
--where location like '%Nigeria%'
  Group by location
  Order by TotalDeathCount desc 


  --Showing the continent with the highest death per population 

   Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
  from PortfolioProject..CovidDeaths
  Where continent is not null
--where location like '%Nigeria%'
  Group by continent
  Order by TotalDeathCount desc


  -- Global Numbers    

  select SUM(new_cases) as TotalNewCases, sum(cast (new_deaths as int)) 
  as TotalNewDeath, sum(cast (new_deaths as int))/ sum(new_cases)*100 as
  DeathPecentage  
  from PortfolioProject..CovidDeaths
  where continent is not null
  --Group by date 
  Order by 1,2


  --Looking at Total Population vs Vaccinations

  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  --SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
  SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
  from PortfolioProject..CovidDeaths dea
  JOin PortfolioProject..CovidVaccination vac
	   on dea.location = vac.location
	   and dea.date = Vac.date
	   where dea.continent is not null
   order by 2,3


--USE A CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  --SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
  SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
  from PortfolioProject..CovidDeaths dea
  JOin PortfolioProject..CovidVaccination vac
	   on dea.location = vac.location
	   and dea.date = Vac.date
	   where dea.continent is not null
   --order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
  

  --TEMP TABLE
Drop Table if exists #percentPopulationVaccinated
create Table #percentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar (255),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
   Insert into #percentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  --SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
  SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
  from PortfolioProject..CovidDeaths dea
  JOin PortfolioProject..CovidVaccination vac
	   on dea.location = vac.location
	   and dea.date = Vac.date
	   where dea.continent is not null
   --order by 2,3 

 select *, (RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated



--CREATING VIEWS TO STORE DATA FOR LATER


Create View PercentPopulationvaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  --SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
  SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
  from PortfolioProject..CovidDeaths dea
  JOin PortfolioProject..CovidVaccination vac
	   on dea.location = vac.location
	   and dea.date = Vac.date
	   where dea.continent is not null
  --order by 2,3  
  
 select *
 from PercentPopulationvaccination