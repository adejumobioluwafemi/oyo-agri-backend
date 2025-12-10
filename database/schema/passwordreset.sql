ALTER TABLE useraccount
ADD COLUMN IF NOT EXISTS PasswordResetToken VARCHAR(255),
ADD COLUMN IF NOT EXISTS PasswordResetTokenExpires TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS LastPasswordReset TIMESTAMPTZ;

ALTER TABLE useraccount
ADD COLUMN IF NOT EXISTS PasswordResetToken VARCHAR(255),
ALTER COLUMN IF NOT EXISTS PasswordResetTokenExpires TYPE TIMESTAMP,
ALTER COLUMN IF NOT EXISTS LastPasswordReset TYPE TIMESTAMP;


SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'useraccount';

-- Table: public.useraccount

-- DROP TABLE IF EXISTS public.useraccount;

CREATE TABLE IF NOT EXISTS public.useraccount
(
    userid integer NOT NULL DEFAULT nextval('useraccount_userid_seq'::regclass),
    tempclientid uuid,
    username character varying(100) COLLATE pg_catalog."default" NOT NULL,
    passwordhash text COLLATE pg_catalog."default" NOT NULL,
    "Password" character varying(10) COLLATE pg_catalog."default",
    createdat timestamp with time zone DEFAULT now(),
    updatedat timestamp with time zone DEFAULT now(),
    deletedat timestamp with time zone,
    version bigint DEFAULT 1,
    salt text COLLATE pg_catalog."default",
    email text COLLATE pg_catalog."default",
    status integer,
    apitoken text COLLATE pg_catalog."default",
    logincount integer,
    lastlogindate date,
    deactivateddate date,
    failedloginattempt integer,
    securityquestion text COLLATE pg_catalog."default",
    securityanswer text COLLATE pg_catalog."default",
    isactive boolean,
    islocked boolean,
    "PasswordResetToken" text COLLATE pg_catalog."default",
    "LastPasswordReset" timestamp without time zone,
    "PasswordResetTokenExpires" timestamp without time zone,
    CONSTRAINT useraccount_pkey PRIMARY KEY (userid),
    CONSTRAINT useraccount_tempclientid_key UNIQUE (tempclientid),
    CONSTRAINT useraccount_username_key UNIQUE (username)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.useraccount
    OWNER to postgres;


-- Add columns that don't exist
DO $$ 
BEGIN
    -- Add tempclientid if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'tempclientid') THEN
        ALTER TABLE public.useraccount ADD COLUMN tempclientid uuid;
    END IF;

    -- Add passwordhash if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'passwordhash') THEN
        ALTER TABLE public.useraccount ADD COLUMN passwordhash text COLLATE pg_catalog."default" NOT NULL DEFAULT '';
    END IF;

    -- Add "Password" if it doesn't exist (note: this field is a security concern)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'Password') THEN
        ALTER TABLE public.useraccount ADD COLUMN "Password" character varying(10) COLLATE pg_catalog."default";
    END IF;

    -- Add createdat if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'createdat') THEN
        ALTER TABLE public.useraccount ADD COLUMN createdat timestamp with time zone DEFAULT now();
    END IF;

    -- Add updatedat if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'updatedat') THEN
        ALTER TABLE public.useraccount ADD COLUMN updatedat timestamp with time zone DEFAULT now();
    END IF;

    -- Add deletedat if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'deletedat') THEN
        ALTER TABLE public.useraccount ADD COLUMN deletedat timestamp with time zone;
    END IF;

    -- Add version if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'version') THEN
        ALTER TABLE public.useraccount ADD COLUMN version bigint DEFAULT 1;
    END IF;

    -- Add salt if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'salt') THEN
        ALTER TABLE public.useraccount ADD COLUMN salt text COLLATE pg_catalog."default";
    END IF;

    -- Add email if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'email') THEN
        ALTER TABLE public.useraccount ADD COLUMN email text COLLATE pg_catalog."default";
    END IF;

    -- Add status if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'status') THEN
        ALTER TABLE public.useraccount ADD COLUMN status integer;
    END IF;

    -- Add apitoken if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'apitoken') THEN
        ALTER TABLE public.useraccount ADD COLUMN apitoken text COLLATE pg_catalog."default";
    END IF;

    -- Add logincount if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'logincount') THEN
        ALTER TABLE public.useraccount ADD COLUMN logincount integer;
    END IF;

    -- Add lastlogindate if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'lastlogindate') THEN
        ALTER TABLE public.useraccount ADD COLUMN lastlogindate date;
    END IF;

    -- Add deactivateddate if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'deactivateddate') THEN
        ALTER TABLE public.useraccount ADD COLUMN deactivateddate date;
    END IF;

    -- Add failedloginattempt if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'failedloginattempt') THEN
        ALTER TABLE public.useraccount ADD COLUMN failedloginattempt integer;
    END IF;

    -- Add securityquestion if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'securityquestion') THEN
        ALTER TABLE public.useraccount ADD COLUMN securityquestion text COLLATE pg_catalog."default";
    END IF;

    -- Add securityanswer if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'securityanswer') THEN
        ALTER TABLE public.useraccount ADD COLUMN securityanswer text COLLATE pg_catalog."default";
    END IF;

    -- Add isactive if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'isactive') THEN
        ALTER TABLE public.useraccount ADD COLUMN isactive boolean;
    END IF;

    -- Add islocked if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'islocked') THEN
        ALTER TABLE public.useraccount ADD COLUMN islocked boolean;
    END IF;

    -- Add "PasswordResetToken" if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'PasswordResetToken') THEN
        ALTER TABLE public.useraccount ADD COLUMN "PasswordResetToken" text COLLATE pg_catalog."default";
    END IF;

    -- Add "LastPasswordReset" if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'LastPasswordReset') THEN
        ALTER TABLE public.useraccount ADD COLUMN "LastPasswordReset" timestamp without time zone;
    END IF;

    -- Add "PasswordResetTokenExpires" if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'PasswordResetTokenExpires') THEN
        ALTER TABLE public.useraccount ADD COLUMN "PasswordResetTokenExpires" timestamp without time zone;
    END IF;

END $$;

-- Add constraints if they don't exist
DO $$
BEGIN
    -- Add primary key constraint if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE table_name = 'useraccount' AND constraint_name = 'useraccount_pkey') THEN
        ALTER TABLE public.useraccount ADD CONSTRAINT useraccount_pkey PRIMARY KEY (userid);
    END IF;

    -- Add unique constraint for tempclientid if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE table_name = 'useraccount' AND constraint_name = 'useraccount_tempclientid_key') THEN
        ALTER TABLE public.useraccount ADD CONSTRAINT useraccount_tempclientid_key UNIQUE (tempclientid);
    END IF;

    -- Add unique constraint for username if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE table_name = 'useraccount' AND constraint_name = 'useraccount_username_key') THEN
        ALTER TABLE public.useraccount ADD CONSTRAINT useraccount_username_key UNIQUE (username);
    END IF;
END $$;

-- Create sequence if it doesn't exist and set default value for userid
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.sequences 
                   WHERE sequence_name = 'useraccount_userid_seq') THEN
        CREATE SEQUENCE public.useraccount_userid_seq;
    END IF;

    -- Set default value for userid if not already set
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'useraccount' AND column_name = 'userid' 
                   AND column_default LIKE '%nextval%') THEN
        ALTER TABLE public.useraccount ALTER COLUMN userid SET DEFAULT nextval('useraccount_userid_seq');
    END IF;
END $$;