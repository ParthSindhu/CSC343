drop schema if exists ticketchema cascade;
create schema ticketchema;
set search_path to ticketchema;

-- How to add constraints to to number of seats per Venue -> 10 or more seats per venue

-- Create a table for venues of concerts. 
-- Venues have a name, city and street address
-- venuees have a owner_id which is a foreign key to the owners table
create table venues (
    venue_id integer primary key,
    name varchar(100) not null,
    city varchar(100) not null,
    street varchar(100) not null,
    owner_id integer references owners(owner_id)
);

-- create a table for owners of Venues
-- Owners have a name, phone number which is unique
create table owners (
    owner_id integer primary key,
    name varchar(100) not null,
    phone char(10) not null unique
);

-- seats have a seat_id, venue_id, seat identifier
-- seat identifier should be unique for each venue
-- seats have a section id
-- seats have boolean value is_accessible
create table seats (
    seat_id integer primary key,
    seat text not null,
    section_id integer references sections(section_id),
    is_accessible boolean not null,
    unique(section_id, seat)
);

-- create a table for sections of a venue
-- sections have a section_id, venue_id, section name
-- section name should be unique for each venue
create table sections (
    section_id integer primary key,
    venue_id integer references venues(venue_id),
    section_name varchar(100) not null,
    unique(venue_id, section_name)
);

-- create a table for concert_dates
-- concerts have a concert_id, venue_id, date
-- a venue can only have one coerct on a given date
create table concert_dates (
    concert_instance_id integer primary key,
    concert_id references concerts(concert_id),
    venue_id integer references venues(venue_id),
    concert_date timestamp not null,
    unique(venue_id, concert_date)
);

-- create a table for concerts
-- concerts have a concert_id, concert name
create table concerts (
    concert_id integer primary key,
    concert_name varchar(100) not null
);

-- create a table for prices
-- prices depend on section of the seat and concert

create table prices (
    price_id integer primary key,
    concert_id integer references concerts(concert_id),
    section_id integer references sections(section_id),
    price numeric(6,2) not null,
    unique(concert_id, section_id)
);

-- create a table for users
-- users have a name as primary key
-- additional user information can be added here later
create table users (
    user_name varchar(100) primary key,
    name varchar(100) not null,
);

-- create table for purchases
-- purchases have a purchase_id, concert_id, user_name, seat_id, purchase_time
-- a seat can only be purchased once
create table purchases (
    purchase_id integer primary key,
    concert_instance_id integer references concert_dates(concert_instance_id),
    user_name varchar(100) references users(user_name),
    seat_id integer references seats(seat_id),
    purchase_time timestamp not null,
    unique(concert_id, seat_id)
);