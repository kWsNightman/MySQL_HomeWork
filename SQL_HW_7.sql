/*1.
 * В базе данных shop и sample присутствуют одни и те же таблицы, 
 * учебной базы данных. Переместите запись id = 1 из таблицы shop.users 
 * в таблицу sample.users. Используйте транзакции.
 */
DROP DATABASE IF EXISTS sample;
CREATE DATABASE sample;
USE sample;

DROP TABLE IF EXISTS users;
CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) COMMENT 'Имя покупателя',
	birthday_at DATE COMMENT 'Дата рождения',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

START TRANSACTION;
INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
DELETE FROM shop.users WHERE id = 1;
COMMIT;

SELECT * FROM sample.users AS sample;

SELECT * FROM shop.users AS users;

/*2.
 * Создайте представление, которое выводит название name 
 * товарной позиции из таблицы products и соответствующее 
 * название каталога name из таблицы catalogs.
 */

CREATE OR REPLACE VIEW prod_catal (prod_name, catalogs) AS 
SELECT p.name, cat.name
FROM shop.products p
LEFT JOIN shop.catalogs cat
ON p.catalog_id = cat.id;

SELECT * FROM prod_catal;

/*3.
 * по желанию) Пусть имеется таблица с календарным полем created_at. 
 * В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', 
 * '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, 
 * который выводит полный список дат за август, выставляя в соседнем поле значение 1, 
 * если дата присутствует в исходном таблице и 0, если она отсутствует.
 */
DROP TABLE IF EXISTS date_tbl;
CREATE TABLE date_tbl (
	created_at DATE
);

INSERT INTO date_tbl VALUES
	('2018-08-01'),
	('2018-08-04'),
	('2018-08-16'),
	('2018-08-14'),
	('2018-08-15'),
	('2018-08-18'),
	('2018-08-17');

SELECT 
	days_period.selected_day AS days,
	(SELECT EXISTS(SELECT * FROM date_tbl WHERE created_at = days)) AS has_already
FROM -- Генерацию дат нашел в интернете но как она работает до конца не понял 
	(SELECT v.* FROM 
		(SELECT ADDDATE('1970-01-01',t4.i*10000 + t3.i*1000 + t2.i*100 + t1.i*10 + t0.i) selected_day FROM
			(SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t0,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t4) v
	WHERE selected_day BETWEEN '2018-08-01' AND '2018-08-31') AS days_period;

/*4.
 * (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
 * Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
 */
DELETE FROM sample.date_tbl
WHERE created_at NOT IN (
	SELECT *
	FROM (
		SELECT *
		FROM sample.date_tbl
		ORDER BY created_at DESC
		LIMIT 5
	) AS last_5
) ORDER BY created_at DESC;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------

/*1.
 * Создайте двух пользователей которые имеют доступ к базе данных shop. 
 * Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
 * второму пользователю shop — любые операции в пределах базы данных shop.
 */
CREATE USER shop_read IDENTIFIED BY '123'; -- создаем пользователей
CREATE USER shop_all IDENTIFIED BY '123';
GRANT SELECT ON shop.* TO shop_read; -- даем пользовотелю на чтение shop
GRANT ALL ON shop.* TO shop_all; -- а этому на все операции с shop

/*2.
 * (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, 
 * содержащие первичный ключ, имя пользователя и его пароль. 
 * Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. 
 * Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, 
 * мог бы извлекать записи из представления username.
 */
CREATE TABLE accounts (
	id serial PRIMARY KEY,
	name varchar(100),
	`password` int
);

CREATE VIEW username (user_id, user_name)AS 
SELECT a.id, a.name
FROM accounts a;


INSERT INTO accounts(name,`password`) VALUES
	('alex','12345656');

CREATE USER user_read IDENTIFIED BY '123';
GRANT SELECT ON sample.username to user_read ;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------	

/*1.
 * Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
 * С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
 * с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
 * с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
 */
delimiter //
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello()
RETURNS varchar(100) NOT DETERMINISTIC 
BEGIN 
	IF(CURTIME() BETWEEN '06:00:00' AND '12:00:00') THEN
		RETURN 'Доброе утро';
	ELSEIF(CURTIME() BETWEEN '12:00:00' AND '18:00:00') THEN
		RETURN 'Добрый день';
	ELSEIF(CURTIME() BETWEEN '18:00:00' AND '00:00:00') THEN
		RETURN 'Добрый вечер';
	ELSE
		RETURN 'Доброй ночи';
	END IF;
END//
delimiter ;
SELECT hello();

/*2.
 * В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
 * Допустимо присутствие обоих полей или одно из них. 
 * Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
 * Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
 * При попытке присвоить полям NULL-значение необходимо отменить операцию.
 */
delimiter //
DROP TRIGGER IF EXISTS null_chek_prod//
CREATE TRIGGER null_chek_prod BEFORE INSERT ON shop.products
FOR EACH ROW
BEGIN 
	IF (isnull(NEW.name) AND isnull(NEW.desription)) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT  = 'NULL in both fields!';
	END IF;
END//
delimiter ;

INSERT INTO products (name, desription, price, catalog_id)
VALUES (NULL, NULL, 5000, 2); 

/*3.
 * (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
 * Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
 * Вызов функции FIBONACCI(10) должен возвращать число 55.
 */

delimiter //
DROP FUNCTION IF EXISTS FIBONACCI//
CREATE FUNCTION FIBONACCI(numbers int)
RETURNS int DETERMINISTIC 
BEGIN 
	DECLARE num int DEFAULT 2;
	DECLARE fib_1 int DEFAULT 0;
	DECLARE fib_2 int DEFAULT 1;
	DECLARE fib_3 int DEFAULT 0;
	DECLARE res int DEFAULT 0;
	IF (numbers = 0) THEN 
		RETURN 0;
	ELSEIF (numbers = 1) THEN 
		RETURN 1;
	ELSE 
		WHILE num <= numbers DO
			SET fib_3 = fib_2;
			SET res = fib_1 + fib_2;
			SET num = num + 1;
			SET fib_1 = fib_3;
			SET fib_2 = res;
		END WHILE;
	END IF;
	RETURN res;
END//
delimiter ;

SELECT FIBONACCI(10);









