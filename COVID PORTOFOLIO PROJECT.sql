SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
--shows a liklihood of dying if you contract covid in your country
Select location , date , total_cases , total_deaths , cast(total_deaths as float)/cast(total_cases AS float)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
order by 1,2

-- looking at the total cases vs the populations
-- Shows what percentage of populations got covid
Select location , date , total_cases , population , cast((total_cases)/(population) as float)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
order by 1,2


-- Look at countries with Highest infection rates compared to populations

Select location , population ,Max(total_cases) as Highest_infection, max(cast((total_cases)/(population) as float)*100) as population_infection_rate
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location,population
order by population_infection_rate desc

--Look at countries with highest death per population
Select location,Max(total_deaths) as total_death_count
FROM PortfolioProject..CovidDeaths
where continent != ' ' 
GROUP BY location
order by total_death_count desc

--lets do that with continent
Select continent,Max(total_deaths) as total_death_count
FROM PortfolioProject..CovidDeaths
where continent != ' ' 
GROUP BY continent
order by total_death_count desc

-- global numbers 
Select SUM(new_cases) as total_cases  , SUM(new_deaths) as total_deaths,
(CAST(SUM(new_deaths)AS float)/CAST(SUM(new_cases) AS float) *100) as Death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent != ' '
order by 1,2

--Looking for total population vs vaccinations
SELECT dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations ,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated /population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent != ' ' 
ORDER BY 2,3


--USE CTE 
WITH pop_vs_vac (continent, location , date,population, new_vaccinations, rolling_people_vaccinated)
as (
SELECT dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations ,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated /population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent != ' ' 
--ORDER BY 2,3
)
SELECT * ,(rolling_people_vaccinated /population)*100
FROM pop_vs_vac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population float ,
new_vaccinations float,
rolling_people_vaccinated float
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations ,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated /population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent != ' ' 
--ORDER BY 2,3
SELECT * ,(rolling_people_vaccinated /population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER 
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations ,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated /population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent != ' ' 