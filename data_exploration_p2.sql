--SQL QUEIRES FOR TABLEAU
--1
--Shows global death percentage 
SELECT SUM(new_cases) as total_case, Sum(cast(new_deaths as int)) as total_death,  
Sum(cast(new_deaths as int))/SUM(new_cases)*100 as global_death_percentage 
FROM covid_deaths
where continent is not null
ORDER BY 1,2

--2
--Shows total death continent wise
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covid_deaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--3
--Shows percentage of population infected countrywise, high to low 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc


--4 
--Shows infected population percentage coutnrywise eachday, high to low
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
