"""
Part2 of csc343 A2: Code that could be part of a ride-sharing application.
csc343, Fall 2022
University of Toronto

--------------------------------------------------------------------------------
This file is Copyright (c) 2022 Diane Horton and Marina Tawfik.
All forms of distribution, whether as given or with any changes, are
expressly prohibited.
--------------------------------------------------------------------------------
"""
from operator import ge
from tkinter.messagebox import NO
from zoneinfo import available_timezones
import psycopg2 as pg
import psycopg2.extensions as pg_ext
from typing import Optional, List, Any
from datetime import datetime
import re


class GeoLoc:
    """A geographic location.

    === Instance Attributes ===
    longitude: the angular distance of this GeoLoc, east or west of the prime
        meridian.
    latitude: the angular distance of this GeoLoc, north or south of the
        Earth's equator.

    === Representation Invariants ===
    - longitude is in the closed interval [-180.0, 180.0]
    - latitude is in the closed interval [-90.0, 90.0]

    >>> where = GeoLoc(-25.0, 50.0)
    >>> where.longitude
    -25.0
    >>> where.latitude
    50.0
    """
    longitude: float
    latitude: float

    def __init__(self, longitude: float, latitude: float) -> None:
        """Initialize this geographic location with longitude <longitude> and
        latitude <latitude>.
        """
        self.longitude = longitude
        self.latitude = latitude

        assert -180.0 <= longitude <= 180.0, \
            f"Invalid value for longitude: {longitude}"
        assert -90.0 <= latitude <= 90.0, \
            f"Invalid value for latitude: {latitude}"


