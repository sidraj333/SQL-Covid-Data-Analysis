--Creating Views to store data

--This view shows the total amount of vaccinations at each date per country with each countrys continent, date, population, and new vaccinations
create view VaccinesPerDate as 
select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as float)) over (partition by deaths.location order by deaths.location,deaths.date) as vaccinations_per_country

from CovidDeaths deaths join CovidVaccinations vacc
	on deaths.location = vacc.location and deaths.date = vacc.date
where deaths.continent is not null
order by 2,3 desc


--This view shows the vaccination rate at each date per country with each countrys continent, date, population, and new vaccinations
create view VaccinePercentPerDate as
with cte_temp(continent, location, date, population, new_vaccinations, sum_vaccinations)
as(
select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as float)) over (partition by deaths.location order by deaths.date)
from CovidDeaths deaths join CovidVaccinations vacc
	on deaths.location = vacc.location and deaths.date = vacc.date
)
select continent, location, date, population, new_vaccinations, sum_vaccinations, sum_vaccinations/population as 'vaccination rate'
from cte_temp
where continent is not null


select *
from VaccinePercentPerDate
order by 2,3 desc

--this sproc selects the continent, location, date ,population, when the country reached the vaccination rate parameter
drop procedure min_time
create procedure min_time @rate float
AS
drop table if exists #mindate
create table #mindate

(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
)

Insert into #mindate
SELECT continent, location,  min(date) as 'Date Reached', avg(population) population
from VaccinePercentPerDate v1
where v1.[vaccination rate] > @rate
group by continent, location




--select v1.continent, v1.location, v2.date, v2.population, v1.sum_vaccinations as 'Total Vaccinations Until Date Reached', v1.[vaccination rate]
select*
from VaccinePercentPerDate v1 join #mindate v2
	on v1.continent = v2.continent and v1.location = v2.location and v1.date = v2.date
order by v1.location, v1.date






exec min_time @rate = .99;
exec min_time @rate = .8;