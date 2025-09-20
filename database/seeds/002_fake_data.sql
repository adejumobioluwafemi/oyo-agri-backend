-- ================
-- TO RUN THIS FILE
-- =================
-- psql -U postgres -d oyo_agro_db -f database/seeds/002_fake_data.sql

-- ==============================================
-- FIXED FAKE DATA GENERATOR
-- ==============================================

\c oyo_agro_db;

-- Ensure extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Associations
INSERT INTO Association (Name, RegistrationNo)
SELECT 'Association ' || gs, 'REG-' || gs
FROM generate_series(1, 10) gs;

-- 2. Addresses (needed for Farmers and Farms)
INSERT INTO Addresses (TempClientID, StreetAddress, Town, PostalCode, LGAID, Latitude, Longitude)
SELECT 
    gen_random_uuid(),
    'Street ' || gs,
    'Town ' || gs,
    '100' || gs,
    (SELECT LGAID FROM LGA ORDER BY random() LIMIT 1),
    round((7 + random())::numeric, 6),
    round((3 + random())::numeric, 6)
FROM generate_series(1, 60) gs;

-- 3. Farmers (use addresses)
INSERT INTO Farmer (
    TempClientID,
    FirstName,
    LastName,
    Gender,
    DateOfBirth,
    Email,
    PhoneNumber,
    AssociationID,
    ResidentialAddressID,
    HouseholdSize,
    AvailableLabor,
    PhotoURL
)
SELECT
    gen_random_uuid(),
    'FarmerFirst' || gs,
    'FarmerLast' || gs,
    CASE WHEN gs % 2 = 0 THEN 'Male' ELSE 'Female' END,
    DATE '1980-01-01' + (random() * 10000)::int,
    'farmer' || gs || '@example.com',
    '080' || (1000000 + gs),
    (SELECT AssociationID FROM Association ORDER BY random() LIMIT 1),
    (SELECT AddressID FROM Addresses ORDER BY random() LIMIT 1),
    (random() * 10)::int + 1,
    (random() * 5)::int,
    'https://picsum.photos/200?random=' || gs
FROM generate_series(1, 50) gs;

-- 4. Farms (link to farmers + addresses)
INSERT INTO Farm (
    TempClientID,
    FarmerID,
    FarmTypeID,
    FarmSize,
    FarmAddressID
)
SELECT
    gen_random_uuid(),
    (SELECT FarmerID FROM Farmer ORDER BY random() LIMIT 1),
    (SELECT FarmTypeID FROM FarmType ORDER BY random() LIMIT 1),
    round((random() * 10)::numeric, 2),
    (SELECT AddressID FROM Addresses ORDER BY random() LIMIT 1)
FROM generate_series(1, 30) gs;

-- 5. Crop Registry (link to farms + seasons)
INSERT INTO CropRegistry (
    TempClientID,
    FarmID,
    SeasonID,
    CropTypeID,
    CropVariety,
    AreaPlanted,
    PlantedQuantity,
    PlantingDate,
    HarvestDate,
    AreaHarvested,
    YieldQuantity
)
SELECT
    gen_random_uuid(),
    (SELECT FarmID FROM Farm ORDER BY random() LIMIT 1),
    (SELECT SeasonID FROM Season ORDER BY random() LIMIT 1),
    (SELECT CropTypeID FROM Crop ORDER BY random() LIMIT 1),
    'Variety-' || gs,
    round((random() * 5)::numeric, 2),
    round((random() * 100)::numeric, 2),
    DATE '2025-04-01' + (random() * 90)::int,
    DATE '2025-07-01' + (random() * 90)::int,
    round((random() * 5)::numeric, 2),
    round((random() * 200)::numeric, 2)
FROM generate_series(1, 40) gs;

-- 6. Livestock Registry (link to farms + seasons)
INSERT INTO LivestockRegistry (
    TempClientID,
    FarmID,
    SeasonID,
    LivestockTypeID,
    Quantity,
    StartDate,
    EndDate
)
SELECT
    gen_random_uuid(),
    (SELECT FarmID FROM Farm ORDER BY random() LIMIT 1),
    (SELECT SeasonID FROM Season ORDER BY random() LIMIT 1),
    (SELECT LivestockTypeID FROM Livestock ORDER BY random() LIMIT 1),
    (random() * 100)::int + 1,
    DATE '2025-01-01' + (random() * 100)::int,
    DATE '2025-06-01' + (random() * 100)::int
FROM generate_series(1, 20) gs;
