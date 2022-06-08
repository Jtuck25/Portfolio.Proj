SELECT *
FROM ..['Covid Deaths $']
ORDER BY 3,4

SELECT *
FROM ..['Covid Vaccinations $']
ORDER BY 3,4	

--Using these to verify that my tables are different but still parts of original dataset

SELECT Location, date, total_cases, new_cases, Total_deaths, population
from ['Covid Deaths $']
order by 1,2

--Death per case 
---Showing likelihood of death with contraction of Covid-19

SELECT Location, date, total_cases, Total_deaths,(total_deaths/total_cases)*100 as PercentageDead
from ['Covid Deaths $']
WHERE location like '%states%'
order by 1,2

--Total cases per population 
--Proportion of population that has Covid-19
SELECT Location, date, total_cases, Population,(total_cases/Population)*100 as Casesbypopulation
from [dbo].['Covid Deaths $']
WHERE location like '%Argentina%'
order by 1,2

--Countries with highest infection rate by population
SELECT Location, Max(total_cases) as HighestInfectionCT, Population,MAX((total_cases/Population))*100 as Percentofpopulationinfected
from [dbo].['Covid Deaths $']
Group by Location, Population
order by Percentofpopulationinfected asc

--Highest death count by population
--Also expressed as a percentage
SELECT Location, Max(total_deaths) as Totaldeathcount, Population,MAX((total_deaths/Population))*100 as Percentofpopulationdeaths
From [dbo].['Covid Deaths $']
Where continent is not null 
Group by Location, population
order by Totaldeathcount desc

--Organize Continents by deathcount

SELECT continent, Max(total_deaths) as Totaldeathcount
From [dbo].['Covid Deaths $']
Where continent is not null 
Group by continent
order by Totaldeathcount desc

--By global per day 
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, (SUM(Cast(new_deaths as int))/SUM(new_cases)) as DeathPercentage
from ['Covid Deaths $']
WHERE continent is not null
Group by date
order by 1,2

--JOIN used to combine both Vaccination and Death table 
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
From  [dbo].['Covid Deaths $'] dea
Join [dbo].['Covid Vaccinations $'] vax
	On dea.location = vax.location
	and dea.date = vax.date
	WHERE dea.continent is not null
	Order by 2,3


--Use CTE
With PopvsVac(Continent, Location, Date, Population, people_vaccinated, rollingcountdeaths) 
as
(Select dea.continent, dea.location, dea.date, dea.population, vax.people_vaccinated, SUM(Cast (dea.total_deaths as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) rollingcountdeaths 
From  [dbo].['Covid Deaths $'] dea
Join [dbo].['Covid Vaccinations $'] vax
	On dea.location = vax.location
	and dea.date = vax.date
	WHERE dea.continent is not null
	
	)
	Select * 
	From PopvsVac




---NEXT STEP
--Temp table 
Drop Table if exists #PopulationVaccinated
Create Table #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
people_vaccinated Numeric,
rollingcountdeaths Numeric)


Insert into #PopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vax.people_vaccinated, SUM(Cast (dea.total_deaths as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as rollingcountdeaths 
From  [dbo].['Covid Deaths $'] dea
Join [dbo].['Covid Vaccinations $'] vax
	On dea.location = vax.location
	and dea.date = vax.date
	WHERE dea.continent is not null
	

Select *, (rollingcountdeaths/population)*100
From #PopulationVaccinated


---Creating view for visualizations later on
Create View PopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vax.people_vaccinated, SUM(Cast (dea.total_deaths as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as rollingcountdeaths 
From  [dbo].['Covid Deaths $'] dea
Join [dbo].['Covid Vaccinations $'] vax
	On dea.location = vax.location
	and dea.date = vax.date
	WHERE dea.continent is not null


Select *
From PopulationVaccinated
