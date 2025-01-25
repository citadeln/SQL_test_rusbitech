-- 1. Создаются две таблицы: компании и сотрудники
--Table: public.company
--DROP TABLE IF EXISTS public.company;

CREATE TABLE IF NOT EXISTS public.company
(
    id integer NOT NULL,
    name text COLLATE pg_catalog."default" NOT NULL,
    type character varying(10) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT company_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS public.person
(
    id integer NOT NULL,
    name text COLLATE pg_catalog."default" NOT NULL,
    company integer NOT NULL,
    CONSTRAINT person_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

--2. Создается функция, возвращяющая id главной компании
--FUNCTION: public.company_main()
--DROP FUNCTION public.company_main();

CREATE OR REPLACE FUNCTION public.company_main(
	)
    RETURNS integer
    LANGUAGE 'sql'
    COST 100
    IMMUTABLE STRICT
AS $BODY$
select id
	from company
	where type = 'главный';
$BODY$;


--3. Заполняются таблицы компаний и сотрудников, работающих в главной компании

TRUNCATE person;
TRUNCATE company;
INSERT INTO company(id, name, type) VALUES(1, 'Компания 1', 'главный');
INSERT INTO company(id, name, type) VALUES(2, 'Компания 2', 'филиал');
INSERT INTO person(id, name, company) VALUES(1, 'Сотрудник 1', company_main());
INSERT INTO person(id, name, company) VALUES(2, 'Сотрудник 2', company_main());
