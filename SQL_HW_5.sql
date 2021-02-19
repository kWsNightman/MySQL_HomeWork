/* 1)Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался с выбранным пользователем (написал ему сообщений).
 * 2)Подсчитать общее количество лайков, которые получили пользователи младше 10 лет..
 * 3)Определить кто больше поставил лайков (всего): мужчины или женщины. 
 */


-- Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался с выбранным пользователем (написал ему сообщений).
USE vk;
SELECT COUNT(*), FROM_USER_ID, TO_USER_ID FROM MESSAGES
	WHERE TO_USER_ID = 1
	GROUP BY from_user_id
	ORDER BY COUNT(*) DESC
	LIMIT 1;

-- Подсчитать общее количество лайков, которые получили пользователи младше 10 лет..
SELECT count(*)
FROM likes
WHERE user_id IN (
	SELECT id FROM users 
	WHERE id IN (
		SELECT user_id FROM profiles 
		WHERE (TIMESTAMPDIFF(YEAR, birthday, NOW())) < 10
		)
	);

-- Определить кто больше поставил лайков (всего): мужчины или женщины. 
-- Создадим колонку в таблице так как у нас нету данных от какого пользователя лайк
ALTER TABLE likes ADD COLUMN from_user_id bigint NOT NULL;

-- Обновим эту таблицу встывив случайеые числа 
UPDATE likes 
SET from_user_id = FLOOR(1 + (RAND() * 30));

-- Слабочитаемый вариант наверное
SELECT IF (
	(SELECT count(*) 
	FROM likes 
	WHERE from_user_id IN (
		SELECT id 
		FROM users 
		WHERE id IN (
			SELECT user_id 
			FROM profiles 
			WHERE gender = 'm'))) 
	> 
	(SELECT count(*) 
	FROM likes 
	WHERE from_user_id IN (
		SELECT id 
		FROM users 
		WHERE id IN (
			SELECT user_id 
			FROM profiles 
			WHERE gender = 'f'))),
	'Мужчины', 'Женщины') AS 'Больше лайков у';

-- Более читаемый 
SET @m = (SELECT count(*) 
	FROM likes 
	WHERE from_user_id IN (
		SELECT id 
		FROM users 
		WHERE id IN (
			SELECT user_id 
			FROM profiles 
			WHERE gender = 'm')));

SET @f = (SELECT count(*) 
	FROM likes 
	WHERE from_user_id IN (
		SELECT id 
		FROM users 
		WHERE id IN (
			SELECT user_id 
			FROM profiles 
			WHERE gender = 'f')));
			
SELECT IF (@f > @m,'Женщин','Мужчин') AS 'Больше лайков у '