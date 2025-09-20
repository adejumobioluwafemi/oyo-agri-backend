-- ================
-- TO RUN THIS FILE
-- =================
-- psql -U postgres -d oyo_agro_db -f database/schema/002_drop_all.sql

-- =====
-- ==============================================
-- DROP ALL TABLES FOR oyo_agro_db (Development Only)
-- ==============================================

-- Switch to the database
\c oyo_agro_db;

-- Disable FK constraints (needed for drop order safety)
SET session_replication_role = replica;

-- Drop dependent tables first
DROP TABLE IF EXISTS SyncLog CASCADE;
DROP TABLE IF EXISTS NotificationTarget CASCADE;
DROP TABLE IF EXISTS Notification CASCADE;
DROP TABLE IF EXISTS LivestockRegistry CASCADE;
DROP TABLE IF EXISTS CropRegistry CASCADE;
DROP TABLE IF EXISTS Livestock CASCADE;
DROP TABLE IF EXISTS Crop CASCADE;
DROP TABLE IF EXISTS Farm CASCADE;
DROP TABLE IF EXISTS FarmType CASCADE;
DROP TABLE IF EXISTS Season CASCADE;
DROP TABLE IF EXISTS Farmer CASCADE;
DROP TABLE IF EXISTS Association CASCADE;
DROP TABLE IF EXISTS UserRegion CASCADE;
DROP TABLE IF EXISTS UserProfile CASCADE;
DROP TABLE IF EXISTS Addresses CASCADE;
DROP TABLE IF EXISTS UserAccount CASCADE;
DROP TABLE IF EXISTS LGA CASCADE;
DROP TABLE IF EXISTS Region CASCADE;
DROP TABLE IF EXISTS Role CASCADE;

-- Drop enums (must be dropped separately)
DROP TYPE IF EXISTS target_scope CASCADE;
DROP TYPE IF EXISTS operation_type CASCADE;

-- Re-enable FK constraints
SET session_replication_role = DEFAULT;

-- Optionally, drop and recreate the database itself (use with care!)
-- \c postgres;
-- DROP DATABASE IF EXISTS oyo_agro_db;
-- CREATE DATABASE oyo_agro_db;
