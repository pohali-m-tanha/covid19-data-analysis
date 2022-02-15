SELECT *
FROM covid_deaths
ORDER BY 3,4 

--SELECT *
--FROM covid_vacc
--ORDER BY 3,4


--from covid_deaths table -----------------

SELECT location,date,total_cases,new_cases,total_deaths, population
FROM covid_deaths
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
where location like '%DENMARK%'
ORDER BY 1,2

--LOOKING AT THE TOTAL CASES VS THE POPULATION 
--SHOWS WHAT % OF THE POPULATION GOT COVID
SELECT location,date,total_cases,population, (total_cases/population)*100 as infected_percentage
FROM covid_deaths
where location like '%DENMARK%'
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location,MAX(total_cases)as highest_infection_count ,population, MAX((total_cases/population))*100 as infected_percentage
FROM covid_deaths
GROUP BY population, location
ORDER BY 4 DESC

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 
SELECT location,MAX(cast(total_deaths as int))as total_death_count
FROM covid_deaths
where continent is not null
GROUP BY location
ORDER BY total_death_count desc

--Let's break things down by continent 
SELECT location,MAX(cast(total_deaths as int))as total_death_count
FROM covid_deaths
where continent is null
GROUP BY location
ORDER BY total_death_count desc

--SHOWING CONTINETS WITH THE HIGHEST DEATTH COUNT
SELECT continent,MAX(cast(total_deaths as int))as total_death_count
FROM covid_deaths
where continent is not null
GROUP BY continent
ORDER BY total_death_count desc

--GLOBAL NUMBERS 
SELECT date,SUM(new_cases) as total_case_eachday, Sum(cast(new_deaths as int)) as total_death_eachday,  Sum(cast(new_deaths as int))/SUM(new_cases)*100 as global_death_percentage 
FROM covid_deaths
where continent is not null
GROUP BY date
ORDER BY 1,2

--total case world wide 
SELECT SUM(new_cases) as total_case_eachday, Sum(cast(new_deaths as int)) as total_death_eachday,  Sum(cast(new_deaths as int))/SUM(new_cases)*100 as global_death_percentage 
FROM covid_deaths
where continent is not null
--GROUP BY date
ORDER BY 1,2

--Joining covid_vacc and covid_deaths table -------------------------

SELECT *
FROM covid_vacc
JOIN covid_deaths
  ON covid_deaths.location=covid_vacc.location
  AND covid_deaths.date=covid_vacc.date

--joining tables and looking at vaccinnation vs population 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location
,dea.date) as cumilative_vaccination 
--,(cumilative_vaccination /population)*100
FROM covid_vacc vac
JOIN covid_deaths dea
  ON dea.location=vac.location
  AND dea.date=vac.date
  where dea.continent is not null
ORDER BY 2,3

--USING CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, cumilative_vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location
,dea.date) as cumilative_vaccination 
--,(cumilative_vaccination /population)*100
FROM covid_vacc vac
JOIN covid_deaths dea
  ON dea.location=vac.location
  AND dea.date=vac.date
  where dea.continent is not null
)
SELECT*, (cumilative_vaccination/population)*100 as percentage_vaccinated
FROM PopVsVac

Drop table if exists #PercentPopulationVaccinated

--USING TEMP TABLE


CREATE TABLE #PercentPopulationVaccinated

(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumilative_vaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location
,dea.date) as cumilative_vaccination 
--,(cumilative_vaccination /population)*100
FROM covid_vacc vac
JOIN covid_deaths dea
  ON dea.location=vac.location
  AND dea.date=vac.date
where dea.continent is not null
SELECT*, (cumilative_vaccination/population)*100 as percentage_vaccinated
FROM #PercentPopulationVaccinated

--altering something in the table and running again 
Drop table if exists #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIATION 
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location
,dea.date) as cumilative_vaccination 
--,(cumilative_vaccination /population)*100
FROM covid_vacc vac
JOIN covid_deaths dea
  ON dea.location=vac.location
  AND dea.date=vac.date
where dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated