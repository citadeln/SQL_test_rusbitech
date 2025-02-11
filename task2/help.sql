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
)
SELECT
    generate_series(missing_id_start, missing_id_end) AS id,
    NULL AS column2,
    NULL AS column3
FROM
    missing_ids;
    





WITH
  -- Пронумеровываем строки таблицы public.codes в порядке возрастания id
  numbered_codes AS (
    SELECT
      id,
      LAG(id) OVER (ORDER BY id) AS prev_id
    FROM
      public.codes
  ),
  -- Находим пропущенные id
  missing_ids AS (
    SELECT
      prev_id + 1 AS missing_id_start,
      id - 1 AS missing_id_end
    FROM
      numbered_codes
    WHERE
      id - prev_id > 1
  )
-- Разворачиваем диапазоны пропущенных id в отдельные строки (если есть диапазоны)
SELECT
  id,
  NULL AS column2,
  NULL AS column3
FROM
  missing_ids,
  generate_series(missing_id_start, missing_id_end) AS id;












WITH
  -- Пронумеровываем строки таблицы public.codes в порядке возрастания id
  numbered_codes AS (
    SELECT
      id,
      LAG(id, 1, id - 1) OVER (
        ORDER BY
          id
      ) AS prev_id
    FROM
      public.codes
  ),
  -- Находим пропущенные id
  missing_ids AS (
    SELECT
      prev_id + 1 AS missing_id_start,
      id - 1 AS missing_id_end
    FROM
      numbered_codes
    WHERE
      id - prev_id > 1
  ),
  -- Разворачиваем диапазоны пропущенных id в отдельные строки (если есть диапазоны)
  expanded_missing_ids AS (
    SELECT
      generate_series(missing_id_start, missing_id_end) AS id
    FROM
      missing_ids
  ) -- Выводим результат
SELECT
  id,
  NULL AS column2,
  NULL AS column3
FROM
  expanded_missing_ids;