class Assignment2:
    """A class that can work with data conforming to the schema in schema.ddl.

    === Instance Attributes ===
    connection: connection to a PostgreSQL database of ride-sharing information.

    Representation invariants:
    - The database to which connection is established conforms to the schema
      in schema.ddl.
    """
    connection: Optional[pg_ext.connection]

    def __init__(self) -> None:
        """Initialize this Assignment2 instance, with no database connection
        yet.
        """
        self.connection = None

    def connect(self, dbname: str, username: str, password: str) -> bool:
        """Establish a connection to the database <dbname> using the
        username <username> and password <password>, and assign it to the
        instance attribute <connection>. In addition, set the search path to
        uber, public.

        Return True if the connection was made successfully, False otherwise.
        I.e., do NOT throw an error if making the connection fails.

        >>> a2 = Assignment2()
        >>> # This example will work for you if you change the arguments as
        >>> # appropriate for your account.
        >>> a2.connect("csc343h-dianeh", "dianeh", "")
        True
        >>> # In this example, the connection cannot be made.
        >>> a2.connect("nonsense", "silly", "junk")
        False
        """
        try:
            self.connection = pg.connect(
                dbname=dbname, user=username, password=password,
                options="-c search_path=uber,public"
            )
            # This allows psycopg2 to learn about our custom type geo_loc.
            self._register_geo_loc()
            return True
        except pg.Error:
            return False

    def disconnect(self) -> bool:
        """Close the database connection.

        Return True if closing the connection was successful, False otherwise.
        I.e., do NOT throw an error if closing the connection failed.

        >>> a2 = Assignment2()
        >>> # This example will work for you if you change the arguments as
        >>> # appropriate for your account.
        >>> a2.connect("csc343h-dianeh", "dianeh", "")
        True
        >>> a2.disconnect()
        True
        >>> a2.disconnect()
        False
        """
        try:
            if not self.connection.closed:
                self.connection.close()
            return True
        except pg.Error:
            return False

    def check_clocked_in(self, driver_id: int | None = None) -> bool | list[str]:
        """
        A) Return True if the driver with driver id <driver_id> is currently
        on an ongoing shift, and False otherwise.
        B) If <driver_id> is None, return list of all drivers who are currently on an ongoing shift.
        """
        cursor = self.connection.cursor()
        template = """
        SELECT  ci.shift_id, 
                ci.datetime as in,
                ci.driver_id, 
                co.datetime as out
        FROM ClockedIn ci, ClockedOut co
        WHERE   ci.shift_id = co.shift_id
        """
        if driver_id is not None:
            template += " AND ci.driver_id = %s"
            cursor.execute(template, (driver_id,))
            all_shift = cursor.fetchall()
            return any([shift[3] is None for shift in all_shift])
        else:
            cursor.execute(template)
            all_shift = cursor.fetchall()
            # Find all drivers who are currently on shift
            return [shift[2] for shift in all_shift if shift[3] is None]

    # ======================= Driver-related methods ======================= #

    def clock_in(self, driver_id: int, when: datetime, geo_loc: GeoLoc) -> bool:
        """Record the fact that the driver with id <driver_id> has declared that
        they are available to start their shift at date time <when> and with
        starting location <geo_loc>. Do so by inserting a row in both the
        ClockedIn and the Location tables.

        If there are no rows are in the ClockedIn table, the id of the shift
        is 1. Otherwise, it is the maximum current shift id + 1.

        A driver can NOT start a new shift if they have an ongoing shift.

        Return True if clocking in was successful, False otherwise. I.e., do NOT
        throw an error if clocking in fails.

        Precondition:
            - <when> is after all dates currently recorded in the database.
        """
        try:
            # TODO: implement this method
            cursor = self.connection.cursor()
            # check if driver_id exists
            cursor.execute("""
            SELECT driver_id From Driver Where driver_id = %s
            """, (driver_id,))
            checkDriver = cursor.fetchone()
            if checkDriver is None:
                return False
            # get max shift id
            cursor.execute("""
            SELECT MAX(shift_id) from ClockedIn
            """)
            shift_id = cursor.fetchone()[0]
            if shift_id is None:
                shift_id = 0
            else:
                shift_id = shift_id + 1
            # check if clocked in
            if self.check_clocked_in(driver_id):
                return False

            # Insert into clocked in
            cursor.execute("""
            INSERT INTO ClockedIn(shift_id, driver_id, datetime) VALUES
            (%s, %s, %s)
            """, (shift_id, driver_id, when))
            cursor.execute("""
            INSERT INTO Location(shift_id, datetime, location) VALUES
            (%s, %s, '(%s, %s)')
            """, (shift_id, when, geo_loc.longitude, geo_loc.latitude))
            cursor.close()
            return True
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            return False

    def pick_up(self, driver_id: int, client_id: int, when: datetime) -> bool:
        """Record the fact that the driver with driver id <driver_id> has
        picked up the client with client id <client_id> at date time <when>.

        If (a) the driver is currently on an ongoing shift, and
           (b) they have been dispatched to pick up the client, and
           (c) the corresponding pick-up has not been recorded
        record it by adding a row to the Pickup table, and return True.
        Otherwise, return False.

        You may not assume that the dispatch actually occurred, but you may
        assume there is no more than one outstanding dispatch entry for this
        driver and this client.

        Return True if the operation was successful, False otherwise. I.e.,
        do NOT throw an error if this pick up fails.

        Precondition:
            - <when> is after all dates currently recorded in the database.
        """
        try:
            # TODO: implement this method
            cursor = self.connection.cursor()
            # check if driver_id exists
            cursor.execute("""
            SELECT driver_id From Driver Where driver_id = %s
            """, (driver_id,))
            checkDriver = cursor.fetchone()
            if checkDriver is None:
                return False
            # check if client_id exists
            cursor.execute("""
            SELECT client_id From Client Where client_id = %s
            """, (client_id,))
            checkClient = cursor.fetchone()
            if checkClient is None:
                return False
            # check a: driver on ongoing shift
            cursor.execute("""
                    CREATE TEMPORARY VIEW shiftOver AS
                    SELECT ClockedIn.shift_id
                    FROM ClockedIn, ClockedOut
                    WHERE ClockedIn.shift_id = ClockedOut.shift_id
            """)
            cursor.execute("""
                    CREATE TEMPORARY VIEW shiftOngoing AS
                    (SELECT shift_id FROM ClockedIn) EXCEPT (SELECT shift_id FROM shiftOver)
            """)
            cursor.execute("""
                    SELECT shift_id, driver_id
                    FROM shiftOngoing NATURAL JOIN ClockedIN
                    WHERE driver_id = %s
                    """, (driver_id,))
            ongoing = cursor.fetchone()
            if ongoing is None:
                return False

            shift_id = ongoing[0]

            # check b: driver dispatched to pick up the client
            cursor.execute("""
                    SELECT Request.request_id, client_id
                    FROM Request, Dispatch
                    WHERE Request.request_id = Dispatch.request_id
                    AND client_id = %s AND shift_id = %s
                    """, (client_id, shift_id,))

            dispatching = cursor.fetchone()
            if dispatching is None:
                return False
            # DO WE NEED TO CALL DISPATCH? PRECONDITIONS?

            request_id = dispatching[0]

            # check c: pick-up not recorded
            cursor.execute("""
                    SELECT *
                    FROM Pickup
                    WHERE request_id = %s
                    """, (request_id))

            notpicked = cursor.fetchone()
            if notpicked is not None:
                return False

            # insert
            cursor.execute("""
                    INSERT INTO Pickup(request_id, datetime) VALUES (%s, %s)
                    """, (request_id, when))

            return True
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            raise ex
            return False

    # ===================== Dispatcher-related methods ===================== #

    def dispatch(self, nw: GeoLoc, se: GeoLoc, when: datetime) -> None:
        """Dispatch drivers to the clients who have requested rides in the area
        bounded by <nw> and <se>, such that:
            - <nw> is the longitude and latitude in the northwest corner of this
            area
            - <se> is the longitude and latitude in the southeast corner of this
            area
        and record the dispatch time as <when>.

        Area boundaries are inclusive. For example, the point (4.0, 10.0)
        is considered within the area defined by
                    NW = (1.0, 10.0) and SE = (25.0, 2.0)
        even though it is right at the upper boundary of the area.

        NOTE: + longitude values decrease as we move further west, and
                latitude values decrease as we move further south.
              + You may find the PostgreSQL operators @> and <@> helpful.

        For all clients who have requested rides in this area (i.e., whose
        request has a source location in this area) and a driver has not
        been dispatched to them yet, dispatch drivers to them one at a time,
        from the client with the highest total billings down to the client
        with the lowest total billings, or until there are no more drivers
        available.

        Only drivers who meet all of these conditions are dispatched:
            (a) They are currently on an ongoing shift.
            (b) They are available and are NOT currently dispatched or on
            an ongoing ride.
            (c) Their most recent recorded location is in the area bounded by
            <nw> and <se>.
        When choosing a driver for a particular client, if there are several
        drivers to choose from, choose the one closest to the client's source
        location. In the case of a tie, any one of the tied drivers may be
        dispatched.

        Dispatching a driver is accomplished by adding a row to the Dispatch
        table. The dispatch car location is the driver's most recent recorded
        location. All dispatching that results from a call to this method is
        recorded to have happened at the same time, which is passed through
        parameter <when>.

        If an exception occurs during dispatch, rollback ALL changes.

        Precondition:
            - <when> is after all dates currently recorded in the database.
        """
        try:
            # Find all clients who have requested rides in this area
            cursor = self.connection.cursor()
            cursor.execute("""
            CREATE TEMPORARY VIEW clients_in_area_no_dispatch AS
            SELECT  client_id, source, destination, request_id
            FROM Client Natural Join Request
            WHERE   source[0] > %s AND
                    source[1] > %s AND
                    source[0] < %s AND
                    source[1] < %s AND
                    Request.request_id NOT IN (SELECT request_id FROM Dispatch);
            """, (nw.longitude, nw.latitude, se.longitude, se.latitude))
            cursor.execute("""
            CREATE TEMPORARY VIEW clent_total_billings AS
            SELECT  client_id, sum(amount) as total_billings
            FROM Client Natural Join Request Natural Join Billed
            GROUP BY client_id
            ORDER BY total_billings DESC;


            CREATE TEMPORARY VIEW clients_in_area_no_dispatch_ordered AS
            SELECT  client_id, source, total_billings, request_id
            FROM clients_in_area_no_dispatch NATURAL JOIN client_total_billings
            ORDER BY total_billings DESC;
            """)

            cursor.execute("""
            SELECT * from clients_in_area_no_dispatch_ordered;
            """)
            clients = cursor.fetchall()

            # Find all drivers who are currently on an ongoing shift
            cursor.execute("""
            CREATE TEMPORARY VIEW shiftOver AS
            SELECT shift_id
            FROM ClockedIn, ClockedOut
            WHERE ClockedIn.shift_id = ClockedOut.shift_id;

            CREATE TEMPORARY VIEW shiftOngoing AS
            (SELECT shift_id FROM ClockedIn) EXCEPT (SELECT shift_id FROM shiftOver);
            CREATE TEMPORARY VIEW driverOngoing AS
            SELECT shift_id, driver_id
            FROM shiftOngoing NATURAL JOIN ClockedIN
            """)
            # Find all drivers who are available and are NOT currently
            # dispatched or on an ongoing ride
            cursor.execute("""
            CREATE TEMPORARY VIEW driver_times AS
            SELECT  driver_id, 
                    Dispatch.datetime as dt, 
                    Pickup.datetime as pt, 
                    Dropoff.datetime as dot
            FROM ClockedIn, Request, Dispatch, Pickup, Dropoff
            WHERE   ClockedIn.shift_id = Dispatch.shift_id AND
                    Dispatch.request_id = Pickup.request_id AND
                    Pickup.request_id = Dropoff.request_id AND
            """)
            cursor.execute("""
            CREATE TEMPORARY VIEW no_free_drivers AS
            SELECT  driver_id
            FROM driver_times
            WHERE   dt  IS NULL OR
                    pt  IS NULL OR
                    dot IS NULL OR
            """)

            # Find all drivers whose most recent recorded location is in the
            # area bounded by <nw> and <se>
            cursor.execute("""
            CREATE TEMPORARY VIEW driver_recent_locations AS
            SELECT  driver_id, MAX(datetime) dt
            FROM Location
            GROUP BY driver_id
            """)
            cursor.execute("""
            CREATE TEMPORARY VIEW driver_nearby_locations AS
            SELECT  driver_id, location
            FROM Location l1
            WHERE   datetime = (
                SELECT dt FROM driver_recent_locations
                WHERE driver_id = l1.driver_id
                ) AND
                    location[0] > %s AND
                    location[1] > %s AND
                    location[0] < %s AND
                    location[1] < %s '
            """, (nw.longitude, nw.latitude, se.longitude, se.latitude))

            cursor.execute("""
            CREATE TEMPORARY VIEW driver_nearby AS
            SELECT  driver_id, location, shift_id
            FROM driver_nearby_locations NATURE JOIN driverOngoing
            WHERE driver_id NOT IN (SELECT driver_id FROM no_free_drivers)
            """)

            # Dispatch drivers to clients one at a time, from the client with
            # the highest total billings down to the client with the lowest
            # total billings, or until there are no more drivers available.
            for client in clients:
                # Find the closest driver to the client's source location
                cursor.execute("""
                SELECT  driver_id, source <@> location as distance, location
                FROM clients_in_area_no_dispatch_ordered, driver_nearby
                WHERE   client_id = %s AND
                order by distance ASC
                """, (client[0],))
                driver = cursor.fetchone()
                if driver is None:
                    break
                else:
                    driver = driver[0]
                    # Dispatch the driver to the client
                    cursor.execute("""
                    INSERT INTO Dispatch(request_id, shift_id, car_location, datetime) 
                    VALUES
                    (%s, %s, '(%s, %s)', %s)
                    """, (client[3], driver[2], driver[1][0], driver[1][1], when))
                    # Remove the driver from the list of available drivers
                    cursor.execute("""
                    DELETE FROM driver_nearby
                    WHERE driver_id = %s
                    """, (driver[0],))
            cursor.close()
            return True
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            raise ex
            return

    # =======================     Helper methods     ======================= #

    # You do not need to understand this code. See the doctest example in
    # class GeoLoc (look for ">>>") for how to use class GeoLoc.

    def _register_geo_loc(self) -> None:
        """Register the GeoLoc type and create the GeoLoc type adapter.

        This method
            (1) informs psycopg2 that the Python class GeoLoc corresponds
                to geo_loc in PostgreSQL.
            (2) defines the logic for quoting GeoLoc objects so that you
                can use GeoLoc objects in calls to execute.
            (3) defines the logic of reading GeoLoc objects from PostgreSQL.

        DO NOT make any modifications to this method.
        """

        def adapt_geo_loc(loc: GeoLoc) -> pg_ext.AsIs:
            """Convert the given geographical location <loc> to a quoted
            SQL string.
            """
            longitude = pg_ext.adapt(loc.longitude)
            latitude = pg_ext.adapt(loc.latitude)
            return pg_ext.AsIs(f"'({longitude}, {latitude})'::geo_loc")

        def cast_geo_loc(value: Optional[str], *args: List[Any]) \
                -> Optional[GeoLoc]:
            """Convert the given value <value> to a GeoLoc object.

            Throw an InterfaceError if the given value can't be converted to
            a GeoLoc object.
            """
            if value is None:
                return None
            m = re.match(r"\(([^)]+),([^)]+)\)", value)

            if m:
                return GeoLoc(float(m.group(1)), float(m.group(2)))
            else:
                raise pg.InterfaceError(f"bad geo_loc representation: {value}")

        with self.connection, self.connection.cursor() as cursor:
            cursor.execute("SELECT NULL::geo_loc")
            geo_loc_oid = cursor.description[0][1]

            geo_loc_type = pg_ext.new_type(
                (geo_loc_oid,), "GeoLoc", cast_geo_loc
            )
            pg_ext.register_type(geo_loc_type)
            pg_ext.register_adapter(GeoLoc, adapt_geo_loc)


