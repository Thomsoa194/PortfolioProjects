-- General overview of the dataset
SELECT * 
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;



-- Select Data That I'm Using 

SELECT location, date, total_cases, total_deaths, new_cases, population
FROM covid_deaths
ORDER BY 1, 2;

-- Looking at Total Cases Versus Total Deaths
-- Shows the Likelihood of dying if you contract Covid in the UK

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM covid_deaths
--WHERE location = 'United Kingdom'
ORDER BY 1, date(date);



-- Looking at the total cases vs population
-- Shows percentage of UK population that got covid.  

SELECT location, date, population, total_cases, (total_cases / population) * 100 AS PercentPopulationInfected
FROM covid_deaths
-- WHERE location = 'United Kingdom'
ORDER BY 1, date(date);



-- Looking at countries with highest infection rate compared to population 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM covid_deaths
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC;



-- Looking at the countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;



-- Looking at things by continent with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- Looking at global numbers 

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 AS DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;



-- Looking at Total population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as INT64)) OVER (
	PARTITION BY dea.location
	ORDER BY dea.location, dea.date
) AS RollingVaccinatedCount
FROM covid_deaths dea
JOIN covid_vaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;



--- Rolling percent of population vaccinated - CTE method

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinatedCount)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as INT64)) OVER (
	PARTITION BY dea.location
	ORDER BY dea.location, dea.date
) AS RollingVaccinatedCount
FROM covid_deaths dea
JOIN covid_vaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccinatedCount / population) * 100 as RollingPercent
FROM PopvsVac;




