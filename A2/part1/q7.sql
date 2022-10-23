-- Ratings histogram.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q7 CASCADE;

CREATE TABLE q7(
    driver_id INTEGER,
    r5 INTEGER,
    r4 INTEGER,
    r3 INTEGER,
    r2 INTEGER,
    r1 INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS driverRated CASCADE;
DROP VIEW IF EXISTS fivestars CASCADE;
DROP VIEW IF EXISTS fourstars CASCADE;
DROP VIEW IF EXISTS threestars CASCADE;
DROP VIEW IF EXISTS twostars CASCADE;
DROP VIEW IF EXISTS onestars CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW driverRated AS
SELECT driver_id, rating
FROM ClockedIn, Dispatch, DriverRating
WHERE ClockedIn.shift_id = Dispatch.shift_id AND Dispatch.request_id = DriverRating.request_id;

CREATE VIEW fivestars AS
SELECT driver_id, count(rating) as r5
FROM driverRated
WHERE rating = 5
GROUP BY driver_id;

CREATE VIEW fourstars AS
SELECT driver_id, count(rating) as r4
FROM driverRated
WHERE rating = 4
GROUP BY driver_id;

CREATE VIEW threestars AS
SELECT driver_id, count(rating) as r3
FROM driverRated
WHERE rating = 3
GROUP BY driver_id;

CREATE VIEW twostars AS
SELECT driver_id, count(rating) as r2
FROM driverRated
WHERE rating = 2
GROUP BY driver_id;

CREATE VIEW onestars AS
SELECT driver_id, count(rating)as r1
FROM driverRated
WHERE rating = 1
GROUP BY driver_id;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q7
SELECT Driver.driver_id, COALESCE(r5, 0), COALESCE(r4, 0), COALESCE(r3, 0), COALESCE(r2, 0), COALESCE(r1, 0)
FROM fivestars NATURAL FULL JOIN fourstars NATURAL FULL JOIN threestars NATURAL FULL JOIN twostars NATURAL FULL JOIN onestars NATURAL FULL JOIN Driver; 
