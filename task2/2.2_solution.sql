/*
Не понятны следующие моменты:
- что значит "функция возвращает массив кодов (text[]), доступных для вставки"?
- как определяеется доступны эти коды для вставки или нет?
- куда должна осуществляться вставка? в новую таблицу или текущую?
*/

-- 2.6. Скорость отработки функции можно улучшить с помощью использования индексов

CREATE OR REPLACE FUNCTION get_available_codes(num_codes INT DEFAULT 1)
RETURNS TEXT[] AS $$
DECLARE
    available_codes TEXT[] := '{}';
    current_code INT := 1;
BEGIN
    WHILE array_length(available_codes, 1) < num_codes LOOP
        -- Проверяем, существует ли код в таблице
        IF NOT EXISTS (SELECT 1 FROM public.codes WHERE code = current_code::TEXT) THEN
            available_codes := array_append(available_codes, current_code::TEXT);
        END IF;
        current_code := current_code + 1; -- Увеличиваем код
    END LOOP;
    RETURN available_codes;
END;
$$
LANGUAGE plpgsql;


-- а) поиск и вставка по одному коду в цикле;
DO $$
DECLARE
    new_code TEXT;
BEGIN
    FOR i IN 1..1000 LOOP
        new_code := get_available_codes(1)[1]; -- Получаем один новый код
        INSERT INTO public.codes (code, name) VALUES (new_code, 'Код ' || new_code);
    END LOOP;
END $$;

-- б) поиск и вставка по 100 кодов;
DO $$
DECLARE
    new_codes TEXT[];
BEGIN
    new_codes := get_available_codes(100); -- Получаем 100 новых кодов
    INSERT INTO public.codes (code, name)
    SELECT unnest(new_codes), 'Код ' || unnest(new_codes);
END $$;

-- в) поиск и вставка сразу всех 1000 кодов.
DO $$
DECLARE
    new_codes TEXT[];
BEGIN
    new_codes := get_available_codes(100); -- Получаем 100 новых кодов
    INSERT INTO public.codes (code, name)
    SELECT unnest(new_codes), 'Код ' || unnest(new_codes);
END $$;

TRUNCATE TABLE public.codes;

-- Заполнение таблицы 1,000,000 записей с уникальными кодами
DO $$
DECLARE
    new_codes TEXT[];
BEGIN
    FOR i IN 1..1000 LOOP
        new_codes := get_available_codes(1000); -- Получаем 1000 новых кодов
        INSERT INTO public.codes (code, name)
        SELECT unnest(new_codes), 'Код ' || unnest(new_codes);
    END LOOP;
END $$;