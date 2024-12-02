

--  Retrieve details of flights involving Airbus A320 models
SELECT *
FROM Nyc_Flights_Snowflake.Fact_Flights AS facts
INNER JOIN Nyc_Flights_Star.DIM_AIRPLANES AS airplanes
ON facts.tailnum = airplanes.Tailnum
INNER JOIN Nyc_Flights_Snowflake.DIM_MODEL AS models
ON airplanes.Model = models.model
WHERE models.model LIKE 'A320%';



-- This query retrieves details of flights to LAX operated by Boeing aircraft,
-- including airplane, manufacturer, and airport information.
SELECT *
FROM Nyc_Flights_Snowflake.Fact_Flights AS facts
INNER JOIN Nyc_Flights_Star.DIM_AIRPLANES AS airplanes
ON facts.tailnum = airplanes.Tailnum
INNER JOIN Nyc_Flights_Snowflake.DIM_MODEL AS models
ON airplanes.Model = models.model
INNER JOIN Nyc_Flights_Snowflake.DIM_MANUFACTURER as manufacturers
ON models.Manufacturer_ID = manufacturers.Manufacturer_ID
INNER JOIN Nyc_Flights_Snowflake.DIM_AIRPORTS as airports
ON facts.dest = airports.faa
where manufacturers.manufacturer = 'BOEING'
AND airports.faa = 'LAX';


-- retrieves the average distance of flights grouped by airline Delta Air Lines Inc.
-- and aircraft manufacturer AIRBUS
SELECT
    airlines.Carrier_name,
    manufacturers.manufacturer,
    AVG(facts.distance) AS avg_distance
FROM Nyc_Flights_Snowflake.Fact_Flights AS facts
INNER JOIN Nyc_Flights_Star.DIM_AIRPLANES AS airplanes
ON facts.tailnum = airplanes.Tailnum
INNER JOIN Nyc_Flights_Snowflake.DIM_MODEL AS models
ON airplanes.Model = models.model
INNER JOIN Nyc_Flights_Snowflake.DIM_MANUFACTURER AS manufacturers
ON models.Manufacturer_ID = manufacturers.Manufacturer_ID
INNER JOIN Nyc_Flights_Snowflake.DIM_AIRLINES AS airlines
ON facts.carrier = airlines.Carrier
WHERE airlines.Carrier_name LIKE '%Delta%'
AND manufacturers.manufacturer = 'AIRBUS'
GROUP BY airlines.Carrier_name, manufacturers.manufacturer;

-- Analysis for JFK as a Manager

--  Retrieve flights from JFK with a distance greater than 1500 miles
SELECT *
FROM Nyc_Flights_Snowflake.Fact_Flights AS facts
INNER JOIN Nyc_Flights_Snowflake.DIM_AIRPORTS AS airports
ON facts.dest = airports.faa
WHERE facts.origin LIKE 'JFK%' AND facts.distance > 1500;


--retrieves the carrier flight numbers for flights originating from
-- JFK and destined for airports in Florida,
-- based on matching city and state information.
SELECT facts.carrier_flightnum
FROM Nyc_Flights_Snowflake.Fact_Flights AS facts
INNER JOIN Nyc_Flights_Snowflake.DIM_AIRPORTS as airports
ON facts.dest = airports.faa
INNER JOIN Nyc_Flights_Snowflake.DIM_CITY as city
ON airports.City_ID = city.City_ID
INNER JOIN Nyc_Flights_Snowflake.DIM_STATE as state
ON city.State_ID = state.State_ID
WHERE facts.origin like "JFK%" AND state.state = 'Florida';



--  retrieves the average departure delay for each
--  carrier flight originating from JFK, grouped by flight number.
SELECT facts.carrier_flightnum, AVG(facts.dep_delay) as avg_delay
FROM Nyc_Flights_Snowflake.Fact_Flights AS facts
WHERE facts.origin LIKE "JFK%"
GROUP BY facts.carrier_flightnum;


-- retrieves the average departure delay for each airline, grouped by airline name,
-- and orders the results in descending order of average delay.
SELECT airlines.carrier_name, AVG(facts.dep_delay) as avg_delay
FROM Nyc_Flights_Snowflake.Fact_Flights AS facts
INNER JOIN Nyc_Flights_Snowflake.DIM_AIRLINES AS airlines
on facts.carrier = airlines.Carrier
GROUP BY airlines.carrier_name
ORDER BY avg_delay DESC;


-- Now analysis as LGA manager

--  retrieves the flight numbers of flights departing earlier than scheduled
-- from La Guardia Airport
-- where the departure delay is negative.
SELECT facts.carrier_flightnum, airports.name
FROM Nyc_Flights_Snowflake.Fact_Flights AS facts
INNER JOIN Nyc_Flights_Snowflake.DIM_AIRPORTS AS airports
ON facts.dest = airports.faa
WHERE airports.name LIKE '%La Guardia%'
  AND
    facts.dep_delay < 0;


-- This query retrieves the flight numbers for flights originating from LGA and
-- destined for airports in New York state

SELECT FF.carrier_flightnum
FROM Nyc_Flights_Snowflake.Fact_Flights FF
JOIN Nyc_Flights_Snowflake.DIM_AIRPORTS DA ON DA.faa = FF.dest
JOIN Nyc_Flights_Snowflake.DIM_CITY DC ON DA.City_ID = DC.City_ID
JOIN Nyc_Flights_Snowflake.DIM_STATE DS ON DC.State_ID = DS.State_ID
WHERE FF.origin = 'LGA'
AND DS.state = 'New York';


-- This query retrieves the maximum departure delay for flights originating
-- from LGA in December 2013

SELECT MAX(FF.dep_delay)
FROM Nyc_Flights_Snowflake.Fact_Flights FF
JOIN Nyc_Flights_Snowflake.DIM_HOUR DH ON FF.sched_dep_id = DH.Time_ID
JOIN Nyc_Flights_Snowflake.DIM_DAY DD ON DH.DAY_ID = DD.DAY_ID
JOIN Nyc_Flights_Snowflake.DIM_MONTH DM ON DD.MONTH_ID = DM.MONTH_ID
JOIN Nyc_Flights_Snowflake.DIM_YEAR DY ON DM.YEAR_ID = DY.YEAR_ID
WHERE FF.origin = 'LGA'
AND DM.month = 12
AND DY.year = 2013;


-- This query retrieves the average departure delay for each aircraft model departing from LGA, ordered by the delay in descending order.

SELECT DM.model, AVG(FF.dep_delay)
FROM Nyc_Flights_Snowflake.Fact_Flights FF
JOIN Nyc_Flights_Snowflake.DIM_AIRPLANES DA ON FF.tailnum = DA.tailnum
JOIN Nyc_Flights_Snowflake.DIM_MODEL DM ON DA.Model_ID = DM.Model_ID
WHERE FF.origin = 'LGA'
GROUP BY DM.model
ORDER BY AVG(FF.dep_delay) DESC;



