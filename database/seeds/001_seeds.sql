-- Seed Roles
INSERT INTO Role (RoleName) VALUES 
('StateAdmin'),
('RegionalOfficer'),
('LGAOfficer');

-- Seed Farm Types
INSERT INTO FarmType (TypeName) VALUES 
('Crop'),
('Livestock'),
('Mixed');

-- Seed Regions
INSERT INTO Region (RegionName) VALUES 
('Ibadan'),
('Ogbomosho'),
('Oyo'),
('Ibarapa'),
('Oke-Ogun');

-- Example LGAs (map to regions)
INSERT INTO LGA (LGAName, RegionID) VALUES
('Ibadan North', 1),
('Ibadan South-East', 1),
('Ogbomosho North', 2),
('Oyo East', 3),
('Ibarapa Central', 4),
('Saki West', 5);

-- Seed Crops
INSERT INTO Crop (Name) VALUES
('Maize'),
('Cassava'),
('Yam'),
('Rice'),
('Tomato');

-- Seed Livestock
INSERT INTO Livestock (Name) VALUES
('Cattle'),
('Goat'),
('Sheep'),
('Poultry'),
('Fish');

-- Seed Seasons
INSERT INTO Season (Name, Year, StartDate, EndDate) VALUES
('2025 Wet', 2025, '2025-04-01', '2025-10-31'),
('2025 Dry', 2025, '2025-11-01', '2026-03-31');
