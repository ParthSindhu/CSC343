DROP VIEW IF EXISTS clients_in_area_no_dispatch CASCADE;
DROP VIEW IF EXISTS client_total_billings CASCADE;
DROP VIEW IF EXISTS clients_in_area_no_dispatch_ordered CASCADE;
DROP VIEW IF EXISTS shiftOver CASCADE;
DROP VIEW IF EXISTS shiftOngoing CASCADE;
DROP VIEW IF EXISTS driverOngoing CASCADE;
DROP VIEW IF EXISTS driver_nearby CASCADE;
DROP VIEW IF EXISTS driver_nearby_locations CASCADE;
DROP VIEW IF EXISTS driver_recent_locations CASCADE;
DROP VIEW IF EXISTS no_free_drivers CASCADE;
DROP VIEW IF EXISTS driver_times CASCADE;
CREATE VIEW clients_in_area_no_dispatch AS
SELECT client_id,
    source,
    destination,
    request_id
FROM Client
    Natural Join Request
WHERE source [0] > -21.5
    AND source [1] > 44.5
    AND source [0] < -20
    AND source [1] < 48.5
    AND Request.request_id NOT IN (
        SELECT request_id
        FROM Dispatch
    );
CREATE VIEW client_total_billings AS
SELECT client_id,
    sum(amount) as total_billings
FROM Client
    Natural Join Request
    Natural Join Billed
GROUP BY client_id
ORDER BY total_billings DESC;
CREATE VIEW clients_in_area_no_dispatch_ordered AS
SELECT client_id,
    source,
    total_billings,
    request_id
FROM clients_in_area_no_dispatch
    NATURAL JOIN client_total_billings
ORDER BY total_billings DESC;
SELECT *
from clients_in_area_no_dispatch_ordered;
CREATE VIEW shiftOver AS
SELECT ClockedIn.shift_id
FROM ClockedIn,
    ClockedOut
WHERE ClockedIn.shift_id = ClockedOut.shift_id;
CREATE VIEW shiftOngoing AS (
    SELECT shift_id
    FROM ClockedIn
)
EXCEPT (
        SELECT shift_id
        FROM shiftOver
    );
CREATE VIEW driverOngoing AS
SELECT shift_id,
    driver_id
FROM shiftOngoing
    NATURAL JOIN ClockedIN;
CREATE VIEW driver_times AS
SELECT driver_id,
    Dispatch.datetime as dt,
    Pickup.datetime as pt,
    Dropoff.datetime as dot
FROM ClockedIn,
    Request,
    Dispatch,
    Pickup,
    Dropoff
WHERE ClockedIn.shift_id = Dispatch.shift_id
    AND Dispatch.request_id = Pickup.request_id
    AND Pickup.request_id = Dropoff.request_id;
CREATE VIEW no_free_drivers AS
SELECT driver_id
FROM driver_times
WHERE dt IS NULL
    OR pt IS NULL
    OR dot IS NULL;
CREATE VIEW driver_recent_locations AS
SELECT driver_id,
    MAX(Location.datetime) dt
FROM Location,
    ClockedIn
WHERE Location.shift_id = ClockedIn.shift_id
GROUP BY driver_id;
CREATE VIEW driver_nearby_locations AS
SELECT c.driver_id,
    location
FROM Location l1,
    ClockedIn c
WHERE l1.shift_id = c.shift_id
    AND l1.datetime = (
        SELECT dt
        FROM driver_recent_locations
        WHERE driver_id = c.driver_id
    )
    AND location [0] > -21.5
    AND location [1] > 44.5
    AND location [0] < -20.0
    AND location [1] < 48.5;
CREATE VIEW driver_nearby AS
SELECT driver_id,
    location,
    shift_id
FROM driver_nearby_locations
    NATURAL JOIN driverOngoing
WHERE driver_id NOT IN (
        SELECT driver_id
        FROM no_free_drivers
    );