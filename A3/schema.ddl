drop schema if exists ticketchema cascade;
CREATE schema ticketchema;
set search_path to ticketchema;
-- Could not:
-- 1) Was unable to to add a constraint to enforce atleast 10 seats available
-- per venue
-- 2) Similarly, Venue capacity must be greater than 0. ie, a venue must have
--    atleast 1 section. with atleast one seat. It was not mentioned and would
--    have required a trigger or assertion to enforce
-- 3) Could not enforce same concert happens at the same venue every time, as
--    it would require a trigger or assertion to enforce
-- Did not:
--
-- Assumptions:
-- 1) The price per ticket of a concert doest change between different timings
--    of the same concert
-- 2) purchase time of a seat must be before the show time of the concert
-- Extra:
-- 1) price of a ticket is below 10000$ (4 digits). Since numeric(6,2) was used
--    as the datatype.
-- create a table for Owner of venues
-- Owner have a name, phone number which is unique
CREATE TABLE Owner (
    owner_id INTEGER PRIMARY KEY,
    owner_name VARCHAR(100) NOT NULL,
    phone char(10) NOT NULL unique
);
-- Create a table for venues of concerts. 
-- venues have a name, city and street address
-- venuees have a owner_id which is a foreign key to the Owner table
CREATE TABLE Venues (
    venue_id INTEGER PRIMARY KEY,
    venue_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    street VARCHAR(100) NOT NULL,
    owner_id INTEGER REFERENCES Owner(owner_id)
);
-- create a table for sections of a venue
-- sections have a section_id, venue_id, section name
-- section name should be unique for each venue
CREATE TABLE Sections (
    section_id INTEGER PRIMARY KEY,
    venue_id INTEGER REFERENCES Venues(venue_id),
    section_name VARCHAR(100) NOT NULL,
    unique(venue_id, section_name)
);
-- seats have a seat_id, venue_id, seat identifier
-- seat identifier should be unique for each venue
-- seats have a section id
-- seats have boolean value is_accessible
CREATE TABLE Seats (
    seat_id INTEGER PRIMARY KEY,
    seat TEXT NOT NULL,
    section_id INTEGER REFERENCES Sections(section_id),
    is_accessible BOOLEAN NOT NULL,
    unique(section_id, seat)
);
-- create a table for concerts
-- concerts have a concert_id, concert name
CREATE TABLE Concerts (
    concert_id INTEGER PRIMARY KEY,
    concert_name VARCHAR(100) NOT NULL
);
-- create a table for ConcertDates
-- concerts have a concert_id, venue_id, date
-- a venue can only have one coerct on a given date
CREATE TABLE ConcertDates (
    concert_instance_id INTEGER PRIMARY KEY,
    concert_id INTEGER REFERENCES Concerts(concert_id),
    venue_id INTEGER REFERENCES Venues(venue_id),
    concert_date TIMESTAMP NOT NULL,
    unique(venue_id, concert_date)
);
-- create a table for prices
-- prices depend on section of the seat and concert
CREATE TABLE Prices (
    price_id INTEGER PRIMARY KEY,
    concert_id INTEGER REFERENCES Concerts(concert_id),
    section_id INTEGER REFERENCES Sections(section_id),
    price numeric(6, 2) NOT NULL,
    unique(concert_id, section_id)
);
-- create a table for users
-- users have a name as primary key
-- additional user information can be added here later
CREATE TABLE Users (
    user_name VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
-- create table for purchases
-- purchases have a purchase_id, concert_id, user_name, seat_id, purchase_time
-- a seat can only be purchased once
CREATE TABLE Purchases (
    purchase_id INTEGER PRIMARY KEY,
    concert_instance_id INTEGER REFERENCES ConcertDates(concert_instance_id),
    user_name VARCHAR(100) REFERENCES Users(user_name),
    seat_id INTEGER REFERENCES Seats(seat_id),
    purchase_time TIMESTAMP NOT NULL,
    unique(concert_instance_id, seat_id)
);