-- ==============================================
-- Oyo Agriculture Management System - Database
-- ==============================================
-- ================
-- TO RUN THIS FILE
-- =================
-- psql -U postgres -f database/schema/002_init_schema.sql

-- 1. Create Database
DROP DATABASE IF EXISTS oyo_agro_db;
CREATE DATABASE oyo_agro_db;
\c oyo_agro_db;

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================
-- 2. Utility ENUMS
-- ==============================================
CREATE TYPE target_scope AS ENUM ('ALL','REGION','LGA','USER');
CREATE TYPE operation_type AS ENUM ('INSERT','UPDATE','DELETE');

-- ==============================================
-- 3. Core Tables
-- ==============================================

CREATE TABLE Role (
    RoleID SERIAL PRIMARY KEY,
    RoleName VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Region (
    RegionID SERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    RegionName VARCHAR(100) NOT NULL,
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE LGA (
    LGAID SERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    LGAName VARCHAR(100) NOT NULL,
    RegionID BIGINT NOT NULL REFERENCES Region(RegionID),
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE UserAccount (
    UserID SERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    Username VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash TEXT NOT NULL,
    PIN VARCHAR(10),
    RoleID BIGINT NOT NULL REFERENCES Role(RoleID),
    LGAID BIGINT REFERENCES LGA(LGAID),
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE Addresses (
    AddressID BIGSERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    StreetAddress VARCHAR(255),
    Town VARCHAR(100),
    PostalCode VARCHAR(20),
    LGAID BIGINT REFERENCES LGA(LGAID),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE UserProfile (
    UserProfileID SERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    UserID BIGINT NOT NULL REFERENCES UserAccount(UserID) ON DELETE CASCADE,
    FirstName VARCHAR(100) NOT NULL,
    MiddleName VARCHAR(100),
    LastName VARCHAR(100) NOT NULL,
    Designation VARCHAR(100),
    Gender VARCHAR(20),
    Email VARCHAR(150),
    PhoneNumber VARCHAR(20),
    Photo TEXT,
    ResidentialAddressID BIGINT REFERENCES Addresses(AddressID),
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE UserRegion (
    UserRegionID SERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    UserID BIGINT NOT NULL REFERENCES UserAccount(UserID),
    RegionID BIGINT NOT NULL REFERENCES Region(RegionID),
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

-- ==============================================
-- 4. Farmer & Association
-- ==============================================
CREATE TABLE Association (
    AssociationID SERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    Name VARCHAR(150) NOT NULL,
    RegistrationNo VARCHAR(100),
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE Farmer (
    FarmerID SERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    FirstName VARCHAR(100) NOT NULL,
    MiddleName VARCHAR(100),
    LastName VARCHAR(100) NOT NULL,
    Gender VARCHAR(20),
    DateOfBirth DATE,
    Email VARCHAR(150),
    PhoneNumber VARCHAR(20),
    AssociationID BIGINT REFERENCES Association(AssociationID),
    ResidentialAddressID BIGINT NOT NULL REFERENCES Addresses(AddressID),
    HouseholdSize INT,
    AvailableLabor INT,
    PhotoURL TEXT,
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

-- ==============================================
-- 5. Farms, Crops, Livestock
-- ==============================================
CREATE TABLE FarmType (
    FarmTypeID SERIAL PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL
);

CREATE TABLE Farm (
    FarmID BIGSERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    FarmerID BIGINT NOT NULL REFERENCES Farmer(FarmerID) ON DELETE CASCADE,
    FarmTypeID BIGINT NOT NULL REFERENCES FarmType(FarmTypeID),
    FarmSize DECIMAL,
    FarmAddressID BIGINT REFERENCES Addresses(AddressID),
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE Season (
    SeasonID SERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    Name VARCHAR(50) NOT NULL,
    Year INT,
    StartDate DATE,
    EndDate DATE,
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE Crop (
    CropTypeID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);

CREATE TABLE CropRegistry (
    CropRegistryID BIGSERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    FarmID BIGINT NOT NULL REFERENCES Farm(FarmID),
    SeasonID BIGINT NOT NULL REFERENCES Season(SeasonID),
    CropTypeID BIGINT NOT NULL REFERENCES Crop(CropTypeID),
    CropVariety VARCHAR(100),
    AreaPlanted DECIMAL,
    PlantedQuantity DECIMAL,
    PlantingDate DATE,
    HarvestDate DATE,
    AreaHarvested DECIMAL,
    YieldQuantity DECIMAL,
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE Livestock (
    LivestockTypeID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);

CREATE TABLE LivestockRegistry (
    LivestockRegistryID BIGSERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    FarmID BIGINT NOT NULL REFERENCES Farm(FarmID),
    SeasonID BIGINT NOT NULL REFERENCES Season(SeasonID),
    LivestockTypeID BIGINT NOT NULL REFERENCES Livestock(LivestockTypeID),
    Quantity INT,
    StartDate DATE,
    EndDate DATE,
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

-- ==============================================
-- 6. Notifications
-- ==============================================
CREATE TABLE Notification (
    NotificationID BIGSERIAL PRIMARY KEY,
    TempClientID UUID UNIQUE,
    CreatedBy BIGINT REFERENCES UserAccount(UserID),
    Title VARCHAR(255),
    Message TEXT,
    TargetScope target_scope NOT NULL,
    IsRead BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMPTZ DEFAULT NOW(),
    UpdatedAt TIMESTAMPTZ DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ,
    Version BIGINT DEFAULT 1
);

CREATE TABLE NotificationTarget (
    TargetID BIGSERIAL PRIMARY KEY,
    NotificationID BIGINT NOT NULL REFERENCES Notification(NotificationID),
    RegionID BIGINT REFERENCES Region(RegionID),
    LGAID BIGINT REFERENCES LGA(LGAID),
    UserID BIGINT REFERENCES UserAccount(UserID)
);

-- ==============================================
-- 7. Sync Support
-- ==============================================
CREATE TABLE SyncLog (
    SyncLogID BIGSERIAL PRIMARY KEY,
    TableName VARCHAR(100) NOT NULL,
    TempClientID UUID,
    ServerID BIGINT,
    OperationType operation_type NOT NULL,
    ChangedAt TIMESTAMPTZ DEFAULT NOW(),
    ClientId VARCHAR(100),
    Processed BOOLEAN DEFAULT FALSE
);
