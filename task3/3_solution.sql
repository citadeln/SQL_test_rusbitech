-- Вариант 1
DO $$
DECLARE
    _json json := '
        {"products":[{
            "category":"Телевизоры",
            "items":[
                {"brand":"Samsung","size":"55","type":"LED"},
                {"brand":"Samsung","size":"65","type":"OLED"},
                {"brand":"LG","size":"32","type":"IPS"},
                {"brand":"LG","size":"65","type":"OLED"}
            ]
        },{
            "category":"Ноутбуки",
            "items":[
                {"brand":"Lenovo","size":"13","cpu":"Intel"},
                {"brand":"Huawei","size":"15","cpu":"AMD"},
                {"brand":"Asus","size":"14"},
                {"brand":"HP","size":"14"}
            ]
        },{
            "category":"Смартфоны",
            "items":[
                {"brand":"Samsung","size":"4.5","type":"IPS","memory":"3GB"},
                {"brand":"Asus","size":"6.7","type":"IPS"},
                {"brand":"Realme","size":"6.7","type":"AMOLED","memory":"12GB"},
                {"brand":"Huawei","size":"6.7","memory":"12GB"}
            ]
        }]}
    ';
    _output json;
BEGIN
    WITH filtered_items AS (
        SELECT 
            p->>'category' AS category,
            json_agg(i) AS items
        FROM 
            json_array_elements(_json->'products') AS p,
            json_array_elements(p->'items') AS i
        WHERE NOT (
            (i->>'type' = 'OLED' OR i->>'brand' = 'Asus') OR 
            (i->>'type' = 'IPS' AND i->>'brand' <> 'Huawei')
        )
        GROUP BY 
            p->>'category'
    )
    SELECT json_build_object(
        'products', 
        json_agg(
            json_build_object(
                'category', category,
                'items', items
            )
        )
    ) INTO _output
    FROM filtered_items
    WHERE json_array_length(items) > 0; -- исключаем категории без оставшихся элементов

    RAISE INFO 'Результат: %', _output;
END $$;

-- Вариант 2
DO $$
DECLARE
    _json json := '{
        "products": [{
            "category": "Телевизоры",
            "items": [
                {"brand": "Samsung", "size": "55", "type": "LED"},
                {"brand": "Samsung", "size": "65", "type": "OLED"},
                {"brand": "LG", "size": "32", "type": "IPS"},
                {"brand": "LG", "size": "65", "type": "OLED"}
            ]
        }, {
            "category": "Ноутбуки",
            "items": [
                {"brand": "Lenovo", "size": "13", "cpu": "Intel"},
                {"brand": "Huawei", "size": "15", "cpu": "AMD"},
                {"brand": "Asus", "size": "14"},
                {"brand": "HP", "size": "14"}
            ]
        }, {
            "category": "Смартфоны",
            "items": [
                {"brand": "Samsung", "size": "4.5", "type": "IPS", "memory": "3GB"},
                {"brand": "Asus", "size": "6.7", "type": "IPS"},
                {"brand": "Realme", "size": "6.7", "type": "AMOLED", "memory": "12GB"},
                {"brand": "Huawei", "size": "6.7", "memory": "12GB"}
            ]
        }]
    }';
    _output json;
BEGIN
    _output := (
        SELECT json_build_object('products', 
            json_agg(
                json_build_object(
                    'category', p->>'category',
                    'items', (
                        SELECT json_agg(i)
                        FROM json_array_elements(p->'items') AS i
                        WHERE NOT (
                            (i->>'type' = 'OLED' OR i->>'brand' = 'Asus') OR 
                            (i->>'type' = 'IPS' AND i->>'brand' <> 'Huawei')
                        )
                    )
                )
            )
        )
        FROM json_array_elements(_json->'products') AS p
        WHERE (
            SELECT COUNT(*)
            FROM json_array_elements(p->'items') AS i
            WHERE NOT (
                (i->>'type' = 'OLED' OR i->>'brand' = 'Asus') OR 
                (i->>'type' = 'IPS' AND i->>'brand' <> 'Huawei')
            )
        ) > 0 -- Исключаем категории без оставшихся элементов
    );

    RAISE NOTICE 'Результат обработки входного JSON: %', _output;
END $$;
