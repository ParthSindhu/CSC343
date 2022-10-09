-- Months.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    client_id INTEGER,
    email VARCHAR(30),
    months INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS ReqToDrop CASCADE;


-- Define views for your intermediate steps here:
-- Define views for your intermediate steps here:
CREATE VIEW ReqToDrop AS 
SELECT DISTINCT client_id, count(DISTINCT date_trunc('month', Request.datetime) ) AS monthCount
FROM Request, Dispatch, Pickup, Dropoff
WHERE Request.request_id = Dispatch.request_id AND Pickup.request_id = Dropoff.request_id AND Dispatch.request_id = Pickup.request_id
GROUP BY client_id;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
SELECT client_id, email, COALESCE(monthCount, 0 )
FROM ReqToDrop NATURAL RIGHT JOIN Client;