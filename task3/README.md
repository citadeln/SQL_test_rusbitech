## Task \#3

#### Решение в файле `3_solution.sql`

## Задание
Написать обработку строки JSON

Сформировать два варианта json, исключив из items объекты, где:

    1. type = 'OLED' или brand = 'Asus'
    2. type = 'IPS' и brand <> 'Huawei'

Если в items не останеться ни одного объекта, вся категория должна быть исключена.

Результат присвоить переменной _output и вывести через RAISE INFO.

Желательно написать два разных варианта обработки json.

```
DO $script$
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
    _output json := '{}';
BEGIN
    RAISE INFO 'Результат обработки входного JSON: %', _output;
END;
$script$;
```