-- =====================================
-- Oyo State Agriculture Management DB
-- Initial Schema
-- =====================================

-- Drop order for dev resets (CAREFUL IN PROD)
-- DROP TABLE IF EXISTS NotificationTarget, Notification, LivestockRegistry, CropRegistry,
-- Farm, Farmer, Association, UserProfile, "User", Role, UserRegion,
-- Region, LGA, FarmType, Season, Crop, Livestock, Addresses CASCADE;

-- ==============
-- Reference Tables
-- ==============

CREATE TABLE Role (
    RoleID SERIAL PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Region (
    RegionID SERIAL PRIMARY KEY,
    RegionName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE LGA (
    LGAID SERIAL PRIMARY KEY,
    LGAName VARCHAR(100) NOT NULL,
    RegionID INT NOT NULL REFERENCES Region(RegionID)
);

CREATE TABLE FarmType (
    FarmTypeID SERIAL PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Season (
    SeasonID SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL, -- e.g., "2025 Wet"
    Year INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);

CREATE TABLE Crop (
    CropTypeID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Livestock (
    LivestockTypeID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE
);

-- ==========
-- Users & Profiles
-- ==========

CREATE TABLE "User" (
    UserID SERIAL PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash TEXT NOT NULL,
    PIN VARCHAR(10) NOT NULL,
    RoleID INT NOT NULL REFERENCES Role(RoleID),
    LGAID INT NULL REFERENCES LGA(LGAID)
);

CREATE TABLE Addresses (
    AddressID SERIAL PRIMARY KEY,
    StreetAddress VARCHAR(150),
    Town VARCHAR(100),
    LGAID INT NOT NULL REFERENCES LGA(LGAID),
    PostalCode VARCHAR(20),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE UserProfile (
    UserProfileID SERIAL PRIMARY KEY,
    UserID INT NOT NULL UNIQUE REFERENCES "User"(UserID),
    FirstName VARCHAR(100) NOT NULL,
    MiddleName VARCHAR(100),
    LastName VARCHAR(100) NOT NULL,
    Designation VARCHAR(100),
    Gender VARCHAR(20),
    Email VARCHAR(150) UNIQUE,
    PhoneNumber VARCHAR(20),
    Photo TEXT,
    ResidentialAddressID INT NOT NULL REFERENCES Addresses(AddressID)
);

CREATE TABLE UserRegion (
    UserRegionID SERIAL PRIMARY KEY,
    UserID INT NOT NULL REFERENCES "User"(UserID),
    RegionID INT NOT NULL REFERENCES Region(RegionID),
    UNIQUE(UserID, RegionID)
);

-- ==========
-- Farmers, Associations, Farms
-- ==========

CREATE TABLE Association (
    AssociationID SERIAL PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    RegistrationNo VARCHAR(100)
);

CREATE TABLE Farmer (
    FarmerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    MiddleName VARCHAR(100),
    LastName VARCHAR(100) NOT NULL,
    Gender VARCHAR(20),
    DateOfBirth DATE,
    Email VARCHAR(150) UNIQUE,
    PhoneNumber VARCHAR(20),
    AssociationID INT NULL REFERENCES Association(AssociationID),
    ResidentialAddressID INT NOT NULL REFERENCES Addresses(AddressID),
    HouseholdSize INT,
    AvailableLabor INT,
    PhotoURL TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Farm (
    FarmID SERIAL PRIMARY KEY,
    FarmerID INT NOT NULL REFERENCES Farmer(FarmerID),
    FarmTypeID INT NOT NULL REFERENCES FarmType(FarmTypeID),
    FarmSize DECIMAL(10,2) NOT NULL,
    FarmAddressID INT NOT NULL REFERENCES Addresses(AddressID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========
-- Crop & Livestock Registries
-- ==========

CREATE TABLE CropRegistry (
    CropRegistryID SERIAL PRIMARY KEY,
    FarmID INT NOT NULL REFERENCES Farm(FarmID),
    SeasonID INT NOT NULL REFERENCES Season(SeasonID),
    CropTypeID INT NOT NULL REFERENCES Crop(CropTypeID),
    CropVariety VARCHAR(100),
    AreaPlanted DECIMAL(10,2),
    PlantingDate DATE NOT NULL,
    PlantedQuantity DECIMAL(10,2),
    HarvestDate DATE,
    AreaHarvested DECIMAL(10,2),
    YieldQuantity DECIMAL(10,2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE LivestockRegistry (
    LivestockRegistryID SERIAL PRIMARY KEY,
    FarmID INT NOT NULL REFERENCES Farm(FarmID),
    SeasonID INT NOT NULL REFERENCES Season(SeasonID),
    LivestockTypeID INT NOT NULL REFERENCES Livestock(LivestockTypeID),
    Quantity INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========
-- Notifications
-- ==========

CREATE TYPE TargetScopeEnum AS ENUM ('ALL','REGION','LGA','USER');

CREATE TABLE Notification (
    NotificationID SERIAL PRIMARY KEY,
    CreatedBy INT NOT NULL REFERENCES "User"(UserID),
    Title VARCHAR(200) NOT NULL,
    Message TEXT NOT NULL,
    TargetScope TargetScopeEnum NOT NULL,
    IsRead BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE NotificationTarget (
    TargetID SERIAL PRIMARY KEY,
    NotificationID INT NOT NULL REFERENCES Notification(NotificationID),
    RegionID INT NULL REFERENCES Region(RegionID),
    LGAID INT NULL REFERENCES LGA(LGAID),
    UserID INT NULL REFERENCES "User"(UserID)
);
