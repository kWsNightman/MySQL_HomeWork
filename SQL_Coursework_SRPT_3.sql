/*
 * В данном скрипте содержатся тригеры и предстовления его лучше после сгенерированных данных выполнять так как тут есть тригер 
 * на обновление а сгенерированные данные для валидности я чуть обновлял скриптом
 */




-- Проверка на корректность вставки чтобы не было ситуаций когда одна и та же книга была выдана 2 читателям одновременно и не возможность выдать утраченую книгу
delimiter //
DROP TRIGGER IF EXISTS insert_check//
CREATE TRIGGER insert_check BEFORE INSERT ON issuance_tbl
FOR EACH ROW 
BEGIN 
	DECLARE total int;
	DECLARE status varchar(20);
	SELECT count(*) INTO total FROM issuance_tbl it JOIN lib_warehouse lw ON lw.status_book='issued' AND NEW.book_wh_id = lw.id;
	SELECT lw2.status_book INTO status FROM lib_warehouse lw2 WHERE NEW.book_wh_id = lw2.id;
	IF total >= 1 THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ОШИБКА данная книга числится выданной, проверьте обновлен ли статус этой книги на stock';
	END IF;
	IF status = 'lost' THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ОШИБКА данная книга утеряна проверьте данные';
	END IF;
	IF NOT isnull(NEW.return_date) THEN 
		SET NEW.return_date = NULL;
	END IF;
END//
delimiter ;



delimiter //
DROP TRIGGER IF EXISTS after_insert_book_status//
CREATE TRIGGER after_insert_book_status AFTER INSERT ON issuance_tbl
FOR EACH ROW 
BEGIN 
	#Тригер меняющий статус книги на выданный 
	UPDATE lib_warehouse SET status_book = 'issued' WHERE NEW.book_wh_id = lib_warehouse.id ;
END //
delimiter ;




delimiter //
DROP TRIGGER IF EXISTS after_return_upd_book_status//
CREATE TRIGGER after_return_upd_book_status AFTER UPDATE ON issuance_tbl
FOR EACH ROW 
BEGIN 
	DECLARE status varchar(20);
	SELECT lw2.status_book INTO status FROM lib_warehouse lw2 WHERE OLD.book_wh_id = lw2.id;
	#Тригер меняющий статус книги на  stock после обновления даты возврата
	IF status = 'issued' THEN 
		UPDATE lib_warehouse SET status_book = 'stock' WHERE OLD.book_wh_id = lib_warehouse.id ;
	END IF;
END //
delimiter ;



UPDATE issuance_tbl SET return_date = now() WHERE book_wh_id = 7 AND isnull(return_date) 




INSERT INTO `issuance_tbl` 
VALUES (354,1,7,'2016-03-09 13:08:04','2016-04-30','2016-04-30')


-- Представление книг на выдаче 
CREATE OR REPLACE VIEW issuance_view
AS SELECT concat(r.firstname,' ', r.lastname) AS name, r.phone , b.title, it.to_date,lw.status_book,lw.id 
FROM lib_warehouse lw 
JOIN book b ON status_book = 'issued'  AND lw.id_book = b.id
JOIN issuance_tbl it ON lw.id = it.book_wh_id AND isnull(it.return_date) 
LEFT JOIN reader r ON r.id = it.reader_id; 

-- Представление книг на складе 
CREATE OR REPLACE VIEW stock_view
AS SELECT lw.id AS id_lib_book , b.title
FROM lib_warehouse lw 
JOIN book b ON status_book = 'stock'  AND lw.id_book = b.id;

-- Представление утеряных книг 
CREATE OR REPLACE VIEW lost_view
AS SELECT lw.id AS id_lib_book , b.title
FROM lib_warehouse lw 
JOIN book b ON status_book = 'lost'  AND lw.id_book = b.id;




delimiter //
DROP PROCEDURE IF EXISTS loss_book //
CREATE PROCEDURE loss_book(IN id_book int)
BEGIN 	
	# Статус книги на утраченную
	UPDATE lib_warehouse SET status_book = 'lost' WHERE lib_warehouse.id = id_book;
	SELECT concat('Книга теперь считается утраченной ', id_book);
END;
delimiter ;


CALL loss_book(8) ;


delimiter //
DROP PROCEDURE IF EXISTS overdue_due_date //
CREATE PROCEDURE overdue_due_date()
BEGIN 
	# Отоброжение просроченой сдачи книг должнеков
	SELECT name , title , to_date 
	FROM issuance_view iv 
	WHERE to_date < current_date() ;
END;
delimiter ;

CALL overdue_due_date()

delimiter //
DROP PROCEDURE IF EXISTS return_book //
CREATE PROCEDURE return_book(IN id_book int)
BEGIN 	
	# Процедура для возврата книги
	UPDATE issuance_tbl SET return_date = current_date() WHERE book_wh_id = id_book AND isnull(return_date) ;
	SELECT concat('Книга возвращена ', id_book);
END;
delimiter ;

CALL return_book (50)

SELECT count(*) FROM reader r GROUP BY gender ; -- подсчет  по полу читателей

SELECT g2.name, count(*) 
FROM genres_book gb 
LEFT JOIN genres g2 
ON gb.genres_id = g2.id 
GROUP BY gb.genres_id ; -- подсчет книг по жанрам 


SELECT b.title , concat(w.firstname, ' ', w.lastname) AS writer
FROM writers_book wb 
JOIN writers w ON w.id = 1 AND wb.writers_id = w.id 
JOIN book b ON wb.book_id = b.id ; -- Выборка книг по писателю


/*
* Наверноэ та бд вышла медленной и не очевидной так как имеет тригеры да и наверное некоторые таблицы тут 
* не нужны и только делают ее сложнее но на данный этап это наверное максимум мой за данный период времени
* надеюсь это не самая худшая курсовая 
* В общем понятие как работают бд у меня сложилось но быстрота моей работы с бд пока что очень низкая 
* Спасибо вам за курс вы хорошо все обьясняли трудности были только с видео уроками но на вебинарах все становилось понятнее
*/