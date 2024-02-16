Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--SELECT location, date,
--       ISNULL(total_cases, 0) as total_cases,
--       ISNULL(total_deaths, 0) as total_deaths,
--       (ISNULL(total_deaths, 0) / NULLIF(ISNULL(total_cases, 0), 0)) as mortality_rate
--FROM PortfolioProject..CovidDeaths;
--In this example above, ISNULL function replaces NULL with 0 in the calculation, 
--and NULLIF is used to avoid division by zero by returning NULL if total_cases is 0.



--Looking  at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT))*100 AS mortality_rate
From PortfolioProject..CovidDeaths
Where location = 'Africa'
and continent is not null
order by 1,2

--Looking at Total cases vs population
--shows what percentage of population got covid or the proportion of total cases relative to the population as a percentage
-- the percentage of the population that has been reported as cases
Select location, date, population, total_cases,(total_cases / population) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Africa'
and  continent is null
order by 1,2

--What countries have the highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases / population)) * 100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'Africa'
where continent is not null
Group by population, location
order by PercentPopulationInfected Desc

--showing the countries with the highest death count per population
Select location, MAX (cast(total_deaths as float)) AS MaxTotalDeaths, MAX(cast(total_deaths as int) / population)* 100 AS PercentDeaths
From PortfolioProject..CovidDeaths
--Where location = 'Africa'
where continent is not null
Group by  location
order by MaxTotalDeaths Desc


--Breaking things down by continent
--1. Showing continents wiht the highest death count
--Didn't get accurate figures, so switched it back to location, and added null values from continents
--switched back to continents
Select continent, MAX (cast(total_deaths as float)) AS MaxTotalDeaths
From PortfolioProject..CovidDeaths
--Where location = 'Africa'
where continent is not null
Group by  continent
order by MaxTotalDeaths Desc

--2. Showing continents wiht the highest death count per population
Select continent, MAX (cast(total_deaths as float)) AS MaxTotalDeaths
From PortfolioProject..CovidDeaths
--Where location = 'Africa'
where continent is not null
Group by  continent
order by MaxTotalDeaths Desc


--GLOBAL NUMBERS
--sum of new cases colum contains 0, same as sum of new death
/*
To avoid the divide by zero error, you can use the NULLIF function to return NULL
instead of zero in the denominator of your division.
This prevents the error by making the division result NULL whenever sum(new_cases) is 0. 
*/
---, sum(new_deaths)/sum(new_cases) * 100  AS DeathPercentage xxx - this was given an error
Select date, sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location = 'Africa'
Where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location = 'Africa'
Where continent is not null
--group by date
order by 1,2




-- Total population vs vaccinations
select *
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


select  dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations--, people_vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



--How many people in the country are vaccinated. Total Population vs Max(cummulative people vacc)

--USE CTE or Temp table
/*Note: if the number of columns in the CTE is diff from the number of columns in the 
select statement, it will give an error*/

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population) *100 as PercentagePopVaccinated
From PopvsVac


--Using Temp Table

Drop Table if exists #PercentagePopulationVaccinated
--Recommended to add Drop table if...if you plan on making any alterations
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255), 
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population) *100 as PercentagePopVaccinated
From #PercentagePopulationVaccinated




--creating view to store data for later visualisations
create view PercentagePopulationVaccinated as
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,


--Query the view
Select *
From PercentagePopulationVaccinated
