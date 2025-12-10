-- ======================================================
-- Migration 006: Create AgroAlliedRegistry
-- Database: oyo_agro_db
-- ======================================================

-- ===============================
-- Create Lookup Table: BusinessType
-- ===============================
CREATE TABLE IF NOT EXISTS "BusinessType" (
    "BusinessTypeId" SERIAL PRIMARY KEY,
    "Name" VARCHAR(100),
    "Createdat" TIMESTAMP DEFAULT now(),
    "Updatedat" TIMESTAMP DEFAULT now(),
    "Deletedat" TIMESTAMP NULL
);
COMMENT ON TABLE "BusinessType" IS 'Lookup table for agro-allied business types (e.g., Processing, Packaging, Storage).';
COMMENT ON COLUMN "BusinessType"."Name" IS 'Name of the business type.';


-- ===============================
-- Create Lookup Table: PrimaryProduct
-- ===============================
CREATE TABLE IF NOT EXISTS "PrimaryProduct" (
    "PrimaryProductTypeId" SERIAL PRIMARY KEY,
    "Name" VARCHAR(100),
    "Createdat" TIMESTAMP DEFAULT now(),
    "Updatedat" TIMESTAMP DEFAULT now(),
    "Deletedat" TIMESTAMP NULL
);

COMMENT ON TABLE "PrimaryProduct" IS 'Lookup table for main agricultural products handled by agro-allied businesses.';
COMMENT ON COLUMN "PrimaryProduct"."Name" IS 'Name of the product (e.g., Cassava Flour, Poultry Feed).';



-- ===============================
-- Create Main Table: AgroAlliedRegistry
-- ===============================
CREATE TABLE IF NOT EXISTS "AgroAlliedRegistry" (
    "AgroAlliedRegistryid" SERIAL PRIMARY KEY,
    "Farmid" INT NOT NULL,
    "BusinessTypeId" INT NOT NULL,
    "PrimaryProductTypeId" INT NOT NULL,
    "Seasonid" INT NOT NULL,
    "ProductionCapacity" VARCHAR(255),
    "Tempclientid" VARCHAR(255) UNIQUE,
    "Createdat" TIMESTAMP DEFAULT now(),
    "Updatedat" TIMESTAMP DEFAULT now(),
    "Deletedat" TIMESTAMP NULL,
    
    CONSTRAINT "AgroAlliedRegistry_farmid_fkey"
        FOREIGN KEY ("Farmid") REFERENCES Farm (Farmid) ON DELETE SET NULL,
    CONSTRAINT "AgroAlliedRegistry_seasonid_fkey"
        FOREIGN KEY ("Seasonid") REFERENCES Season (Seasonid) ON DELETE SET NULL,
    CONSTRAINT "AgroAlliedRegistry_businesstypeid_fkey"
        FOREIGN KEY ("BusinessTypeId") REFERENCES "BusinessType" ("BusinessTypeId") ON DELETE SET NULL,
    CONSTRAINT "AgroAlliedRegistry_primaryproducttypeId_fkey"
        FOREIGN KEY ("PrimaryProductTypeId") REFERENCES "PrimaryProduct" ("PrimaryProductTypeId") ON DELETE SET NULL
);

COMMENT ON TABLE "AgroAlliedRegistry" IS 'Tracks agro-allied production businesses linked to farms and seasons.';
COMMENT ON COLUMN "AgroAlliedRegistry"."Tempclientid" IS 'Temporary UUID for offline sync before server assigns FarmID.';
COMMENT ON COLUMN "AgroAlliedRegistry"."BusinessTypeId" IS 'FK → BusinessType lookup table.';
COMMENT ON COLUMN "AgroAlliedRegistry"."PrimaryProductTypeId" IS 'FK → PrimaryProduct lookup table.';


-- ===============================
-- Indexes
-- ===============================
CREATE INDEX IF NOT EXISTS idx_agroalliedregistry_farmid
    ON "AgroAlliedRegistry"("Farmid");

CREATE INDEX IF NOT EXISTS idx_agroalliedregistry_seasonid
    ON "AgroAlliedRegistry"("Seasonid");

CREATE INDEX IF NOT EXISTS idx_agroalliedregistry_businesstypeid
    ON "AgroAlliedRegistry"("BusinessTypeId");

CREATE INDEX IF NOT EXISTS idx_agroalliedregistry_primaryproductid
    ON "AgroAlliedRegistry"("PrimaryProductTypeId");

CREATE INDEX IF NOT EXISTS idx_agroalliedregistry_deletedat
    ON "AgroAlliedRegistry"("Deletedat");

-- ===============================
-- Seed Lookup Data
-- ===============================
INSERT INTO BusinessType ("Name")
VALUES
    ('Agro-chemical'),
	('FeedMill'),
	('Food Processing'),
    ('Packaging'),
    ('Storage'),
    ('Distribution')
ON CONFLICT ("Name") DO NOTHING;

INSERT INTO "PrimaryProduct" ("Name")
VALUES
    ('Cassava Flour'),
    ('Maize Grain'),
    ('Palm Oil'),
    ('Poultry Feed'),
    ('Tomato Paste')
ON CONFLICT ("Name") DO NOTHING;
--===================================
--get the list of columns in a table with their data types and foreign key information
--===================================
SELECT 
    c.column_name,
    c.data_type,
    c.is_nullable,
    CASE 
        WHEN fk.constraint_name IS NOT NULL THEN 'YES'
        ELSE 'NO'
    END AS is_foreign_key,
    fk.foreign_table_name,
    fk.foreign_column_name
FROM information_schema.columns c
LEFT JOIN (
    SELECT 
        kcu.table_name,
        kcu.column_name,
        tc.constraint_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu 
        ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage ccu 
        ON tc.constraint_name = ccu.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY'
) fk ON c.table_name = fk.table_name AND c.column_name = fk.column_name
WHERE c.table_name = 'AgroAlliedRegistry'
    AND c.table_schema = 'public'
ORDER BY c.ordinal_position;