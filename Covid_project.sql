 -- EXPLORING INITIAL DATA
SELECT *
FROM covid_portafolio.`owid-covid-death`
ORDER BY location;
 
	-- Casting Date colum from string to date format 
	SELECT date,
		str_to_date(date,'%m/%d/%y') AS New_Date
	FROM covid_portafolio.`owid-covid-death`;

-- EXPLORE DATA BY LOCATION
SELECT location,
	date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM covid_portafolio.`owid-covid-death`
ORDER BY location;
    
    -- Looking at Total Cases Vs. Total Deaths by Percentage
	SELECT location,
		CAST(date AS DATETIME),
		total_cases,
		total_deaths,
        CAST((total_deaths/total_cases)*100 AS DECIMAL(4,4)) AS Death_Percentage,
		population
    FROM covid_portafolio.`owid-covid-death`
    WHERE location LIKE '%venezuela%'
    ORDER BY location;
    
    -- Looking at Total Cases vs. Population by Percentage
    -- Shows how much people got infected in the country
	SELECT location,
		CAST(date AS DATETIME),
		population,
        total_cases,
        CAST((total_cases/population)*100 AS DECIMAL(4,4)) AS Infected_Percentage
    FROM covid_portafolio.`owid-covid-death`
    WHERE location like '%venezuela%'
    ORDER BY location;
    
    -- Looking at which country have the high rate of infection
    SELECT location,
		population,
        MAX(total_cases) AS Max_Infection,
        MAX((total_cases/population)*100) AS Max_Infected_Percentage
    FROM covid_portafolio.`owid-covid-death`
    WHERE continent <> ''
    GROUP BY location,population
    ORDER BY Max_Infection DESC;
    
    -- Looking at highest Deaths count per Country
    SELECT location,
		population,
        MAX(CAST(total_deaths AS UNSIGNED)) AS Max_Deaths
    FROM covid_portafolio.`owid-covid-death`
    WHERE continent <> ''
    GROUP BY location,population
    ORDER BY Max_Deaths DESC;
    
	-- Looking at highest Deaths count by Continent
    SELECT location,
        MAX(CAST(total_deaths AS UNSIGNED)) AS Max_Deaths
    FROM covid_portafolio.`owid-covid-death`
    WHERE continent = ''
    GROUP BY location
    ORDER BY Max_Deaths DESC;
    
-- GLOBAL NUMBERS
	-- Total Cases vs Total Deaths and Percentage in the World 
	SELECT
		SUM(new_cases) AS World_New_Cases_day,
		SUM(CAST(new_deaths AS UNSIGNED)) AS World_New_deaths_day,
        SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases) *100 AS World_Deaths_Percentage
    FROM covid_portafolio.`owid-covid-death`
    WHERE continent = ''
    ORDER BY 1 ;
	
    -- Total Cases, Deaths and percentage by Day in the World
    SELECT str_to_date(date,'%m/%d/%y') AS New_Date,
		SUM(new_cases) AS World_New_Cases_day,
		SUM(CAST(new_deaths AS UNSIGNED)) AS World_New_deaths_day,
        SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases) *100 AS World_Deaths_Percentage
    FROM covid_portafolio.`owid-covid-death`
    WHERE continent = ''
    GROUP BY New_Date
    ORDER BY 1 ;

-- Joining Tables

	-- Join Death and Vaccine Tables
	SELECT *
	FROM covid_portafolio.`owid-covid-death`AS deaths
	JOIN covid_portafolio.`owid-covid-vacc` AS vacc	
		ON deaths.location = vacc.location
		AND deaths.date = vacc.date;
	
    -- Total Population Vs Vaccinations
	SELECT deaths.continent,
		deaths.location,
        str_to_date(deaths.date,'%m/%d/%y') AS New_Date,
        deaths.population,
        vacc.new_vaccinations,
        SUM(CAST(vacc.new_vaccinations AS unsigned)) OVER (partition by deaths.location ORDER BY deaths.location, str_to_date(deaths.date,'%m/%d/%y')) AS Total_Vacc_Daily
	FROM covid_portafolio.`owid-covid-death`AS deaths
	JOIN covid_portafolio.`owid-covid-vacc` AS vacc	
		ON deaths.location = vacc.location 
		AND deaths.date = vacc.date
	WHERE deaths.continent <> '' 
	ORDER BY 2,3;
    
    -- Use of CTE to calculate percentage of vaccinated people
    
    WITH PopvsVacc (continent, location, date, population, new_vaccinations, Total_Vacc_Daily)
    AS
    (
    SELECT deaths.continent,
		deaths.location,
        str_to_date(deaths.date,'%m/%d/%y') AS New_Date,
        deaths.population,
        vacc.new_vaccinations,
        SUM(CAST(vacc.new_vaccinations AS unsigned)) OVER (partition by deaths.location ORDER BY deaths.location, str_to_date(deaths.date,'%m/%d/%y')) AS Total_Vacc_Daily
	FROM covid_portafolio.`owid-covid-death`AS deaths
	JOIN covid_portafolio.`owid-covid-vacc` AS vacc	
		ON deaths.location = vacc.location 
		AND deaths.date = vacc.date
	WHERE deaths.continent <> '' 
	-- ORDER BY 2,3
    )
    SELECT *, (Total_Vacc_Daily / Population)*100
    FROM PopvsVacc;
    
    -- Creating a view for Data Visualiztions
    
    CREATE VIEW PercentPopVaccinated AS
    SELECT deaths.continent,
		deaths.location,
        str_to_date(deaths.date,'%m/%d/%y') AS New_Date,
        deaths.population,
        vacc.new_vaccinations,
        SUM(CAST(vacc.new_vaccinations AS unsigned)) OVER (partition by deaths.location ORDER BY deaths.location, str_to_date(deaths.date,'%m/%d/%y')) AS Total_Vacc_Daily
	FROM covid_portafolio.`owid-covid-death`AS deaths
	JOIN covid_portafolio.`owid-covid-vacc` AS vacc	
		ON deaths.location = vacc.location 
		AND deaths.date = vacc.date
	WHERE deaths.continent <> '' 