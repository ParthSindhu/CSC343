SET SEARCH_PATH TO ticketchema,
    public;
DROP TABLE IF EXISTS q1 CASCADE;
-- Percentage of seats sold for concert , each date is treated as separate concert
CREATE TABLE q1(
    consert_name VARCHAR(100),
    concert_date DATE,
    -- total amount sold , float value
    amount_sold FLOAT,
    sold_percentage INTEGER
);
-- Do this for each of the views that define your intermediate steps.  
DROP VIEW IF EXISTS concert_sales CASCADE;
DROP VIEW IF EXISTS concert_prices CASCADE;
DROP VIEW IF EXISTS concert_data CASCADE;
-- Define views for your intermediate steps here:
-- names and dates of concerts with their instance ids
CREATE VIEW concert_data AS
SELECT concert_instance_id,
    concert_id,
    concert_date,
    concert_name
FROM ConcertDates
    NATURAL JOIN Concerts;
-- prices of concerts with their instance ids
CREATE VIEW concert_prices AS
SELECT concert_instance_id,
    concert_name,
    concert_date,
    price,
    seat_id
FROM Seats
    NATURAL JOIN concert_data
    NATURAL JOIN Prices;
-- sales of concerts grouped by concert instance id along with their names and dates
CREATE VIEW concert_sales AS
SELECT concert_instance_id,
    concert_name,
    concert_date,
    SUM(price) as amount_sold,
    COUNT(seat_id) as seats_sold
FROM concert_prices
    NATURAL JOIN Purchases
GROUP BY concert_instance_id,
    concert_name,
    concert_date;
-- total number of seats in each concert
CREATE VIEW concert_seats AS
SELECT concert_instance_id,
    COUNT(seat_id) as seats_available
FROM concert_prices
GROUP BY concert_instance_id;
-- insert into q1
INSERT INTO q1
SELECT concert_name,
    concert_date,
    amount_sold,
    ROUND(
        (seats_sold::float / seats_available::float) * 100
    ) as sold_percentage
FROM concert_sales
    NATURAL JOIN concert_seats;
-- print q1
SELECT *
FROM q1;