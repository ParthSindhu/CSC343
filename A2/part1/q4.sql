-- Do drivers improve?
-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber,
    public;
DROP TABLE IF EXISTS q4 CASCADE;
CREATE TABLE q4(
    type VARCHAR(9),
    number INTEGER,
    early FLOAT,
    late FLOAT
);
-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS DriverDays CASCADE;
DROP VIEW IF EXISTS Driver10Days CASCADE;
DROP VIEW IF EXISTS Driver10DaysTrained CASCADE;
DROP VIEW IF EXISTS Driver10DaysUntrained CASCADE;
DROP VIEW IF EXISTS DriverDayRatings CASCADE;
DROP VIEW IF EXISTS DriverDayRatingsTrainedRanking CASCADE;
DROP VIEW IF EXISTS DriverDayRatingsUntrainedRanking CASCADE;
DROP VIEW IF EXISTS TrainedEarly CASCADE;
DROP VIEW IF EXISTS TrainedLate CASCADE;
DROP VIEW IF EXISTS Trained CASCADE;
DROP VIEW IF EXISTS UntrainedEarly CASCADE;
DROP VIEW IF EXISTS UntrainedLate CASCADE;
DROP VIEW IF EXISTS Untrained CASCADE;
-- Define views for your intermediate steps here:
CREATE VIEW DriverDays AS
SELECT ClockedIn.driver_id,
    date_trunc('day', Request.datetime) as day,
    Request.request_id
FROM Request,
    Dispatch,
    ClockedIn
WHERE Request.request_id = Dispatch.request_id
    AND Dispatch.shift_id = ClockedIn.shift_id;
CREATE VIEW Driver10Days AS
SELECT driver_id
FROM DriverDays
GROUP BY driver_id
HAVING count(DISTINCT day) >= 10;
CREATE VIEW Driver10DaysTrained AS
SELECT driver_id
FROM Driver10Days
    NATURAL JOIN Driver
WHERE trained = TRUE;
CREATE VIEW Driver10DaysUntrained AS
SELECT driver_id
FROM Driver10Days
    NATURAL JOIN Driver
WHERE trained = FALSE;
CREATE VIEW DriverDayRatings AS
SELECT driver_id,
    request_id,
    rating,
    day
FROM DriverRating NATURAL
    right JOIN DriverDays;
CREATE VIEW DriverDayRatingsTrainedRanking AS
SELECT driver_id,
    rating,
    rank() OVER (
        PARTITION BY driver_id
        ORDER BY day
    ) as day_rank
FROM DriverDayRatings NATURAL
    right JOIN Driver10DaysTrained;
CREATE VIEW DriverDayRatingsUntrainedRanking AS
SELECT driver_id,
    rating,
    rank() OVER (
        PARTITION BY driver_id
        ORDER BY day
    ) AS day_rank
FROM DriverDayRatings NATURAL
    right JOIN Driver10DaysUntrained;
CREATE VIEW TrainedEarly AS
SELECT driver_id,
    AVG(rating) as early
FROM DriverDayRatingsTrainedRanking
WHERE day_rank <= 5
GROUP BY driver_id;
CREATE VIEW TrainedLate AS
SELECT driver_id,
    AVG(rating) as late
FROM DriverDayRatingsTrainedRanking
WHERE day_rank > 5
GROUP BY driver_id;
CREATE VIEW Trained AS
SELECT 'trained' as type,
    AVG(early) as early,
    AVG(late) as late,
    (
        SELECT count(driver_id)
        from Driver10DaysTrained
    ) as number
FROM TrainedLate NATURAL
    FULL JOIN TrainedEarly;
CREATE VIEW UntrainedEarly AS
SELECT driver_id,
    AVG(rating) as early
FROM DriverDayRatingsUntrainedRanking
WHERE day_rank <= 5
GROUP BY driver_id;
CREATE VIEW UntrainedLate AS
SELECT driver_id,
    AVG(rating) as late
FROM DriverDayRatingsUntrainedRanking
WHERE day_rank > 5
GROUP BY driver_id;
CREATE VIEW Untrained AS
SELECT 'untrained' as type,
    AVG(early) as early,
    AVG(late) as late,
    (
        SELECT count(driver_id)
        from Driver10DaysUntrained
    ) as number
FROM UntrainedLate NATURAL
    FULL JOIN UntrainedEarly;
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT type,
    number early,
    late
FROM Trained
Union all
SELECT type,
    number early,
    late
FROM Untrained;