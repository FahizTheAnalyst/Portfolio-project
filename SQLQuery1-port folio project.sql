select*
from PortfolioProject..CovidDeaths
order by 3,4

--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- selecting the data that we need from covid deaths

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows likelyhood of death if you get covid in your country
select location,date,total_cases,total_deaths,CAST(total_deaths AS DECIMAL)/ CAST(total_cases AS decimal)*100 AS Death_percentage
from PortfolioProject..CovidDeaths
where location like 'INDIA'
order by 1,2

--Looking at total_cases vs population
--Shows what percentage of population got covid
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

--Showing countries with most death count per population

select location,max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
--where location like 'INDIA'
where continent is not null
group by location
order by 2 desc

--Lets break it down by continent

select location,max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
--where location like 'INDIA'
where continent is  null --and location not like 'High income' and location not like 'Upper middle income' and location not like 'LOWER MIDDLE INCOME' and location not like 'LOW INCOME'
group by location
order by Total_death_count  desc

--Showing continents with highest death count
select continent,max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
--where location like 'INDIA'
where continent is not null
group by continent
order by 2 desc

--GLOBAL NUMBERS

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases) as Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1

--total cases globally and deaths
select sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases) as Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1

--Looking at total population vs vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null --and vac.new_vaccinations is not null
order by 2,3

--USING CTE
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

--POPULATION VS VACCINATION PERCENTAGE USING TEMP TABLES

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