
/*
INSERT INTO
orders(user_id)
VALUES
	(1), -- Геннадий
	(3), -- Александр
	(8); -- Олег


INSERT INTO
	orders_products(order_id, product_id)
VALUES
	(1, 1),
	(1, 1);


-- товары заказанные Василием
INSERT INTO
	orders_products(order_id, product_id)
VALUES
	(1, 1),
	(1, 2);


-- товары заказанные Александром
INSERT INTO
	orders_products(order_id, product_id)
VALUES
	(2, 1),
	(2, 2);


-- товары заказанные Олегом
INSERT INTO
	orders_products(order_id, product_id, total)
VALUES
	(4, 1, 1),
	(4, 4, 3),
	(4, 5, 2);
*/	

-- Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

SELECT 
	u.id 'Ид юзера', 
	name,
	o.id 'Ид заказа'
FROM users u 
RIGHT JOIN orders o ON u.id = o.user_id ;




-- Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT 
	p.id,
	p.name,
	c.name
FROM products p
JOIN catalogs c ON p.catalog_id = c.id;

/*
CREATE TABLE IF NOT EXISTS flights(
 	id SERIAL PRIMARY KEY,
 	`from` VARCHAR(50) NOT NULL COMMENT 'en', 
	`to` VARCHAR(50) NOT NULL COMMENT 'en'
);

CREATE TABLE  IF NOT EXISTS cities(
	label VARCHAR(50) PRIMARY KEY COMMENT 'en', 
 	name VARCHAR(50) COMMENT 'ru'
);

ALTER TABLE flights
ADD CONSTRAINT fk_from_label
FOREIGN KEY(`from`)
REFERENCES cities(label);

ALTER TABLE flights
ADD CONSTRAINT fk_to_label
FOREIGN KEY(`to`)
REFERENCES cities(label);

INSERT INTO cities VALUES
	('Moscow', 'Москва'),
 	('Saint Petersburg', 'Санкт-Петербург'),
 	('Omsk', 'Омск'),
 	('Tomsk', 'Томск'),
 	('Ufa', 'Уфа');

INSERT INTO flights VALUES
 	(NULL, 'Moscow', 'Saint Petersburg'),
 	(NULL, 'Saint Petersburg', 'Omsk'),
 	(NULL, 'Omsk', 'Tomsk'),
 	(NULL, 'Tomsk', 'Ufa'),
 	(NULL, 'Ufa', 'Moscow');
*/

-- (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.

SELECT 
	f.id,
	c_f.name 'from',
	c_t.name 'to'
FROM flights f
LEFT JOIN cities c_f
ON 
	f.`from` = c_f.label 
LEFT JOIN cities c_t
ON 
	f.`to` = c_t.label;


