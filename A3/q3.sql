SET SEARCH_PATH TO ticketchema,
    public;
DROP TABLE IF EXISTS q3 CASCADE;
CREATE TABLE q3(
    venue_name VARCHAR(100),
    -- percentage of accessible Seats
    accessible_percentage INTEGER
);
-- Do this for each of the views that define your intermediate steps.
DROP VIEW IF EXISTS accessible_seats CASCADE;
-- create views
-- accessible seats in each venue
CREATE VIEW accessible_seats AS
SELECT venue_id,
    COUNT(seat_id) as accessible_seats
FROM Seats
    NATURAL JOIN Sections
    NATURAL JOIN Venues
WHERE is_accessible = TRUE
GROUP BY venue_id;
-- total seats in each venue
CREATE VIEW total_seats AS
SELECT venue_id,
    COUNT(seat_id) as total_seats
FROM Seats
    NATURAL JOIN Sections
    NATURAL JOIN Venues
GROUP BY venue_id;
-- insert into q3
INSERT INTO q3
SELECT venue_name,
    ROUND(
        (accessible_seats::float / total_seats::float) * 100
    )
FROM accessible_seats
    NATURAL JOIN total_seats
    NATURAL JOIN Venues;
-- print q3
SELECT *
FROM q3;