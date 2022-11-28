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