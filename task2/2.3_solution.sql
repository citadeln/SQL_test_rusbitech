-- Задача: написать единый запрос для вставки 1000 уникальных кодов в таблицу public.codes, заполняя пропущенные id между первым id и максимальным.

-- Если пропущенных id было меньше 1000, вставила их в конец таблицы.

WITH numbered_codes AS (
    SELECT
        id,
        LAG(id) OVER (ORDER BY id) AS prev_id
    FROM
        public.codes
),
missing_ids AS (
    SELECT
        prev_id + 1 AS missing_id_start,
        id - 1 AS missing_id_end
    FROM
        numbered_codes
    WHERE
        id - prev_id > 1
),
generated_missing_ids AS (
    SELECT
        generate_series(missing_id_start, missing_id_end) AS id,
        ROW_NUMBER() OVER () as rn
    FROM
        missing_ids
),
codes_base AS (
    SELECT
        (FLOOR(RANDOM() * 2147483647) + 1)::TEXT AS code,
        ROW_NUMBER() OVER () as rn
    FROM
        generate_series(1, 100000)
),
unique_codes AS (
    SELECT 
        cb.code,
        cb.rn
    FROM codes_base cb
    LEFT JOIN public.codes c ON cb.code = c.code
    WHERE c.code IS NULL
),
max_id AS (
    SELECT COALESCE(MAX(id), 0) AS max_id FROM public.codes
),
extended_missing_ids AS (
    SELECT
        ROW_NUMBER() OVER () + (SELECT max_id FROM max_id) AS new_id,
        ROW_NUMBER() OVER () as rn
    FROM
        generate_series(1, GREATEST(0, 1000 - (SELECT COUNT(*) FROM generated_missing_ids)))
),
combined_ids AS (
    SELECT id, rn FROM generated_missing_ids
    UNION ALL
    SELECT new_id AS id, rn + (SELECT COUNT(*) FROM generated_missing_ids) AS rn FROM extended_missing_ids
),
limited_unique_codes AS (
    SELECT code, rn
    FROM unique_codes
    LIMIT 1000
)
INSERT INTO public.codes (id, name, code)
SELECT
    c.id AS id,
    'Код ' || l.code AS name,
    l.code
FROM
    limited_unique_codes l
LEFT JOIN
    combined_ids c ON l.rn = c.rn
ORDER BY c.id
LIMIT 1000
ON CONFLICT DO NOTHING;
