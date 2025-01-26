-- 1.1. Заполнить таблицу случайными значениями code,
--      состоящими из цифр, длинной от 1 до 10, в количестве 10000 записей
-- 1.2. Поле name заполнить в виде:
--      а) "Код 1234", где 1234 сгенерированный код (простой вариант)
--      б) Случайное текстовое значение (цифры и символы) длинной не более 1000
-- 1.3. Поля code и name заполнять с учетом уникальности каждого поля.
-- 1.4. Предложить варианты контроля уникальности полей code и name.
--      Уникальность code определять по целому типу ::int4

-- 1.3. Для обеспечения уникальности полей code и name добавим ограничения на уровне базы данных:
ALTER TABLE public.codes ADD CONSTRAINT unique_code UNIQUE (code);
ALTER TABLE public.codes ADD CONSTRAINT unique_name UNIQUE (name);

-- 1.4. Для уникальность поля code как целого числа, можно создать уникальный индекс, который будет применять преобразование типа
CREATE UNIQUE INDEX unique_code_int ON public.codes ((code::int4));

TRUNCATE TABLE public.codes;

WITH unique_codes AS (
    SELECT 
        LPAD(FLOOR(RANDOM() * (10 ^ (1 + FLOOR(RANDOM() * 10))))::TEXT, 10, '0') AS code,
        'Код ' || LPAD(FLOOR(RANDOM() * (10 ^ (1 + FLOOR(RANDOM() * 10))))::TEXT, 10, '0') AS name,
        ROW_NUMBER() OVER () AS rn
    FROM generate_series(1, 100000) -- Генерация большего количества строк для уникальности
)
INSERT INTO public.codes (code, name)
SELECT code, name
FROM unique_codes
WHERE rn <= 10000
ON CONFLICT (code, name) DO NOTHING;







/*





WITH RECURSIVE random_codes AS (
    SELECT 
        LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0') AS code,
        'Код ' || LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0') AS name,
        1 AS rn
    UNION ALL
    SELECT 
        LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0'),
        'Код ' || LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0'),
        rn + 1
    FROM random_codes
    WHERE rn < 10000
)
INSERT INTO public.codes (code, name)
SELECT DISTINCT code, name
FROM random_codes
WHERE code IS NOT NULL AND name IS NOT NULL
ON CONFLICT (code) DO NOTHING;




WITH RECURSIVE random_codes AS (
    SELECT 
        LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0') AS code,
        'Код ' || LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0') AS name,
        1 AS rn
    UNION ALL
    SELECT 
        LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 
             (FLOOR(RANDOM() * 10) + 1), '0') AS code,
        'Код ' || LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 
             (FLOOR(RANDOM() * 10) + 1), '0') AS name,
        rn + 1
    FROM random_codes
    WHERE rn < 10000
)
INSERT INTO public.codes (code, name)
SELECT DISTINCT code, name
FROM random_codes
WHERE code IS NOT NULL AND name IS NOT NULL
ON CONFLICT (code) DO NOTHING;


 --Ограничение: нельзя использовать пользовательские функции.
   -- Примечание: можно использовать CTE и подзапросы. Переделай код для решения задач с 1 по 4



   CREATE TABLE IF NOT EXISTS public.codes (
    id serial NOT NULL,
    name text COLLATE pg_catalog."default" NOT NULL,
    code character varying(10) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT codes_pkey PRIMARY KEY (id),
    CONSTRAINT unique_code UNIQUE (code),
    CONSTRAINT unique_name UNIQUE (name)
) WITH (
    OIDS = FALSE
) TABLESPACE pg_default;

-- Удаляем все записи, если таблица уже заполнена
TRUNCATE TABLE public.codes;

-- Генерация 10,000 уникальных кодов и имен
INSERT INTO public.codes (code, name)
SELECT DISTINCT
    LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0') AS code,
    'Код ' || LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0') AS name
FROM generate_series(1, 100000) -- Генерируем больше строк, чтобы гарантировать уникальность
WHERE code IS NOT NULL AND name IS NOT NULL
LIMIT 10000
ON CONFLICT (code) DO NOTHING
ON CONFLICT (name) DO NOTHING;