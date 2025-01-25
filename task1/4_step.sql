DO $$
DECLARE
    company_main integer = 1;
BEGIN
    UPDATE company SET type = CASE WHEN id = company_main THEN 'главный' ELSE 'филиал' END;
    UPDATE person SET company = company_main();
    RAISE INFO '%', (SELECT company FROM person LIMIT 1);
END
$$;

/*
Ответ на вопрос "Почему при изменении company_main головная компания у сотрудников меняется только при повторном выполнении оператора DO":

Потому что переменная company_main инициализируется статическим значением (например, 1), которое не обновляется автоматически. Это значение не связано с результатом функции company_main(), которая возвращает актуальный идентификатор главной компании. Следовательно, при выполнении оператора DO отработка функции company_main и далее указание компаний у сотрудников происходит на основе устаревшего значения переменной.
*/

/*
Также в коде есть ещё одна ошибка:

Значение столбца company присваивается результату вызова функции company_main(). Однако функция company_main() не принимает никаких параметров и возвращает значение типа integer. Если функция возвращает NULL или вызывает ошибку, это может привести к проблемам (столбец company имеет ограничение NOT NULL).

Также если функция возвращает NULL, это может привести к логическим ошибкам в приложении или бизнес-логике. Например, если приложение ожидает, что все сотрудники имеют связь с главной компанией (идентификатором), и функция возвращает NULL, это может вызвать сбои в работе приложения или неправильные вычисления, так как приложение не сможет корректно обработать отсутствие данных о компании.
*/


-- Как исправить:

-- Вариант 1, назначать кампанию 'главной' до отработки анонимного блока DO
UPDATE company
SET type = CASE 
    WHEN id = 1 THEN 'главный' 
    ELSE 'филиал' 
END;

DO $$
DECLARE
    company_id integer;
BEGIN
    company_id := company_main();
    UPDATE person SET company = company_id;
    RAISE INFO '%', (SELECT company FROM person LIMIT 1);
END
$$;


-- Вариант 2, использование триггера
CREATE OR REPLACE FUNCTION update_company_and_employees()
RETURNS TRIGGER AS $$
DECLARE
    main_comp integer;
BEGIN
    main_comp := company_main();
    IF NEW.type = 'главный' THEN
        UPDATE person SET company = NEW.id WHERE company != NEW.id;
    END IF;
    RETURN NEW; -- Возвращаем новое значение, если необходимо
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_company_trigger
AFTER INSERT OR UPDATE ON company
FOR EACH ROW EXECUTE FUNCTION update_company_and_employees();

-- пример использования
DO $$
BEGIN
    -- Изменяем запись в таблице company (например, делаем компанию с id = 2 главной)
    UPDATE company SET type = CASE 
        WHEN id = 2 THEN 'главный' 
        ELSE 'филиал'
    END;
    -- триггер автоматически выполнит обновление типов компаний
END $$;

-- Вариант 4, хранимая процедура (но тут тогда функция company_main() не нужна)
CREATE OR REPLACE PROCEDURE company_updating(company_id integer)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE company 
    SET type = CASE 
        WHEN id = company_id THEN 'главный' 
        ELSE 'филиал' 
    END;
    UPDATE person 
    SET company = (SELECT id FROM company WHERE type = 'главный');
END;
$$;
CALL company_updating(2);

-- Вариант 3, использование CTE
WITH updated_company AS (
    UPDATE company SET type = CASE 
        WHEN id = 2 THEN 'главный' 
        ELSE 'филиал' 
    END RETURNING id
)
UPDATE person SET company = (SELECT company_main());
