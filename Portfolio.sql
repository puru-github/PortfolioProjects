
--use portfolio
--select location, date, total_cases, total_deaths, population
--from CovidDeaths
--order by 1,2


--Percentage deceased 

--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As deaths_percentage
--from CovidDeaths
--where location like '%india%'
--order by 1,2

--Looking at total cases vs population

--select location, date, population, total_cases, (total_cases/population)*100 As population_percentage
--from CovidDeaths
--where location like '%india%'
--order by 1,2;

--Countries with highest infection rate to population

--select location, population, max(total_cases) as highestInfectionCount, max(total_cases/population)*100 As percentPopulation
--from CovidDeaths
--group by location, population
--order by highestInfectionCount desc


--Countries with the hightest death count 

select location, population, max(total_deaths) as highestDeathCount, max(total_deaths/population)*100 As percentPopulation
from CovidDeaths
group by location, population
order by highestDeathCount desc


--highest death count of people country wise

select location, population, max(cast(total_deaths as int)) as total_deaths
from CovidDeaths
where continent is not null
group by location, population
order by total_deaths desc


--highest death count of people continent wise

select continent, max(cast(total_deaths as int)) as total_deaths
from CovidDeaths
where continent is not null
group by continent
order by total_deaths desc


--Total population vs vaccination

select d.continent, d.location, d.date, d.population,  v.new_vaccinations, 
SUM(convert(int, v.new_vaccinations)) OVER (partition by d.location order by d.location, d.date) as RollingPeopleVaccination

from CovidDeaths d
join CovidVaccinations v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 2,3


--Use CTE

with PopVsVacc(continent, location, date, population, new_vaccinations, RollingPeopleVaccination )
as 
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(convert(int, v.new_vaccinations)) OVER (partition by d.location order by d.location, d.date) as RollingPeopleVaccination
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location 
and d.date = v.date
where d.continent is not null

)
select *, (RollingPeopleVaccination/population)*100 as PercantagePopulationVaccinated
from PopVsVacc

--Temp table 

Drop table if exists #PercentePopulationVaccinated
create table #PercentePopulationVaccinated
(continet nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric)

insert into #PercentePopulationVaccinated
select d.continent, d.location, d.date, d.population,  v.new_vaccinations, 
SUM(convert(int, v.new_vaccinations)) OVER (partition by d.location order by d.location, d.date) as RollingPeopleVaccination

from CovidDeaths d
join CovidVaccinations v
on d.location = v.location 
and d.date = v.date


select *, (RollingPeopleVaccination/population)*100 as PercantagePopulationVaccinated
from #PercentePopulationVaccinated


--Creating view to strore date for later visualization

create view PercentePopulationVaccinated as 
select d.continent, d.location, d.date, d.population,  v.new_vaccinations, 
SUM(convert(int, v.new_vaccinations)) OVER (partition by d.location order by d.location, d.date) as RollingPeopleVaccination
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location 
and d.date = v.date
where d.continent is not null





