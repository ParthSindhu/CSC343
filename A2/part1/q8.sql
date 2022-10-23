-- Scratching backs?

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q8 CASCADE;

CREATE TABLE q8(
    client_id INTEGER,
    reciprocals INTEGER,
    difference FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS mutual CASCADE;
DROP VIEW IF EXISTS recNum CASCADE; 

-- Define views for your intermediate steps here:
CREATE VIEW mutual AS
SELECT Request.request_id, driver_id, client_id, DriverRating.rating as DRate, ClientRating.rating as CRate
FROM DriverRating, ClientRating, Request, Dispatch, ClockedIn
WHERE DriverRating.request_id = ClientRating.request_id AND ClientRating.request_id = Request.request_id AND Request.request_id = Dispatch.request_id AND ClockedIn.shift_id = Dispatch.shift_id;

CREATE VIEW recNum AS
SELECT client_id, count(client_id) as reciprocals, avg(DRate - CRate) as difference
FROM mutual
GROUP BY client_id;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q8
SELECT *
FROM recNum;
