-- Consistent raters.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q9 CASCADE;

CREATE TABLE q9(
    client_id INTEGER,
    email VARCHAR(30)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS allRides CASCADE;
DROP VIEW IF EXISTS ratedRides CASCADE;
DROP VIEW IF EXISTS allRidesCount CASCADE;
DROP VIEW IF EXISTS ratedRidesCount CASCADE;
DROP VIEW IF EXISTS compare CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW allRides AS
SELECT Request.request_id, driver_id, client_id
FROM Request, Dispatch, Pickup, Dropoff, ClockedIn
WHERE Request.request_id = Dispatch.request_id AND Pickup.request_id = Dropoff.request_id AND Dispatch.request_id = Pickup.request_id AND ClockedIn.shift_id = Dispatch.shift_id;

CREATE VIEW ratedRides AS
SELECT driver_id, client_id, rating 
FROM DriverRating NATURAL JOIN allRides;

CREATE VIEW allRidesCount AS
SELECT client_id, count(Distinct driver_id) as allDriverCount
FROM allRides
Group By client_id;

CREATE VIEW ratedRidesCount AS
SELECT client_id, count(Distinct driver_id) as ratedDriverCount
From ratedRides
Group by client_id;

CREATE VIEW compare AS
SELECT client_id, allDriverCount, ratedDriverCount
FROM allRidesCount NATURAL JOIN ratedRidesCount
WHERE allDriverCount = ratedDriverCount;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q9
SELECT client_id, email
FROM compare NATURAL JOIN Client;
