SET SEARCH_PATH TO ticketchema,
    public;
DROP TABLE IF EXISTS q1 CASCADE;
CREATE TABLE q1(
    consert_name VARCHAR(100),
    concert_date DATE,
    -- total amount sold , float value
    amount_sold FLOAT,
    sold_percentage INTEGER
);
-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS concert_sales CASCADE;
DROP VIEW IF EXISTS concert_prices CASCADE;
DROP VIEW IF EXISTS concert_data CASCADE;
-- Define views for your intermediate steps here:
CREATE VIEW concert_data AS
SELECT concert_instance_id,
    concert_id,
    concert_date,
    concert_name
FROM concert_dates
    NATURAL JOIN concerts;
CREATE VIEW concert_prices AS
SELECT concert_instance_id,
    concert_name,
    concert_date,
    price,
    seat_id
FROM seats
    NATURAL JOIN concert_data
    NATURAL JOIN prices;
CREATE VIEW concert_sales AS
SELECT concert_instance_id,
    concert_name,
    concert_date,
    SUM(price) as amount_sold,
    COUNT(seat_id) as seats_sold
FROM concert_prices
    NATURAL JOIN purchases
GROUP BY concert_instance_id,
    concert_name,
    concert_date;
CREATE VIEW concert_seats AS
SELECT concert_instance_id,
    COUNT(seat_id) as seats_available
FROM concert_prices
GROUP BY concert_instance_id;
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
SELECT concert_name,
    concert_date,
    amount_sold,
    ROUND(
        (seats_sold::float / seats_available::float) * 100
    ) as sold_percentage
FROM concert_sales
    NATURAL JOIN concert_seats;