-- Table: public.codes
-- DROP TABLE IF EXISTS public.codes;

CREATE TABLE IF NOT EXISTS public.codes
(
    id serial NOT NULL,
    name text COLLATE pg_catalog."default" NOT NULL,
    code character varying(10) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT codes_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
