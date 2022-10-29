-- Rainmakers.
-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber,
    public;
DROP TABLE IF EXISTS q10 CASCADE;
CREATE TABLE q10(
    driver_id INTEGER,
    month CHAR(2),
    mileage_2020 FLOAT,
    billings_2020 FLOAT,
    mileage_2021 FLOAT,
    billings_2021 FLOAT,
    mileage_increase FLOAT,
    billings_increase FLOAT
);
-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS DriverRequest CASCADE;
DROP VIEW IF EXISTS DriverBills CASCADE;
DROP VIEW IF EXISTS Driver20 CASCADE;
DROP VIEW IF EXISTS Driver21 CASCADE;
DROP VIEW IF EXISTS DriverAll CASCADE;
DROP VIEW IF EXISTS AllDrivers CASCADE;
DROP VIEW IF EXISTS Months CASCADE;
-- Define views for your intermediate steps here:
CREATE VIEW DriverRequest AS
SELECT ClockedIn.driver_id,
    CAST(to_char(Request.datetime, 'MM') AS CHAR(2)) as month,
    to_char(Request.datetime, 'YY') as year,
    Request.request_id,
    source <@ > destination as mileage
FROM Request,
    Dispatch,
    ClockedIn
WHERE Request.request_id = Dispatch.request_id
    AND Dispatch.shift_id = ClockedIn.shift_id;
CREATE VIEW DriverBills AS
SELECT driver_id,
    month,
    year,
    request_id,
    amount,
    mileage
FROM DriverRequest
    NATURAL JOIN Billed;
CREATE VIEW Driver20 AS
SELECT driver_id,
    month,
    sum(mileage) as mileage_2020,
    sum(amount) as billings_2020
FROM DriverBills
WHERE year = '20'
GROUP BY driver_id,
    month;
CREATE VIEW Driver21 AS
SELECT driver_id,
    month,
    sum(mileage) as mileage_2021,
    sum(amount) as billings_2021
FROM DriverBills
WHERE year = '21'
GROUP BY driver_id,
    month;
CREATE VIEW Months AS
SELECT CAST(
        TRIM(to_char(generate_series(1, 12), 'FM09')) AS CHAR(2)
    ) AS month;
CREATE View AllDrivers AS
SELECT driver_id,
    month
FROM Driver,
    Months;
CREATE View DriverAll As
SELECT COALESCE(
        Driver21.driver_id,
        Driver20.driver_id,
        AllDrivers.driver_id
    ) AS driver_id,
    COALESCE(Driver21.month, Driver20.month, AllDrivers.month) AS month,
    COALESCE(mileage_2020, 0) as mileage_2020,
    COALESCE(billings_2020, 0) as billings_2020,
    COALESCE(mileage_2021, 0) as mileage_2021,
    COALESCE(billings_2021, 0) as billings_2021
FROM AllDrivers Natural
    FULL join Driver20 NATURAL
    FULL JOIN Driver21;
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q10
SELECT driver_id,
    month,
    mileage_2020,
    billings_2020,
    mileage_2021,
    billings_2021,
    mileage_2021 - mileage_2020 as mileage_increase,
    billings_2021 - billings_2020 as billings_increase
FROM DriverAll;