-- ==============================================
-- Oyo Agriculture Management System - Database
-- ==============================================

-- ==============================================
-- PostgreSQL version of Access Control schemas
-- Database: oyo_agro_db
-- ==============================================

-- ================
-- TO RUN THIS FILE
-- =================
-- psql -U postgres -f database/schema/003_accesscontrol_schema.sql




-- Connect to the database
\c oyo_agro_db;

-- ==============================================
-- Parent Activities
-- ==============================================
CREATE TABLE ProfileActivityParent(
    ActivityParentID SERIAL PRIMARY KEY,
    ActivityParentName TEXT NOT NULL,
    BaseCreateTime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    BaseCreatorId BIGINT NOT NULL,
    BaseVersion INT NOT NULL DEFAULT 1,
    BaseModifyTime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    BaseModifierId BIGINT NOT NULL,
    BaseIsDelete BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================
-- Activities (linked to Parent)
-- ==============================================
CREATE TABLE ProfileActivity (
    ActivityID SERIAL PRIMARY KEY,
    ActivityParentID INT NOT NULL REFERENCES ProfileActivityParent(ActivityParentID) ON DELETE CASCADE,
    ActivityName TEXT NOT NULL,
    BaseCreateTime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    BaseCreatorId BIGINT NOT NULL,
    BaseVersion INT NOT NULL DEFAULT 1,
    BaseModifyTime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    BaseModifierId BIGINT NOT NULL,
    BaseIsDelete BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================
-- Additional Activities per User
-- ==============================================
CREATE TABLE ProfileAdditionalActivity (
    AdditionalActivityID SERIAL PRIMARY KEY,
    UserID INT NOT NULL REFERENCES UserAccount(UserID) ON DELETE CASCADE,
    ActivityID INT NOT NULL REFERENCES ProfileActivity(ActivityID) ON DELETE CASCADE,
    CanAdd BOOLEAN NOT NULL DEFAULT FALSE,
    CanEdit BOOLEAN NOT NULL DEFAULT FALSE,
    CanView BOOLEAN NOT NULL DEFAULT FALSE,
    CanDelete BOOLEAN NOT NULL DEFAULT FALSE,
    CanApprove BOOLEAN NOT NULL DEFAULT FALSE,
    ExpireON TIMESTAMPTZ NULL,
    BaseCreateTime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    BaseCreatorId BIGINT NOT NULL,
    BaseVersion INT NOT NULL DEFAULT 1,
    BaseModifyTime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    BaseModifierId BIGINT NOT NULL,
    BaseIsDelete BOOLEAN NOT NULL DEFAULT FALSE
);

-- Indexes for faster lookups
CREATE INDEX idx_activity_parent ON ProfileActivityParent(ActivityParentID);
CREATE INDEX idx_additionalactivity_user ON ProfileAdditionalActivity(UserID);
CREATE INDEX idx_additionalactivity_activity ON ProfileAdditionalActivity(ActivityID);