def sample_test_function() -> None:
    """A sample test function."""
    a2 = Assignment2()
    try:
        import os
        user = os.getlogin()
        # TODO: Change this to connect to your own database:
        connected = a2.connect(f"csc343h-{user}", user, "")
        print(f"[Connected] Expected True | Got {connected}.")

        # TODO: Test one or more methods here, or better yet, make more testing
        #   functions, with each testing a different aspect of the code.

        # ------------------- Testing Clocked In -----------------------------#

        # These tests assume that you have already loaded the sample data we
        # provided into your database.

        # This driver doesn't exist in db
        # clocked_in = a2.clock_in(
        #     989898, datetime.now(), GeoLoc(-79.233, 43.712)
        # )
        # print(f"[ClockIn] Expected False | Got {clocked_in}.")

        # This drive does exist in the db
        clocked_in = a2.clock_in(
            22222, datetime.now(), GeoLoc(-79.233, 43.712)
        )
        print(f"[ClockIn] Expected True | Got {clocked_in}.")

        # Same driver clocks in again
        # clocked_in = a2.clock_in(
        #     22222, datetime.now(), GeoLoc(-79.233, 43.712)
        # )
        # print(f"[ClockIn] Expected False | Got {clocked_in}.")

    finally:
        a2.disconnect()


if __name__ == "__main__":
    # Un comment-out the next two lines if you would like all the doctest
    # examples (see ">>>" in the method and class docstrings) to be run
    # and checked.
    # import doctest
    # doctest.testmod()

    # TODO: Put your testing code here, or call testing functions such as
    #   this one:
    sample_test_function()
