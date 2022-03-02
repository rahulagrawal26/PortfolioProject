
select*from dbo.CovidDeaths
where continent is not null
order by 3,4 

----select*from 
--dbo.CovidVaccinations
----order by 3,4

--Select Data that we are going to be using 
select location ,date,total_cases , new_cases , total_deaths ,population
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
order by 1,2 

--Looking at Total Cases vs Total Deaths
--shows the likelihood of dying if you contract covid in your country 
select location ,date,total_cases , total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
order by 1,2 

--Looking at Total cases  vs Population 
--Shows what percentage population got covid
select location ,date, population ,total_cases , (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
order by 1,2 

--Looking at countires with higehst infection rate compared to population 
select location ,population ,MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like'%afghanistan%'
group by location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
select location ,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like'%afghanistan%'
where continent is not null
group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT 


--Showing the continents with the highest death count per population 
select continent ,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like'%afghanistan%'
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS 

--shows the likelihood of dying if you contract covid in your country 
select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int )) as total_deaths,SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as 
DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
group by date
order by 1,2 

-- shows the total global tally
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int )) as total_deaths,SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as 
DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
--group by date
order by 1,2 

--Using the Covid vaccination table 
select*from 
PortfolioProject.dbo.CovidVaccinations

-- Joining the two tables together
Select*
from  PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 

-- Looking at total population vs vaccinations 
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint ,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location ,dea.date) as
RollingPeopleVaccinated,--(RollingPeopleVaccinated/Population)*100
from  PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null
order by 2,3 


--either use CTE or temp table 

--use CTE 
with PopvsVac(continent ,location ,date ,population ,new_vaccinations,RollingPeopleVaccinated)
as
(Select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
,SUM(convert(bigint ,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location ,dea.date) as
RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from  PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp table

DROP Table if exists #percentPopulationVaccinated
Create table #percentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into  #percentPopulationVaccinated
Select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
,SUM(convert(bigint ,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location ,dea.date) as
RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from  PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated


--creating views to store data for later visualizations
create view percentPopulationVaccinated as
Select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
,SUM(convert(bigint ,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location ,dea.date) as
RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from  PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select * 
from percentPopulationVaccinated