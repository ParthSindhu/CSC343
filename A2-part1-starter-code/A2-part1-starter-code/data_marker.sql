SET SEARCH_PATH TO uber,
	public;
TRUNCATE Client,
Driver,
Pickup,
Dropoff,
Dispatch,
Request,
ClockedIn CASCADE;
INSERT INTO Client(client_id, surname, firstname, email)
VALUES (
		'1',
		'Client 0',
		'Clone',
		'driveme@cs.toronto.edu'
	);
INSERT INTO Driver(
		driver_id,
		surname,
		firstname,
		dob,
		address,
		vehicle,
		trained
	)
VALUES (
		'1',
		'Driver 0',
		'Clone',
		'January 1, 1980',
		'0 Bahen Street',
		'ABCD 007',
		'True'
	);
INSERT INTO ClockedIn(shift_id, driver_id, datetime)
VALUES ('1', '1', '2020-11-02 02:06'),
	('2', '1', '2020-11-03 02:06'),
	('3', '1', '2020-11-04 02:06');
INSERT INTO Location(shift_id, datetime, location)
VALUES -- Shift 1
	(1, '2019-07-01 07:55', '(-79.3871, 43.6426)'),
	(1, '2019-07-01 08:22', '(-79.575, 43.6701)'),
	(1, '2019-07-01 11:22', '(-79.5058, 43.7181)'),
	-- Shift 2
	(2, '2020-02-01 06:00', '(0.6167, 51.2629)'),
	(2, '2020-02-01 07:30', '(0.4579, 51.2983)'),
	(2, '2020-02-01 07:45', '(0.3623, 51.3455)'),
	(2, '2020-02-01 09:00', '(-0.6361, 51.369)'),
	(2, '2020-02-01 10:20', '(-1.3605, 51.3267)'),
	(2, '2020-02-01 19:00', '(0.45017, 51.3309)'),
	(2, '2020-02-01 20:12', '(0.654, 51.2459)'),
	-- Shift 3
	(3, '2020-02-03 07:45', '(0.4094, 51.397)'),
	-- Shift 4
	(4, '2020-02-03 13:22', '(-1.33376, 51.344)'),
	(4, '2020-02-03 14:13', '(-1.3166, 51.3724)'),
	-- Shift 5
	(5, '2021-01-08 16:00', '(-79.378, 43.656)'),
	(5, '2021-01-08 16:30', '(-79.408, 43.637)'),
	(5, '2021-01-08 17:30', '(-79.6306, 43.6767)'),
	(5, '2021-01-08 18:40', '(-79.6582, 43.6634)'),
	(5, '2021-01-08 23:00', '(-79.4082, 43.6665)'),
	-- Shift 6
	(6, '2022-07-01 07:55', '(0.4578, 51.374)'),
	(6, '2022-07-01 09:10', '(-0.504, 51.481)'),
	(6, '2022-07-01 13:03', '(-0.4496, 51.4696)'),
	-- Shift 7
	(7, '2022-07-02 11:10', '(-79.6306, 43.6767)'),
	-- Shift 8
	(8, '2022-07-03 11:55', '(-79.4160, 43.723)'),
	(8, '2022-07-03 13:00', '(-79.3784, 43.672)');
INSERT INTO ClockedOut(shift_id, datetime)
VALUES (1, '2019-07-01 23:00'),
	(2, '2020-02-02 00:05'),
	(3, '2020-02-03 12:15'),
	(4, '2020-02-03 15:43'),
	(5, '2021-01-08 23:15'),
	(6, '2022-07-01 14:00'),
	(7, '2022-07-02 15:10'),
	(8, '2022-07-03 15:42');
INSERT INTO Request(
		request_id,
		client_id,
		datetime,
		source,
		destination
	)
VALUES (
		'1',
		'1',
		'2020-11-02 02:07',
		'(21.231, -12.123)',
		'(21.24, -12.143012)'
	),
	(
		'2',
		'1',
		'2020-11-03 02:07',
		'(21.231, -12.123)',
		'(21.24, -12.143012)'
	),
	(
		'3',
		'1',
		'2020-11-04 02:07',
		'(21.231, -12.123)',
		'(21.24, -12.143012)'
	);
INSERT INTO Dispatch(request_id, shift_id, car_location, datetime)
VALUES (
		'1',
		'1',
		'(21.231, -12.123)',
		'2020-11-02 02:11'
	),
	(
		'2',
		'2',
		'(21.231, -12.123)',
		'2020-11-03 02:11'
	),
	(
		'3',
		'3',
		'(21.231, -12.123)',
		'2020-11-04 02:11'
	);
INSERT INTO Pickup(request_id, datetime)
VALUES ('1', '2020-11-02 02:16'),
	('2', '2020-11-03 02:16'),
	('3', '2020-11-04 02:16');
INSERT INTO Dropoff(request_id, datetime)
VALUES ('1', '2020-11-02 15:30'),
	('2', '2020-11-03 14:30'),
	('3', '2020-11-04 16:30');
INSERT INTO Rates(base, per_mile)
VALUES (3.2,.55);
INSERT INTO Billed(request_id, amount)
VALUES (1, 14.1),
	(2, 65.35),
	(3, 62.6),
	(4, 59.3),
	(5, 14.95),
	(6, 40.44),
	(7, 14.75),
	(8, 4.05);
INSERT INTO DriverRating(request_id, rating)
VALUES (1, 1),
	(3, 4),
	(5, 5),
	(8, 5);
INSERT INTO ClientRating(request_id, rating)
VALUES (3, 3),
	(5, 4),
	(7, 3),
	(8, 5);