-- ==============================================
-- SEED DATA
-- ==============================================

-- ================
-- TO RUN THIS FILE
-- =================
-- psql -U postgres -d oyo_agro_db -f database/seeds/002_seed_data.sql

-- Roles
INSERT INTO Role (RoleName) VALUES
('StateAdmin'),
('RegionalOfficer'),
('LGAOfficer');

-- Regions
INSERT INTO Region (RegionName) VALUES
('Oyo North'),
('Oyo Central'),
('Oyo South');

-- LGAs (sample few)
INSERT INTO LGA (LGAName, RegionID) VALUES
('Ibadan North', 3),
('Ibadan South-West', 3),
('Ogbomosho North', 1),
('Ogbomosho South', 1);

-- Farm Types
INSERT INTO FarmType (TypeName) VALUES
('Crop'),
('Livestock'),
('Mixed');

-- Crops
INSERT INTO Crop (Name) VALUES
('Maize'),
('Cassava'),
('Yam'),
('Rice');

-- Livestock
INSERT INTO Livestock (Name) VALUES
('Cattle'),
('Goat'),
('Sheep'),
('Poultry');

-- Season
INSERT INTO Season (Name, Year, StartDate, EndDate) VALUES
('2025 Wet', 2025, '2025-04-01', '2025-09-30'),
('2025 Dry', 2025, '2025-10-01', '2026-03-31');
