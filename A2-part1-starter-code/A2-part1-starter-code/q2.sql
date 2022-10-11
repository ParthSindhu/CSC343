-- Lure them back.
-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber,
	public;
DROP TABLE IF EXISTS q2 CASCADE;
CREATE TABLE q2(
	client_id INTEGER,
	name VARCHAR(41),
	email VARCHAR(30),
	billed FLOAT,
	decline INTEGER
);
-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS ReqToDrop CASCADE;
DROP VIEW IF EXISTS RidesPre2020 CASCADE;
DROP VIEW IF EXISTS RidesIn2020 CASCADE;
DROP VIEW IF EXISTS RidesIn2021 CASCADE;
DROP VIEW IF EXISTS LessRidesIn2021 CASCADE;
DROP VIEW IF EXISTS formatedClient CASCADE;
-- Define views for your intermediate steps here:
CREATE VIEW ReqToDrop AS
SELECT client_id,
	Request.request_id,
	EXTRACT(
		YEAR
		FROM Request.datetime
	) as year
FROM Request,
	Dispatch,
	Pickup,
	Dropoff
WHERE Request.request_id = Dispatch.request_id
	AND Pickup.request_id = Dropoff.request_id
	AND Dispatch.request_id = Pickup.request_id;
CREATE VIEW RidesPre2020 AS
SELECT client_id,
	sum(amount) as billed
FROM ReqToDrop
	NATURAL JOIN Billed
WHERE year < 2020
GROUP BY client_id
HAVING sum(amount) > 500;
CREATE VIEW RidesIn2020 AS
SELECT client_id,
	count(year) as ridesNum2020
FROM ReqToDrop
WHERE year = 2020
GROUP BY client_id
HAVING count(year) <= 10
	AND count(year) >= 1;
CREATE VIEW RidesIn2021 AS
SELECT client_id,
	count(year) as ridesNum2021
FROM ReqToDrop
WHERE year = 2021
GROUP BY client_id;
CREATE VIEW LessRidesIn2021 AS
SELECT client_id,
	(ridesNum2021 - ridesNum2020) AS decline
FROM RidesIn2020
	NATURAL JOIN RidesIn2021
WHERE ridesNum2020 - ridesNum2021 > 0;
CREATE VIEW formatedClient AS
SELECT client_id,
	CONCAT(firstname, ' ', surname) AS name,
	COALESCE(email, 'unknown') as email
FROM Client;
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
SELECT client_id,
	name,
	email,
	billed,
	decline
FROM RidesPre2020
	NATURAL JOIN LessRidesIn2021
	NATURAL JOIN formatedClient;
