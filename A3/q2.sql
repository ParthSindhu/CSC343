SET SEARCH_PATH TO ticketchema,
    public;
DROP TABLE IF EXISTS q2 CASCADE;
CREATE TABLE q2(
    owner_name VARCHAR(100),
    Venues_owned INTEGER
);
-- Do this for each of the views that define your intermediate steps.
DROP VIEW IF EXISTS owner_Venues CASCADE;
-- create views
-- Owner and their owned venues
CREATE VIEW owner_Venues AS
SELECT owner_id,
    owner_name,
    venue_id
FROM Owner
    NATURAL JOIN Venues;
-- insert into q2
INSERT INTO q2
SELECT owner_name,
    COUNT(venue_id)
FROM owner_Venues
GROUP BY owner_name;
-- print q2
SELECT *
FROM q2;