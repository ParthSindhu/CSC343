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
DROP VIEW IF EXISTS DriverDropoffs CASCADE;
DROP VIEW IF EXISTS DriverDuration CASCADE;
DROP VIEW IF EXISTS DriverDayDuration CASCADE;
DROP VIEW IF EXISTS DriverBreaks CASCADE;
DROP VIEW IF EXISTS DriverBreaksDay CASCADE;
DROP VIEW IF EXISTS DriverBreaksFull CASCADE;
DROP VIEW IF EXISTS BadDays CASCADE;
DROP VIEW IF EXISTS BadDaysConsec CASCADE;
-- Define views for your intermediate steps here:
CREATE VIEW DriverRequests AS
SELECT driver_id,
    Dispatch.shift_id AS shift_id,
    Dispatch.request_id,
    date_trunc('day', Request.datetime) as rday
from ClockedIn,
    Dispatch,
    Request
WHERE ClockedIn.shift_id = Dispatch.shift_id
    AND Dispatch.request_id = Request.request_id;
CREATE VIEW DriverPickups AS
SELECT driver_id,
    rday,
    Pickup.request_id,
    Pickup.datetime as ptime
from DriverRequests,
    Pickup
WHERE DriverRequests.request_id = Pickup.request_id;
CREATE VIEW DriverDropoffs AS
SELECT driver_id,
    rday,
    Dropoff.request_id,
    Dropoff.datetime as dtime
from DriverRequests,
    Dropoff
WHERE DriverRequests.request_id = Dropoff.request_id;
CREATE VIEW DriverDuration AS
SELECT driver_id,
    request_id,
    DriverDropoffs.rday,
    dtime - ptime as duration
FROM DriverPickups
    NATURAL JOIN DriverDropoffs;
CREATE VIEW DriverDayDuration AS
SELECT driver_id,
    rday,
    sum(duration) as driving
FROM DriverDuration
GROUP BY rday,
    driver_id;
CREATE VIEW DriverBreaks AS
SELECT DriverPickups.rday,
    DriverPickups.driver_id,
    MIN(ptime - dtime) AS btime,
    dtime
FROM DriverDropoffs,
    DriverPickups
WHERE DriverDropoffs.driver_id = DriverPickups.driver_id
    AND DriverDropoffs.rday = DriverPickups.rday
    AND DriverDropoffs.request_id != DriverPickups.request_id
    AND (ptime - dtime) > INTERVAL '0'
GROUP BY DriverPickups.driver_id,
    DriverPickups.rday,
    dtime;
CREATE VIEW DriverBreaksDay as
SELECT DriverBreaks.rday,
    DriverBreaks.driver_id,
    sum(btime) as btimetotal
FROM DriverBreaks
GROUP BY DriverBreaks.driver_id,
    DriverBreaks.rday;
CREATE VIEW DriverBreaksFull AS
SELECT DriverRequests.driver_id,
    DriverRequests.rday,
    COALESCE(MAX(btime), '0') as btimemax
FROM DriverRequests natural
    left JOIN DriverBreaks
GROUP BY DriverRequests.driver_id,
    DriverRequests.rday;
CREATE VIEW BadDays AS
SELECT DriverBreaksFull.driver_id,
    DriverBreaksFull.rday,
    btimemax,
    driving,
    COALESCE(btimetotal, '0') as btimetotal
FROM DriverBreaksFull natural
    left join DriverDayDuration natural
    left join DriverBreaksDay
WHERE btimemax <= INTERVAL '15 minutes'
    AND driving >= INTERVAL '12 hour';
CREATE VIEW BadDaysConsec AS
SELECT bd1.driver_id,
    bd1.rday as start,
    (bd1.driving + bd2.driving + bd3.driving) as driving,
    (bd1.btimetotal + bd2.btimetotal + bd3.btimetotal) as breaks
FROM BadDays bd1,
    BadDays bd2,
    BadDays bd3
WHERE (bd2.rday - bd1.rday) = INTERVAL '1 day'
    AND (bd3.rday - bd2.rday) = INTERVAL '1 day'
    AND bd1.driver_id = bd2.driver_id
    AND bd2.driver_id = bd3.driver_id;
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT driver_id,
    start,
    driving,
    breaks
from BadDaysConsec;