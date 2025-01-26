-- 1.3. Для обеспечения уникальности полей code и name добавим ограничения на уровне базы данных:
ALTER TABLE public.codes ADD CONSTRAINT unique_code_name UNIQUE (code, name);

-- 1.4. Для уникальность поля code как целого числа, можно создать уникальный индекс, который будет применять преобразование типа
CREATE UNIQUE INDEX unique_code_int ON public.codes ((code::int4));

TRUNCATE TABLE public.codes;

WITH unique_codes AS (
    SELECT
        FLOOR(RANDOM() * 2147483647) + 1 AS code 
        --LPAD(FLOOR(RANDOM() * (10 ^ (1 + FLOOR(RANDOM() * 10))))::TEXT, 10, '0') AS code        
    FROM generate_series(1, 100000) -- Генерация большего количества строк для уникальности
)
INSERT INTO public.codes (code, name)
SELECT code, 'Код ' || code AS name
FROM unique_codes
WHERE code IS NOT NULL
LIMIT 10000
ON CONFLICT (code, name) DO NOTHING;

SELECT COUNT(*) FROM public.codes;
