## Task \#1
- Выполнить с 1 по 3 пункт
- Решить проблемы в 4-м пункте

### Решение описано в файле `4_step.sql`

Ниже представлен текст задания.

1. Создаются две таблицы: компании и сотрудники
```
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
```
2. Создается функция, возвращяющая id главной компании
```
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
```

3. Заполняются таблицы компаний и сотрудников, работающих в главной компании
```
TRUNCATE person;
TRUNCATE company;
INSERT INTO company(id, name, type) VALUES(1, 'Компания 1', 'главный');
INSERT INTO company(id, name, type) VALUES(2, 'Компания 2', 'филиал');
INSERT INTO person(id, name, company) VALUES(1, 'Сотрудник 1', company_main());
INSERT INTO person(id, name, company) VALUES(2, 'Сотрудник 2', company_main());
```
4. Изменение головной компании
```
-- При отдельном выполнении оператора DO меняется головная компания, согласно значению company_main.
-- Затем происходит перемещение сотрудников в головную компанию.

-- Проблема: При изменении company_main головная компания у сотрудников меняется
--           только при повторном выполнении оператора DO.
-- Вопрос:   Найти и объяснить причину данного поведения.
-- Задание:  Предложить варианты решения (минимум два), с учетом того, что головную компанию
--           может возвращать только функция company_main().

DO $$
DECLARE
    company_main integer = 1;
BEGIN
    UPDATE company SET type = CASE WHEN id = company_main THEN 'главный' ELSE 'филиал' END;
    UPDATE person SET company = company_main();
    RAISE INFO '%', (SELECT company FROM person LIMIT 1);
END
$$;
```
