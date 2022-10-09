-- Rest bylaw.
-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber,
    public;
DROP TABLE IF EXISTS q3 CASCADE;
CREATE TABLE q3(
    driver_id INTEGER,
    start DATE,
    driving INTERVAL,
    breaks INTERVAL
);
-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS DriverRequests CASCADE;
DROP VIEW IF EXISTS DriverPickups CASCADE;
DROP VIEW IF EXISTS DriverDuration CASCADE;
DROP VIEW IF EXISTS DriverShiftDuration CASCADE;
-- Define views for your intermediate steps here:
CREATE VIEW DriverRequests AS
SELECT driver_id,
    Dispatch.shift_id AS shift_id,
    request_id
from ClockedIn,
    Dispatch
WHERE ClockedIn.shift_id = Dispatch.request_id;
CREATE VIEW DriverPickups AS
SELECT driver_id,
    shift_id,
    Pickup.request_id,
    Pickup.datetime as ptime
from DriverRequests,
    Pickup
WHERE DriverRequests.request_id = Pickup.request_id;
CREATE VIEW DriverDropoffs AS
SELECT driver_id,
    shift_id,
    Dropoff.request_id,
    Dropoff.datetime as dtime
from DriverRequests,
    Dropoff
WHERE DriverRequests.request_id = Dropoff.request_id;
CREATE VIEW DriverDuration AS
SELECT driver_id,
    shift_id,
    request_id,
    dtime - ptime as duration
FROM DriverPickups
    NATURAL JOIN DriverDropoffs;
CREATE VIEW DriverShiftDuration AS
SELECT driver_id,
    shift_id,
    sum(duration) as driving
FROM DriverDuration
GROUP BY shift_id,
    driver_id;
-- Your query that answers the question goes below the "insert into" line:
-- INSERT INTO q3