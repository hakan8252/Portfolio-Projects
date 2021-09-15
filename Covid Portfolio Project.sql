-- Total number of cases in the world

Select location, sum(total_cases) as "Dünyadaki Toplam Vaka"
FROM webservice_db.`owid-covid-data` 
where location in ("World") and date='2021-06-05'
group by location;



-- Deaths per million in Afghanistan

Select location, sum(total_deaths_per_million)
FROM webservice_db.`owid-covid-data` 
where location in ("Afghanistan") and date='2021-06-05'
group by location;



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From webservice_db.`owid-covid-data`
Where location like '%states%'
and continent is not null 
order by 1,2;



-- Total number of cases and deaths by median age

SELECT median_age, sum(total_cases), sum(total_deaths)
 FROM webservice_db.`owid-covid-data`
 WHERE date='2021-06-05' and median_age!='NULL' 
 Group by median_age
 ORDER BY median_age desc limit 50;



 -- Rate of death from heart attack by continent and country
 
SELECT continent, location, cardiovasc_death_rate
 FROM webservice_db.`owid-covid-data`
 WHERE date='2021-06-05' and cardiovasc_death_rate != 'NULL'
 Group by continent, location
 ORDER BY cardiovasc_death_rate;


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM webservice_db.`owid-covid-data`
-- Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From webservice_db.`owid-covid-data`
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2




-- Top 5 countries with an average age of people greater than the world average

 SELECT continent,location,median_age, (Select avg(median_age) from webservice_db.`owid-covid-data` where location != "World") as Dunya_Ortalaması
 FROM webservice_db.`owid-covid-data`
 WHERE date='2021-06-05' and median_age is not null and median_age > (Select avg(median_age) from webservice_db.`owid-covid-data` where location != "World")
 GROUP BY location
 ORDER BY median_age DESC limit 5;
 
 
-- The country with the lowest number of hospital beds per 1000 people and its date
 
Select date, continent, location, hospital_beds_per_thousand
from webservice_db.`owid-covid-data`
where hospital_beds_per_thousand is not null
group by location
order by hospital_beds_per_thousand asc limit 1;

-- What is the purchasing power of 5 countries with a high ratio of people over the age of 65 to the population?

Select continent, location, population, aged_65_older, ((aged_65_older/population)*100) as '65 yaşındakilerin nüfusa göre oranı', gdp_per_capita
from webservice_db.`owid-covid-data`
where (population and aged_65_older is not null)
group by location
order by ((aged_65_older/population)*100) desc limit 5;

-- The ratio of the number of people who have received 2 doses of the vaccine to the total population in Germany

Select continent, location, population, people_fully_vaccinated, ((people_fully_vaccinated/population)*100) as '2 Doz aşı olanların nüfusa göre oranı'
from webservice_db.`owid-covid-data`
where date='2021-06-04' and (population and people_fully_vaccinated is not null) and location = "Germany"
group by location;




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From webservice_db.`owid-covid-data`..CovidDeaths dea
Join webservice_db.`owid-covid-data`..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated










