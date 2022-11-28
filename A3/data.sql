SET SEARCH_PATH TO uber,
    public;
TRUNCATE TABLE venues,
owners,
seats,
sections,
concerts,
prices,
users,
purchases CASCADE;
-- 
INSERT INTO venues(venue_id, name, city, street, owner_id)
VALUES (
        1,
        'Massey Hall',
        'Toronto',
        '178 Victoria Street',
        1
    ),
    (
        2,
        'Roy Thomson Hall',
        'Toronto',
        '60 Simcoe Street',
        1
    ),
    (
        3,
        'Scotiabank Arena',
        'Toronto',
        '40 Bay Street',
        2
    );
INSERT INTO owners(owner_id, name, phone)
VALUES (
        1,
        'Corporation of Massey Hall and Roy Thomson Hall',
        '4168724255'
    ),
    (
        2,
        'Maple Leaf Sports and Entertainment',
        '4168155980'
    );
INSERT INTO sections(section_id, venue_id, section_name)
VALUES (1, 1, 'floor'),
    (2, 1, 'balocny'),
    (3, 2, 'main hall'),
    (4, 3, '100'),
    (5, 3, '200'),
    (6, 3, '300');
INSERT INTO seats(seat_id, seat, section_id, is_accessible)
VALUES (1, 'A1', 1, true),
    (2, 'A2', 1, true),
    (3, 'A3', 1, true),
    (4, 'A4', 1, false),
    (5, 'A5', 1, false),
    (6, 'A6', 1, false),
    (7, 'A7', 1, false),
    (8, 'A8', 1, true),
    (9, 'A9', 1, true),
    (10, 'A10', 1, true),
    (11, 'B1', 1, false),
    (12, 'B2', 1, false),
    (13, 'B3', 1, false),
    (14, 'B4', 1, false),
    (15, 'B5', 1, false),
    (16, 'B6', 1, false),
    (17, 'B7', 1, false),
    (18, 'B8', 1, false),
    (19, 'B9', 1, false),
    (20, 'B10', 1, false),
    -- balcony has seats C1 to C5, not accessible
    (21, 'C1', 2, false),
    (22, 'C2', 2, false),
    (23, 'C3', 2, false),
    (24, 'C4', 2, false),
    (25, 'C5', 2, false),
    -- main hall has seats AA1 to AA3, not accessible
    (26, 'Aa1', 3, false),
    (27, 'AA2', 3, false),
    (28, 'AA3', 3, false),
    -- main hall has seats BB1 to BB8, not accessible
    (29, 'BB1', 3, false),
    (30, 'BB2', 3, false),
    (31, 'BB3', 3, false),
    (32, 'BB4', 3, false),
    (33, 'BB5', 3, false),
    (34, 'BB6', 3, false),
    (35, 'BB7', 3, false),
    (36, 'BB8', 3, false),
    -- main hall has seats CC1 to CC10, not accessible
    (37, 'CC1', 3, false),
    (38, 'CC2', 3, false),
    (39, 'CC3', 3, false),
    (40, 'CC4', 3, false),
    (41, 'CC5', 3, false),
    (42, 'CC6', 3, false),
    (43, 'CC7', 3, false),
    (44, 'CC8', 3, false),
    (45, 'CC9', 3, false),
    (46, 'CC10', 3, false),
    -- sections "100", "200", and "300"
    -- each section has seats "row 1, seat 1" through "row 1, seat 5" and "row 2, seat 1" through "row 2, seat 5"
    -- all of section "100" is accessible.
    (47, 'row 1 seat 1', 4, true),
    (48, 'row 1 seat 2', 4, true),
    (49, 'row 1 seat 3', 4, true),
    (50, 'row 1 seat 4', 4, true),
    (51, 'row 1 seat 5', 4, true),
    (52, 'row 2 seat 1', 4, true),
    (53, 'row 2 seat 2', 4, true),
    (54, 'row 2 seat 3', 4, true),
    (55, 'row 2 seat 4', 4, true),
    (56, 'row 2 seat 5', 4, true),
    -- all of section "200" is not accessible.
    (57, 'row 1 seat 1', 5, false),
    (58, 'row 1 seat 2', 5, false),
    (59, 'row 1 seat 3', 5, false),
    (60, 'row 1 seat 4', 5, false),
    (61, 'row 1 seat 5', 5, false),
    (62, 'row 2 seat 1', 5, false),
    (63, 'row 2 seat 2', 5, false),
    (64, 'row 2 seat 3', 5, false),
    (65, 'row 2 seat 4', 5, false),
    (66, 'row 2 seat 5', 5, false),
    -- all of section 300 is not accesible
    (67, 'row 1 seat 1', 6, false),
    (68, 'row 1 seat 2', 6, false),
    (69, 'row 1 seat 3', 6, false),
    (70, 'row 1 seat 4', 6, false),
    (71, 'row 1 seat 5', 6, false),
    (72, 'row 2 seat 1', 6, false),
    (73, 'row 2 seat 2', 6, false),
    (74, 'row 2 seat 3', 6, false),
    (75, 'row 2 seat 4', 6, false),
    (76, 'row 2 seat 5', 6, false);
