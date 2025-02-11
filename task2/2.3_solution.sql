WITH RECURSIVE
    -- Находим все пропущенные id
    missing_ids AS (
        SELECT gs.num AS id
        FROM generate_series((SELECT min(id) FROM public.codes), (SELECT max(id) FROM public.codes)) AS gs(num)
        WHERE NOT EXISTS (SELECT 1 FROM public.codes WHERE id = gs.num)
    ),
    -- Считаем количество пропущенных id
    missing_count AS (
        SELECT COUNT(*) AS count FROM missing_ids
    ),
    -- Определяем, сколько кодов нужно сгенерировать всего (максимум 1000)
    needed_count AS (
        SELECT LEAST(1000, 1000 + (SELECT count FROM missing_count)) AS count
    ),
    -- Генерируем случайные коды
    potential_codes AS (
        SELECT
          (FLOOR(RANDOM() * 2147483647) + 1)::INT AS candidate_code
        FROM
          generate_series(1, (SELECT count FROM needed_count))
        WHERE
          NOT EXISTS (
            SELECT
              1
            FROM
              public.codes
            WHERE
              code = (FLOOR(RANDOM() * 2147483647) + 1)::TEXT
          )
    ),
        -- Распределяем коды по пропущенным ID (если есть) и новым ID
    assigned_codes AS (
        SELECT 
            (CASE 
                WHEN (SELECT count FROM missing_count) > 0 AND mi.id IS NOT NULL THEN mi.id
                ELSE (SELECT COALESCE(MAX(id), 0) FROM public.codes) + ROW_NUMBER() OVER (ORDER BY pc.candidate_code)
            END) AS target_id,
            pc.candidate_code
        FROM potential_codes pc
        LEFT JOIN (SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn FROM missing_ids) mi ON pc.candidate_code = mi.rn
          LIMIT 1000
    ),
    -- Отбираем только те ID и коды, которых еще нет в таблице
    available_codes AS (
        SELECT
            ac.target_id AS id,
            ac.candidate_code::TEXT AS code
        FROM assigned_codes ac
        WHERE NOT EXISTS (SELECT 1 FROM public.codes c WHERE c.id = ac.target_id OR c.code = ac.candidate_code::TEXT)
        LIMIT 1000
    )
-- Вставляем данные в таблицу
INSERT INTO public.codes (id, code, name)
SELECT
  id,
  code,
  'Код ' || code
FROM
  available_codes
ON CONFLICT (id)
  DO NOTHING;

-- Возвращаем массив добавленных кодов
SELECT array_agg(code) FROM available_codes;




















WITH RECURSIVE
  existing_max AS (
    SELECT COALESCE(MAX(id), 0) AS max_id FROM public.codes
  ),
  -- Генерация недостающих id и кандидатов на новые коды
  missing_ids AS (
    SELECT
      gs.num AS missing_id,
      (FLOOR(RANDOM() * 2147483647) + 1)::INT AS candidate_code
    FROM
      generate_series(
        (SELECT max_id FROM existing_max) + 1,
        (SELECT max_id + 1000 FROM existing_max)
      ) AS gs(num)
    WHERE
      NOT EXISTS (
        SELECT 1
        FROM public.codes
        WHERE code = (FLOOR(RANDOM() * 2147483647) + 1)::TEXT
      )
    LIMIT 1000
  ) 
-- Вставка недостающих данных
INSERT INTO public.codes (id, code, name)
SELECT
  missing_id,
  candidate_code::TEXT,
  'Код ' || candidate_code::TEXT
FROM
  missing_ids
ON CONFLICT (id) DO NOTHING;

SELECT array_agg(code) FROM available_codes;


/*
-- Дозаполнение пропущенных id и генерация кодов (с учетом уникальности)
WITH RECURSIVE
  existing_max AS (
    SELECT coalesce(max(id), 0) AS max_id FROM public.codes
  ),
  needed_count AS (
    SELECT 1000 AS count
  ),
  -- Генерация пропущенных id и кандидатов на новые коды
  missing_ids AS (
    SELECT
      gs.num AS missing_id,
      (FLOOR(RANDOM() * 2147483647) + 1)::INT AS candidate_code
    FROM
      generate_series(
        (
          SELECT
            max_id
          FROM
            existing_max
        ) + 1,
        (
          SELECT
            max_id + (
              SELECT
                count
              FROM
                needed_count
            )
          FROM
            existing_max
        )
      ) AS gs(num)
  ),
  -- Исключаем уже существующие коды
  available_codes AS (
    SELECT
      mi.missing_id AS id,
      mi.candidate_code::TEXT AS code
    FROM
      missing_ids mi
    WHERE
      NOT EXISTS (
        SELECT
          1
        FROM
          public.codes
        WHERE
          code = mi.candidate_code::TEXT
      )
    LIMIT (
      SELECT
        count
      FROM
        needed_count
    )
  ) -- Вставка недостающих данных
INSERT INTO
  public.codes (id, code, name)
SELECT
  id,
  code,
  'Код ' || code
FROM
  available_codes
ON CONFLICT (id)
  DO NOTHING;


/* -- Вывести массив 1000 кодов потенциальных для вставки
WITH RECURSIVE
  existing_max AS (
    SELECT coalesce(max(id), 0) AS max_id FROM public.codes
  ),
  needed_count AS (
    SELECT 1000 AS count
  ),
  -- Генерируем кандидаты на новые id и коды
  candidate_ids AS (
    SELECT
      gs.num AS candidate_id,
      (FLOOR(RANDOM() * 2147483647) + 1)::INT AS candidate_code
    FROM
      generate_series(
        (
          SELECT
            max_id
          FROM
            existing_max
        ) + 1,
        (
          SELECT
            max_id + (
              SELECT
                count
              FROM
                needed_count
            )
          FROM
            existing_max
        )
      ) AS gs(num)
  ),
  -- Исключаем уже существующие коды
  available_codes AS (
    SELECT
      candidate_code::TEXT
    FROM
      candidate_ids
    WHERE
      NOT EXISTS (
        SELECT
          1
        FROM
          public.codes
        WHERE
          code = candidate_code::TEXT
      )
    LIMIT (
      SELECT
        count
      FROM
        needed_count
    )
  ) -- Формируем массив уникальных кодов
SELECT
  array_agg(candidate_code)
FROM
  available_codes;
