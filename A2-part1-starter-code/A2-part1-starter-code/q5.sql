-- Bigger and smaller spenders.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5(
    client_id INTEGER,
    month VARCHAR(7),
    total FLOAT,
    comparison VARCHAR(30)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS fullRide CASCADE;
DROP VIEW IF EXISTS monthRided CASCADE;
DROP VIEW IF EXISTS rideBilled CASCADE;
DROP VIEW IF EXISTS rideBilledByClientPerMonth CASCADE;
DROP VIEW IF EXISTS rideBilledAVG CASCADE;
DROP VIEW IF EXISTS rideBilledComp CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW fullRide AS
SELECT Request.request_id, Request.client_id, CONCAT(EXTRACT(Year From  Request.datetime), ' ', to_char(Request.datetime, 'MM')) as month
FROM Request, Dispatch, Pickup, Dropoff
WHERE Request.request_id = Dispatch.request_id AND Dispatch.request_id = Pickup.request_id AND Pickup.request_id = Dropoff.request_id;

CREATE VIEW monthRided AS
SELECT DISTINCT month
FROM fullRide;

CREATE VIEW rideBilled AS
SELECT fullRide.request_id, client_id, month, amount
FROM fullRide NATURAL JOIN Billed;

CREATE VIEW rideBilledByClientPerMonth AS
SELECT month, client_id, sum(amount) as total
FROM rideBilled
GROUP BY month, client_id;

CREATE VIEW rideBilledAVG AS
SELECT month, avg(amount) as monthavg
FROM rideBilled
GROUP BY month;

CREATE VIEW rideBilledComp AS
SELECT month, client_id, total, CASE WHEN total >= monthavg THEN 'at or above' ELSE 'below' END AS comparison 
FROM rideBilledByClientPerMonth NATURAL FULL JOIN rideBilledAVG;
 

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
SELECT DISTINCT client_id, month, COALESCE(total, 0), COALESCE(comparison, 'below')
FROM rideBilledComp NATURAL FULL JOIN (Client NATURAL FULL JOIN monthRided);
