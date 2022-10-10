-- -----------------------------------------------------
-- Enable postgis extension
-- -----------------------------------------------------

CREATE EXTENSION postgis ;

CREATE EXTENSION btree_gist;


-- -----------------------------------------------------
-- Schema case01
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS case01;

-- -----------------------------------------------------
-- franchaise table
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS case01.franchaises (
    id CHAR (3),
    franchaise VARCHAR (30),
    PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- restaurant table
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS case01.restaurants (
    id SERIAL,
    franchaise CHAR (3) NOT NULL,
    geom GEOMETRY (point, 2163),
    PRIMARY KEY (id),
    CONSTRAINT fk_restaurants_lu_franchaises
        FOREIGN KEY (franchaise)
        REFERENCES case01.franchaises (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ------------------------------------------------------------------------------
-- Create an index for efficient join between restaurants and francahises tables
-- ------------------------------------------------------------------------------

CREATE INDEX fki_restaurants_franchaises ON case01.restaurants (franchaise);


-- -----------------------------------------------------
-- Create a spatial index for the restaurant table
-- -----------------------------------------------------

CREATE INDEX idx_code_restaurant_geom ON case01.restaurants USING gist(geom);


-- -----------------------------------------------------
-- highways table
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS case01.highways (
    gid INT NOT NULL,
    feature VARCHAR(80),
    name VARCHAR(120),
    state VARCHAR(2),
    geom GEOMETRY(multilinestring,2163),
    CONSTRAINT pk_highways PRIMARY KEY (gid)
);

-- -----------------------------------------------------
-- Create a spatial index for the highways table
-- -----------------------------------------------------

CREATE INDEX idx_highways ON case01.highways USING gist(gid);

-- -----------------------------------------------------
-- Create staging table for load data into restaurants
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS case01.restaurants_staging (
    franchaise TEXT,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION 
);

-- -----------------------------------------------------
-- Insert data into franchaises
-- -----------------------------------------------------

INSERT INTO case01.franchaises(id, franchaise)
VALUES
    ('BKG', 'Burger King'), 
    ('CJR', 'Carl''s Jr'),
    ('HDE', 'Hardee'), 
    ('INO', 'In-N-Out'),
    ('JIB', 'Jack in the Box'), 
    ('KFC', 'Kentucky Fried Chicken'),
    ('MCD', 'McDonald'), 
    ('PZH', 'Pizza Hut'),
    ('TCB', 'Taco Bell'), 
    ('WDY', 'Wendys');

-- -----------------------------------------------------
-- Insert data into restaurants_staging
-- -----------------------------------------------------

COPY case01.restaurants_staging
    FROM '/data/restaurants.csv'
    DELIMITER as ',';


-- -----------------------------------------------------------
-- Insert data into restaurants from and by transforming temp
-- -----------------------------------------------------------

INSERT INTO case01.restaurants (franchaise, geom)
SELECT 
    franchaise,
    ST_transform(ST_SetSRID(ST_Point(lon,lat),4326),2163) AS geom
FROM case01.restaurants_staging;