INSERT INTO concerts(concert_id, concert_name)
VALUES (1, 'Ron Sexsmith'),
    (2, "Women's Blues Review"),
    (3, 'Mariah Carey - Merry Christmas to all'),
    (4, 'TSO - Elf in Concert');
-- Ron Sexsmith is playing Massey Hall on Saturday, December 3rd, at 7:30pm.
-- Women's Blues Review is at Massey on Friday, November 25th, at 8:00pm.
INSERT INTO concert_dates(
        concert_instance_id,
        concert_id,
        venue_id,
        concert_date
    )
VALUES (1, 1, 1, '2022-12-03 19:30:00'),
    (
        2,
        2,
        1,
        '2022-11-25 20:00:00'
    ),
    -- Mariah Carey - Merry Christmas to all is on at the ScotiaBank Arena on Friday, December 9th and Sunday, December 11th, both at 8:00pm. 
    (
        3,
        3,
        3,
        '2022-12-09 20:00:00'
    ),
    (
        4,
        3,
        3,
        '2022-12-11 20:00:00'
    ),
    -- TSO - Elf in Concert is on at Roy Thompson Hall on Friday December 9th at 7:30 pm and on Saturday, December 10th at 2:30pm and 7:30 pm.
    (
        5,
        4,
        2,
        '2022-12-09 19:30:00'
    ),
    (
        6,
        4,
        2,
        '2022-12-10 14:30:00'
    ),
    (
        7,
        4,
        2,
        '2022-12-10 19:30:00'
    );
-- prices
INSERT INTO prices(price_id, concert_id, section_id, price)
VALUES -- Ron Sexsmith, floor seats at 130$
    (1, 1, 1, 130),
    -- Ron Sexsmith, balcony seats at 99$
    (2, 1, 2, 99),
    -- Womens Blues Review, floor seats at 150$
    (3, 2, 1, 150),
    -- Womens Blues Review, balcony seats at 125$
    (4, 2, 2, 125),
    -- Mariah Carey - Merry Christmas to all, 100 seats at 986$
    (5, 3, 4, 986),
    -- Mariah Carey - Merry Christmas to all, 200 seats at 244$, 300 at 176$
    (6, 3, 5, 244),
    (7, 3, 6, 176),
    -- TSO - Elf in Concert, main hall - 159$
    (8, 4, 3, 159);
-- users
-- Allicent hightower, username ahightower
-- Daemon Targaryen has the username d_targaryen
-- Criston Cole has the username cristonc
INSERT INTO users(username, name)
VALUES ('ahightower', 'Allicent Hightower'),
    ('d_targaryen', 'Daemon Targaryen'),
    ('cristonc', 'Criston Cole');
-- purchases
INSERT INTO purchases(
        purchase_id,
        concert_instance_id,
        user_name,
        seat_id,
        purchase_time
    )
VALUES -- Allicent Hightower bought A5, C2 for Women's Blues Review
    (1, 2, 'ahightower', 5, '2022-11-20 19:00:00'),
    (2, 2, 'ahightower', 22, '2022-11-20 19:00:00'),
    -- Daemon Targaryen bought 
    -- B3 for Ron Sexsmith
    (3, 1, 'd_targaryen', 13, '2022-12-01 18:00:00'),
    -- BB7 for Elf in concert
    (4, 7, 'd_targaryen', 35, '2022-12-6 19:30:00'),
    -- Criston Cole bought
    (5, 3, 'cristonc', 49, '2022-12-6 19:30:00'),
    (6, 4, 'cristonc', 64, '2022-12-6 19:30:00'),
    (7, 4, 'cristonc', 65, '2022-12-6 19:30:00');