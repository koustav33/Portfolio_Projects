/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from Potfolio_Project..CovidDeaths
where continent is not null
order by 2,3

--{select *
--from Potfolio_Project..CovidVaccinations
--order by 2,3}

-- Select Data that we are going to be starting with

select location,date,total_cases,new_cases,total_deaths,population
from Potfolio_Project..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths(Shows likelihood of dying if you contract covid in your country)

select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from Potfolio_Project..CovidDeaths
order by 1,2


-- Total Cases vs Population(Shows what percentage of population infected with Covid)

select location,date,total_cases,population,total_deaths,(total_cases/population)*100 as PercentPopulatinInfection
         from Potfolio_Project..CovidDeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location,MAX(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentPopulatinInfection
from Potfolio_Project..CovidDeaths
Group by location,population
order by  PercentPopulatinInfection desc


-- Countries with Highest Death Count per Population

select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from Potfolio_Project..CovidDeaths
where continent is not null
Group by location
order by  TotalDeathCount desc


--- BREAKING THINGS DOWN BY CONTINENT(Showing contintents with the highest death count per population)

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from Potfolio_Project..CovidDeaths
where continent is not null
Group by continent
order by  TotalDeathCount desc 


--Global Numbers

select sum(new_cases) as totalCases,sum(cast(new_deaths as int)) as totalDeath,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Potfolio_Project..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations(Shows Percentage of Population that has recieved at least one Covid Vaccine)

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from  Potfolio_Project..CovidDeaths as dea
 join Potfolio_Project..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
	order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac(Continent,location,date,population,New_Vaccinations,RollingPeopleVaccination)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from  Potfolio_Project..CovidDeaths as dea
 join Potfolio_Project..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
--	order by 2,3
)
select * ,(RollingPeopleVaccination/population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationvaccinated
create Table #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population nvarchar,
new_vaccination numeric,
RollingPeopleVaccination numeric
)
Insert into  #PercentPopulationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from  Potfolio_Project..CovidDeaths as dea
 join Potfolio_Project..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
	--where dea.continent is not null
	--order by 2,3
	select* ,(RollingPeopleVaccination/population)*100
	from #PercentPopulationvaccinated


-- Creating View to store data for later visualizations

Create View  PercentPopulationvaccinated  as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from  Potfolio_Project..CovidDeaths as dea
 join Potfolio_Project..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
	--order by 2,3
