SET SEARCH_PATH TO ticketchema,
    public;
DROP TABLE IF EXISTS q1 CASCADE;
CREATE TABLE q2(
    owner_name VARCHAR(100),
    venues_owned INTEGER
);
-- Do this for each of the views that define your intermediate steps.
DROP VIEW IF EXISTS owner_venues CASCADE;
-- create views
CREATE VIEW owner_venues AS
SELECT owner_id,
    owner_name,
    venue_id
FROM owners
    NATURAL JOIN venues;
-- insert into q2
INSERT INTO q2
SELECT owner_name,
    COUNT(venue_id)
FROM owner_venues
GROUP BY owner_name;