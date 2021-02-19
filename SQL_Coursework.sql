
















/*	

SELECT concat(r.firstname,' ', r.lastname),lw.id_book, b.title, it.to_date 
FROM lib_warehouse lw 
JOIN book b ON lw.id_book = b.id AND status_book = 'issued'
JOIN issuance_tbl it ON b.id = it.book_id 
JOIN reader r ON r.id = it.reader_id 

-- Проверка на корректность вставки чтобы не было ситуаций когда одна и та же книга была выдана 2 читателям одновременно
delimiter //
DROP TRIGGER IF EXISTS insert_check//
CREATE TRIGGER insert_check BEFORE INSERT ON issuance_tbl
FOR EACH ROW 
BEGIN 
	DECLARE total int;
	SELECT count(*) INTO total FROM issuance_tbl it JOIN lib_warehouse lw ON lw.status_book='issued' AND NEW.book_wh_id = lw.id;
	IF total >= 1 THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ОШИБКА данная книга числится выданной, проверьте обновлен ли статус этой книги на stock';
	END IF;
END//
delimiter ;

b.id = lw.id_book 

FROM lib_warehouse lw  
RIGHT  JOIN book b ON lw.status_book = 'issued'
LEFT JOIN reader r ON r.id = it.reader_id 
JOIN issuance_tbl it;*/


