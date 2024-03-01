/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
select*
from PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- selecting the data that we are going to start with

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of death if you get covid in your country
  
select location,date,total_cases,total_deaths,CAST(total_deaths AS DECIMAL)/ CAST(total_cases AS decimal)*100 AS Death_percentage
from PortfolioProject..CovidDeaths
where location like 'INDIA'
order by 1,2

--Looking at total_cases vs population
-- Shows what percentage of population infected with Covid
  
select location,date,population,total_cases,CAST(total_cases AS DECIMAL)/ CAST(population AS decimal)*100 AS affected_percentage
from PortfolioProject..CovidDeaths
--where location like 'INDIA'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as Highest_infection_COUNT,max(CAST(total_cases AS DECIMAL)/ CAST(population AS decimal))*100 AS affected_percentage
from PortfolioProject..CovidDeaths
--where location like 'INDIA'
group by location,population
order by 4 DESC

-- countries with highest death count per population

select location,max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
--where location like 'INDIA'
where continent is not null
group by location
order by 2 desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

select continent,max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
--where location like 'INDIA'
where continent is not null
group by continent
order by 2 desc

--GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases) as Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1

--Looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null --and vac.new_vaccinations is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
-- POPULATION VS VACCINATION PERCENTAGE
  
WITH POPVSVAC(continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null-- and dea.location like 'india'--and vac.new_vaccinations is not null
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population)*100 as vacpercentage
from POPVSVAC

-- Using Temp Table to perform Calculation on Partition By in previous query
  
drop table if exists #Rollingpeoplevaccinated
CREATE TABLE #Rollingpeoplevaccinated(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATIONS NUMERIC,
Rollingpeoplevaccinated NUMERIC
)
INSERT INTO #Rollingpeoplevaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null-- and dea.location like 'india'--and vac.new_vaccinations is not null
--order by 2,3
select *,(Rollingpeoplevaccinated/population)*100 as vacpercentage
from #Rollingpeoplevaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISAUALISATIONS.
-- CREATING VIEW
--view 1
  
CREATE VIEW Rollingpeoplevaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null-- and dea.location like 'india'--and vac.new_vaccinations is not null
--order by 2,3

SELECT*
FROM Rollingpeoplevaccinated

--view 2
  
create view Death_percentage as
select location,date,total_cases,total_deaths,CAST(total_deaths AS DECIMAL)/ CAST(total_cases AS decimal)*100 AS Death_percentage
from PortfolioProject..CovidDeaths
where location like 'INDIA'
--order by 1,2

SELECT*
FROM Death_percentage

--view 3

create view affected_percentage as
select location,population,max(total_cases) as Highest_infection_COUNT,max(CAST(total_cases AS DECIMAL)/ CAST(population AS decimal))*100 AS affected_percentage
from PortfolioProject..CovidDeaths
--where location like 'INDIA'
group by location,population

--order by 4 DESC

select*
from affected_percentage

--view 4

--Showing countries with most death count per population
create view Total_death_count as
select location,max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
--where location like 'INDIA'
where continent is not null
group by location
--order by 2 desc

select*
from Total_death_count
