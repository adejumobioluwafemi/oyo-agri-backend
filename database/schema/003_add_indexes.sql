-- ==============================================
-- Indexes for oyo_agro_db
-- ==============================================

-- ================
-- TO RUN THIS FILE
-- =================
-- psql -U postgres -f database/schema/003_add_indexes.sql

-- ==============================================
-- Database: oyo_agro_db
-- ==============================================

\c oyo_agro_db;

-- ==========================
-- User & Profile
-- ==========================
CREATE INDEX idx_user_roleid ON UserAccount(RoleID);
CREATE INDEX idx_user_lgaid ON UserAccount(LGAID);
CREATE UNIQUE INDEX idx_user_username ON UserAccount(Username);

CREATE INDEX idx_userprofile_userid ON UserProfile(UserID);
CREATE UNIQUE INDEX idx_userprofile_email ON UserProfile(Email);
CREATE INDEX idx_userprofile_phone ON UserProfile(PhoneNumber);

-- ==========================
-- Roles & Regions
-- ==========================
CREATE INDEX idx_userregion_userid ON UserRegion(UserID);
CREATE INDEX idx_userregion_regionid ON UserRegion(RegionID);

CREATE UNIQUE INDEX idx_region_name ON Region(RegionName);
CREATE INDEX idx_lga_regionid ON LGA(RegionID);
CREATE UNIQUE INDEX idx_lga_name ON LGA(LGAName);

-- ==========================
-- Farmer & Association
-- ==========================
CREATE INDEX idx_farmer_associationid ON Farmer(AssociationID);
CREATE INDEX idx_farmer_addressid ON Farmer(ResidentialAddressID);
CREATE UNIQUE INDEX idx_farmer_email ON Farmer(Email);
CREATE INDEX idx_farmer_phone ON Farmer(PhoneNumber);

CREATE UNIQUE INDEX idx_association_name ON Association(Name);

-- ==========================
-- Farm & Types
-- ==========================
CREATE INDEX idx_farm_farmerid ON Farm(FarmerID);
CREATE INDEX idx_farm_typeid ON Farm(FarmTypeID);
CREATE INDEX idx_farm_addressid ON Farm(FarmAddressID);

CREATE UNIQUE INDEX idx_farmtype_name ON FarmType(TypeName);

-- ==========================
-- Season / Crop / Livestock
-- ==========================
CREATE UNIQUE INDEX idx_season_name_year ON Season(Name, Year);

CREATE UNIQUE INDEX idx_crop_name ON Crop(Name);
CREATE UNIQUE INDEX idx_livestock_name ON Livestock(Name);

CREATE INDEX idx_cropregistry_farmid ON CropRegistry(FarmID);
CREATE INDEX idx_cropregistry_seasonid ON CropRegistry(SeasonID);
CREATE INDEX idx_cropregistry_croptypeid ON CropRegistry(CropTypeID);
CREATE INDEX idx_cropregistry_plantingdate ON CropRegistry(PlantingDate);

CREATE INDEX idx_livestockregistry_farmid ON LivestockRegistry(FarmID);
CREATE INDEX idx_livestockregistry_seasonid ON LivestockRegistry(SeasonID);
CREATE INDEX idx_livestockregistry_typeid ON LivestockRegistry(LivestockTypeID);

-- ==========================
-- Notifications
-- ==========================
CREATE INDEX idx_notification_createdby ON Notification(CreatedBy);
CREATE INDEX idx_notification_isread ON Notification(IsRead);
CREATE INDEX idx_notification_createdat ON Notification(CreatedAt);

CREATE INDEX idx_notificationtarget_notificationid ON NotificationTarget(NotificationID);
CREATE INDEX idx_notificationtarget_regionid ON NotificationTarget(RegionID);
CREATE INDEX idx_notificationtarget_lgaid ON NotificationTarget(LGAID);
CREATE INDEX idx_notificationtarget_userid ON NotificationTarget(UserID);

-- ==========================
-- Addresses
-- ==========================
CREATE INDEX idx_addresses_lgaid ON Addresses(LGAID);
CREATE INDEX idx_addresses_town ON Addresses(Town);

-- ==========================
-- SyncLog
-- ==========================
CREATE INDEX idx_synclog_tablename ON SyncLog(TableName);
CREATE INDEX idx_synclog_tempclientid ON SyncLog(TempClientID);
CREATE INDEX idx_synclog_serverid ON SyncLog(ServerID);
CREATE INDEX idx_synclog_changedat ON SyncLog(ChangedAt);

-- ==============================================
-- Notes:
-- 1. All FKs have supporting indexes.
-- 2. Unique constraints for natural keys (Name, Email, Username).
-- 3. Timestamp & status indexes to speed filtering (CreatedAt, IsRead).
-- ==============================================
