/*
 * Эта база библиотеки и выдачи книг, я уверен что тут много чего надо доробатывать
 * но я уже начинаю сам путаться в ней. Хотел больше функционала в нее запихнуть но амбиции выше возможностей на данном этапе
 * Задумывалось регистрация зарезервированых книг но я бы не успел походу
 * На данный момент функционал ее это содержание название книг их страниц и авторов так же жанров
 * Пытался реализовать некоторые проверки валидности данных но еще много чего можно доделать 
 * Есть три представления 
 * Пытался сделать эту бд автоматизированной чуть возможно просто себе усложнил задачу и так не делается
 * В этом скрипте содержатся описания таблиц и их создание его выполнять первым
 */




DROP DATABASE IF EXISTS library;
CREATE DATABASE library;
USE library;

DROP TABLE IF EXISTS genres;
CREATE TABLE genres(
	id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	name varchar(100) UNIQUE NOT NULL COMMENT 'Название жанра'
)COMMENT 'Жанры';

-- Решил создать таблицу со странами так как подумал что и в писателях и в издателях возможен столбец страны и чтобы не дублировать данные 
DROP TABLE IF EXISTS country;
CREATE TABLE country(
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY, -- TINYINT UNSIGNED потому что количество стран 197 в мире и не должно привысить лимит 0-255 и меньше занимает памяти
	name_country varchar(100) UNIQUE NOT NULL COMMENT 'Страна'
) COMMENT 'Страны';

DROP TABLE IF EXISTS writers;
CREATE TABLE writers(
	id serial PRIMARY KEY,
	firstname varchar(50) NOT NULL COMMENT 'Имя автора',
	lastname varchar(50) NOT NULL COMMENT'Фамилия автора',
	gender enum('f','m') COMMENT 'Пол автора',
	country_id TINYINT UNSIGNED NOT NULL COMMENT 'Страна автора', -- TINYINT UNSIGNED потому что количество стран 197 в мире и не должно привысить лимит 0-255
	FOREIGN KEY (country_id) REFERENCES country(id),
	KEY first_last_name_writer (firstname, lastname),
	UNIQUE(firstname, lastname)
)COMMENT 'Авторы';

DROP TABLE IF EXISTS publisher;
CREATE TABLE publisher(
	id serial PRIMARY KEY,
	name varchar (255) NOT NULL  COMMENT 'Имя издательства',
	address TEXT COMMENT 'Адрес издателя',
	country_id TINYINT UNSIGNED NOT NULL COMMENT 'Страна автора',
	FOREIGN KEY (country_id) REFERENCES country(id),
	UNIQUE(name, address(50)) -- Возможно что под одним названием издательство быть в разных адресах
) COMMENT 'Издатели';

DROP TABLE IF EXISTS book;
CREATE TABLE book(
	id SERIAL PRIMARY KEY,
	title varchar(255) NOT NULL COMMENT 'Название книги',
	pages SMALLINT UNSIGNED COMMENT 'Количество страниц',
	publisher_id BIGINT UNSIGNED COMMENT 'Ид издательства',
	price SMALLINT UNSIGNED COMMENT 'Цена книги',
	currency ENUM('USD','EURO','RUB') COMMENT 'Валюта',
	print_date DATE COMMENT 'Дата печати',
-- number_copies SMALLINT UNSIGNED NOT NULL COMMENT 'Количество экземпляров',
	FOREIGN KEY (publisher_id) REFERENCES publisher(id),
	UNIQUE(title,print_date), -- На случай если переиздавалась книга
	INDEX (title)
) COMMENT 'Книги ';

DROP TABLE IF EXISTS genres_book;
CREATE TABLE genres_book(
	genres_id SMALLINT UNSIGNED NOT NULL COMMENT 'Ид жанра',
	book_id BIGINT UNSIGNED NOT NULL COMMENT 'Ид книги',
	FOREIGN KEY (genres_id) REFERENCES genres(id),
	FOREIGN KEY (book_id) REFERENCES book(id),
	PRIMARY KEY (genres_id,book_id) -- Чтобы не было повторений 
) COMMENT 'Жанры книги'; -- Создал эту таблицу так как возможно что у книги может быть не один жанр 

DROP TABLE IF EXISTS writers_book;
CREATE TABLE writers_book(
	writers_id BIGINT UNSIGNED NOT NULL COMMENT 'Ид автора',
	book_id BIGINT UNSIGNED NOT NULL COMMENT 'Ид книги',
	FOREIGN KEY (writers_id) REFERENCES writers(id),
	FOREIGN KEY (book_id) REFERENCES book(id),
	PRIMARY KEY (writers_id,book_id)
) COMMENT 'Авторы книги'; -- Так же у одной книги может быть несколько авторов

DROP TABLE IF EXISTS reader;
CREATE TABLE reader(
	id serial PRIMARY KEY,
	firstname varchar(50) NOT NULL COMMENT 'Имя читателя',
	lastname varchar(50) NOT NULL COMMENT'Фамилия читателя',
	address TEXT NOT NULL COMMENT 'Адрес читателя',
	phone BIGINT UNSIGNED UNIQUE COMMENT 'Телефон читателя',
	gender enum('f','m') COMMENT 'Пол читателя',
	created_at datetime DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Читатели';

DROP TABLE IF EXISTS lib_warehouse;
CREATE TABLE lib_warehouse(
	id SERIAL PRIMARY KEY,
	id_book bigint UNSIGNED ,
	status_book enum('issued' ,'stock' ,'lost') DEFAULT 'stock' COMMENT 'Статус книги - Выдана, На складе, Утеряна',
	purchased DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (id_book) REFERENCES book(id)
) COMMENT 'Склад библиотеки'; -- Не уверен что стоит было делать эту таблицу так как всю инфу возможно было бы вложить в таблицу book

DROP TABLE IF EXISTS issuance_tbl;
CREATE TABLE issuance_tbl(
	id serial PRIMARY KEY,
	reader_id BIGINT UNSIGNED NOT NULL COMMENT 'Ид читателя',
	book_wh_id BIGINT UNSIGNED NOT NULL COMMENT 'Ид книги из lib_warehouse',
	date_issue DATETIME DEFAULT CURRENT_TIMESTAMP,
	to_date DATE DEFAULT (date_add(date_issue , INTERVAL 1 MONTH)) COMMENT 'Дата до кокого выдана',
	return_date DATETIME DEFAULT NULL  COMMENT 'Дата возврата',
	FOREIGN KEY (reader_id) REFERENCES reader(id),
	FOREIGN KEY (book_wh_id) REFERENCES lib_warehouse(id)
) COMMENT 'Таблица выдачи';