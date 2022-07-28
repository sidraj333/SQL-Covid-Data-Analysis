--selecting every column covid deaths table
SELECT *
FROM CovidDeaths
order by 3,4

--selecting every column from covidvaccinations table
Select *
From CovidVaccinations
Order By 3,4

--selecting every column from combining covid deaths and covid vaccinations
select*
from CovidDeaths d join CovidVaccinations v
	on d.location = v.location and d.date = v.date
order by d.location,d.date

--Selecting the location column, date column, total cases column, new cases column, total deaths column, and populationm column from covid deaths table

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by Location, Date


--selecting location, date, total cases, total deaths and death percentage given you get covid. All this is from united states
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as "DeathPercentage"
From CovidDeaths
Where location like '%states%'
Order by Location, Date

--Selecting location, date, population, total cases, and contraction rate in unied states
Select Location, date, population,  total_cases,  (total_cases/population) "ContractionPercentage"
From CovidDeaths
Where location like '%states%'
Order by Location, Date desc

--Looking at countries with highest contraction rate rate 
Select Location, population, sum(new_cases) as HighestInfectionCount,  sum(new_cases)/avg(population) "MaxContractionPercentage"
From CovidDeaths
Group by Location, Population
Order by MaxContractionPercentage DESC

--Showing Countries with Covid Highest Death Rate per Population
select location, population, sum(new_cases), max(total_deaths), max(total_deaths)/sum(new_cases) as 'covid_death_rate'
from CovidDeaths
group by location, population

--Total Death Count by Continent

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/(sum(new_cases)) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by date, DeathPercentage desc


--covid vaccinations table combined with covid deaths table

select*
from CovidDeaths deaths join CovidVaccinations vacc
	on deaths.location = vacc.location and deaths.date = vacc.date

--Using a CTE to find vaccinations per country

With PopulationVsVaccination (continent, location, date, population, new_vaccinations, vaccinations_per_country)
as
(

select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as float)) over (partition by deaths.location order by deaths.location, deaths.date) as vaccinations_per_country

from CovidDeaths deaths join CovidVaccinations vacc
	on deaths.location = vacc.location and deaths.date = vacc.date
where deaths.continent is not null

)
select*, (vaccinations_per_country/population) * 100 as vaccination_percentage
from PopulationVsVaccination


--Using a temp table to find vaccinations per country

drop table if exists #percentpopulationvaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
vaccinations_per_country numeric
)
Insert into #percentpopulationvaccinated

select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as float)) over (partition by deaths.location order by deaths.location, deaths.date) as vaccinations_per_country

from CovidDeaths deaths join CovidVaccinations vacc
	on deaths.location = vacc.location and deaths.date = vacc.date
where deaths.continent is not null

select*, (vaccinations_per_country/population)  as vaccination_percentatage
from #percentpopulationvaccinated






