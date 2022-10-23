-- Frequent riders.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q6 CASCADE;

CREATE TABLE q6(
    client_id INTEGER,
    year CHAR(4),
    rides INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS fullRide CASCADE;
DROP VIEW IF EXISTS fullRideYear CASCADE;
DROP VIEW IF EXISTS masterTable CASCADE;
DROP VIEW IF EXISTS maxone CASCADE;
DROP VIEW IF EXISTS topone CASCADE;
DROP VIEW IF EXISTS maxtwo CASCADE;
DROP VIEW IF EXISTS toptwo CASCADE;
DROP VIEW IF EXISTS maxthree CASCADE;
DROP VIEW IF EXISTS topthree CASCADE;
DROP VIEW IF EXISTS minone CASCADE;
DROP VIEW IF EXISTS lowone CASCADE;
DROP VIEW IF EXISTS mintwo CASCADE;
DROP VIEW IF EXISTS lowtwo CASCADE;
DROP VIEW IF EXISTS minthree CASCADE;
DROP VIEW IF EXISTS lowthree CASCADE;
DROP VIEW IF EXISTS master CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW fullRide AS
SELECT client_id, EXTRACT(Year From Request.datetime) as Year, count(Request.request_id) as rides
FROM Request, Dispatch, Pickup, Dropoff
WHERE Request.request_id = Dispatch.request_id AND Dispatch.request_id = Pickup.request_id AND Pickup.request_id = Dropoff.request_id
GROUP BY client_id, Year;

CREATE VIEW fullRideYear AS
SELECT DISTINCT Year
FROM fullRide;

CREATE VIEW masterTable AS
SELECT client_id, Year, COALESCE(rides, 0) as rides
FROM fullRideYear NATURAL FULL JOIN Client NATURAL FULL JOIN fullRide;

CREATE VIEW maxone AS
SELECT max(rides) as maxonenum 
FROM masterTable;

CREATE VIEW topone AS
SELECT client_id, Year, rides
FROM masterTable, maxone
WHERE rides = maxonenum;

CREATE VIEW maxtwo AS
SELECT DISTINCT rides AS maxtwonum
FROM masterTable f1
WHERE 1=(SELECT count(DISTINCT rides) FROM masterTable f2 WHERE f2.rides>f1.rides);

CREATE VIEW toptwo AS
SELECT client_id, Year, rides
FROM masterTable, maxtwo
WHERE rides = maxtwonum;

CREATE VIEW maxthree AS
SELECT DISTINCT rides AS maxthreenum
FROM masterTable f1
WHERE 2=(SELECT count(DISTINCT rides) FROM masterTable f2 WHERE f2.rides>f1.rides);

CREATE VIEW topthree AS
SELECT client_id, Year, rides
FROM masterTable, maxthree
WHERE rides = maxthreenum;
	

CREATE VIEW minone AS
SELECT min(rides) as minonenum
FROM masterTable;

CREATE VIEW lowone AS
SELECT client_id, Year, rides
FROM masterTable, minone
WHERE rides = minonenum;

CREATE VIEW mintwo AS
SELECT DISTINCT rides AS mintwonum
FROM masterTable f1
WHERE 1=(SELECT count(DISTINCT rides) FROM masterTable f2 WHERE f2.rides<f1.rides);

CREATE VIEW lowtwo AS
SELECT client_id, Year, rides
FROM masterTable, mintwo
WHERE rides = mintwonum;

CREATE VIEW minthree AS
SELECT DISTINCT rides AS minthreenum
FROM masterTable f1
WHERE 2=(SELECT count(DISTINCT rides) FROM masterTable f2 WHERE f2.rides<f1.rides);

CREATE VIEW lowthree AS
SELECT client_id, Year, rides
FROM masterTable, minthree
WHERE rides = minthreenum;

CREATE VIEW master AS 
SELECT client_id, Year, rides
FROM topone
UNION
SELECT client_id, Year, rides
FROM toptwo
UNION
SELECT client_id, Year, rides
FROM topthree
UNION
SELECT client_id, Year, rides
FROM lowthree
UNION
SELECT client_id, Year, rides
FROM lowtwo
UNION
SELECT client_id, Year, rides
FROM lowone;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q6
SELECT client_id, Year, rides
FROM master
ORDER BY client_id;
