CREATE TABLE passwordresettokens (
    id SERIAL PRIMARY KEY,
    userid INTEGER NOT NULL,
    token VARCHAR(255) NOT NULL,
    expiresat TIMESTAMP NOT NULL,
    isused BOOLEAN NOT NULL DEFAULT FALSE,
    usedat TIMESTAMP NULL,
    ipaddress VARCHAR(45) NULL,
    useragent VARCHAR(500) NULL,
    createdat TIMESTAMP NOT NULL DEFAULT NOW(),
    updatedat TIMESTAMP NOT NULL DEFAULT NOW(),
    deletedat TIMESTAMP NULL
);

ALTER TABLE public.passwordresettokens
ADD CONSTRAINT fk_passwordresettokens_userid
FOREIGN KEY (userid)
REFERENCES public.useraccount(userid)
ON DELETE CASCADE;

CREATE INDEX idx_passwordresettokens_token ON passwordresettokens(token);
CREATE INDEX idx_passwordresettokens_userid ON passwordresettokens(userid);
CREATE INDEX idx_passwordresettokens_expiresat ON passwordresettokens(expiresat);