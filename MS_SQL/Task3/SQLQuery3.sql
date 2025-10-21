USE master
/*ОБРАЩЕНИЕ К СИСТЕМНОЙ БАЗЕ SQL СЕРВЕРА
ДЛЯ СОЗДАНИЯ ПОЛЬЗОВАТЕЛЬСКОЙ БАЗЫ ДАННЫХ*/
GO --РАЗДЕЛИТЕЛЬ БАТЧЕЙ (BATH)

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Lagunov'
)
ALTER DATABASE KB301_Lagunov set single_user with rollback immediate
GO
/* ПРОВЕРЯЕМ, СУЩЕСТВУЕТ ЛИ НА СЕРВЕРЕ БАЗА ДАННЫХ
С ИМЕНЕМ [ИМЯ БАЗЫ], ЕСЛИ ДА, ТО ЗАКРЫВАЕМ ВСЕ ТЕКУЩИЕ
 СОЕДИНЕНИЯ С ЭТОЙ БАЗОЙ */

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Lagunov'
)
DROP DATABASE KB301_Lagunov
GO
CREATE DATABASE KB301_Lagunov
GO
-- СОЗДАЕМ БАЗУ ДАННЫХ

USE KB301_Lagunov
GO
/* ПЕРЕХОДИМ К СОЗДАННОЙ БАЗЕ ДАННЫХ ДЛЯ ПОСЛЕДУЮЩЕЙ РАБОТЫ С НЕЙ 
ИЛИ С ЭТИХ КОМАНД ПРОДОЛЖАЕМ РАБОТУ С БАЗОЙ ДАННЫХ ЕСЛИ ОНА
 УЖЕ СУЩЕСТВУЕТ НА СЕРВЕРЕ */

CREATE SCHEMA Посты 
GO

CREATE TABLE KB301_Lagunov.Посты.regions_aux
( 
	region_code tinyint NOT NULL,
	ex_region_code smallint NOT NULL
	CONSTRAINT PK_id_ex_reg PRIMARY KEY (ex_region_code)
)
GO

CREATE PROCEDURE Fill_regions_aux
AS
BEGIN
	DECLARE @cur CURSOR, @i tinyint
	SET @cur = CURSOR
	FOR SELECT reg.region_code FROM KB301_Lagunov.Посты.regionsCSV reg
	OPEN @cur
	FETCH NEXT FROM @cur INTO @i
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO KB301_Lagunov.Посты.regions_aux
			VALUES
			(@i, 100 + @i),
			(@i, 200 + @i),
			(@i, 700 + @i)

		FETCH NEXT FROM @cur INTO @i
	END
END
GO 

CREATE PROCEDURE Clean_Main
AS
BEGIN
	DELETE KB301_Lagunov.Посты.main
	DELETE KB301_Lagunov.Посты.auto_status
END

CREATE TABLE KB301_Lagunov.Посты.auto_status
(
	number nvarchar(18) NOT NULL,
	id_status tinyint NOT NULL
	CONSTRAINT PK_number PRIMARY KEY (number)
)
GO
DROP TABLE  KB301_Lagunov.Посты.auto_status
GO

CREATE TABLE KB301_Lagunov.Посты.status_list
(
	id_status tinyint NOT NULL,
	status_name nvarchar(30) NOT NULL
	CONSTRAINT PK_id_status PRIMARY KEY (id_status)
)
GO

INSERT INTO KB301_Lagunov.Посты.status_list
  VALUES 
  (0, N'Прочие'),
  (1, N'Транзитные'),
  (2, N'Иногородние'),
  (3, N'Местные')

CREATE TABLE KB301_Lagunov.Посты.main
(
	GAI_post_number tinyint NOT NULL, 
	number nvarchar(18) NOT NULL,
	travel_time smalldatetime NOT NULL,
	direction BIT NOT NULL
	CONSTRAINT PK_main PRIMARY KEY (GAI_post_number, number, travel_time, direction)
)
GO

DROP TABLE  KB301_Lagunov.Посты.main
GO
DROP TABLE  KB301_Lagunov.Посты.auto_status
GO

ALTER TABLE KB301_Lagunov.Посты.main ADD 
	CONSTRAINT chk_number CHECK (
	(((main.number LIKE N'[АВЕКМНОРСТУХ][1-9][0-9][0-9][АВЕКМНОРСТУХ][АВЕКМНОРСТУХ][0-9][0-9]' )OR 
	(main.number LIKE N'[АВЕКМНОРСТУХ][0-9][1-9][0-9][АВЕКМНОРСТУХ][АВЕКМНОРСТУХ][0-9][0-9]') OR 
	(main.number LIKE N'[АВЕКМНОРСТУХ][0-9][0-9][1-9][АВЕКМНОРСТУХ][АВЕКМНОРСТУХ][0-9][0-9]')) and LEN(main.number) = 8) OR
	(((main.number LIKE N'[АВЕКМНОРСТУХ][1-9][0-9][0-9][АВЕКМНОРСТУХ][АВЕКМНОРСТУХ][127][0-9][0-9]') OR 
	(main.number LIKE N'[АВЕКМНОРСТУХ][0-9][1-9][0-9][АВЕКМНОРСТУХ][АВЕКМНОРСТУХ][127][0-9][0-9]') OR 
	(main.number LIKE N'[АВЕКМНОРСТУХ][0-9][0-9][1-9][АВЕКМНОРСТУХ][АВЕКМНОРСТУХ][127][0-9][0-9]')) and LEN(main.number) = 9)
	)
GO

ALTER TABLE KB301_Lagunov.Посты.main   
DROP CONSTRAINT chk_number  
GO 

SELECT name 
FROM sys.check_constraints 
WHERE parent_object_id = OBJECT_ID('KB301_Lagunov.Посты.main')

EXEC Fill_regions_aux
go

SELECT *  FROM KB301_Lagunov.Посты.regions_aux
go

CREATE TRIGGER Посты.insert_new_auto ON KB301_Lagunov.Посты.main INSTEAD OF INSERT 
AS
	DECLARE @last_direction BIT, @last_travel_time SMALLDATETIME, @last_GAI_post_number TINYINT, @new_direction BIT, @new_travel_time SMALLDATETIME, @new_GAI_post_number TINYINT, @new_number NVARCHAR(18), @region SMALLINT, @cursor CURSOR
	SET @cursor = CURSOR FOR
	SELECT direction, travel_time, GAI_post_number, number FROM inserted
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @new_direction, @new_travel_time, @new_GAI_post_number, @new_number
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF LEN(@new_number) = 8
		BEGIN
			BEGIN TRY
				SELECT @region = CAST(SUBSTRING(@new_number, 7, 2) AS SMALLINT)
			END TRY
			BEGIN CATCH
				PRINT N'Неверный формат номера'
				FETCH NEXT FROM @cursor INTO @new_direction, @new_travel_time, @new_GAI_post_number, @new_number
				CONTINUE
			END CATCH
		END
		ELSE
		BEGIN
			BEGIN TRY
				SELECT @region = CAST(SUBSTRING(@new_number, 7, 3) AS SMALLINT)
			END TRY
			BEGIN CATCH
				PRINT N'Неверный формат номера'
				FETCH NEXT FROM @cursor INTO @new_direction, @new_travel_time, @new_GAI_post_number, @new_number
				CONTINUE
			END CATCH
		END
		IF (NOT EXISTS (SELECT regionsCSV.region_code FROM regionsCSV WHERE regionsCSV.region_code = @region) AND NOT EXISTS (SELECT regions_aux.ex_region_code FROM regions_aux WHERE regions_aux.ex_region_code = @region))
		BEGIN
			PRINT N'Неверный формат номера'
			FETCH NEXT FROM @cursor INTO @new_direction, @new_travel_time, @new_GAI_post_number, @new_number
			CONTINUE
		END
		SELECT TOP 1 @last_travel_time = mn.travel_time FROM KB301_Lagunov.Посты.main mn WHERE mn.number = @new_number ORDER BY mn.travel_time DESC
		SELECT TOP 1 @last_direction = mn.direction FROM KB301_Lagunov.Посты.main mn WHERE mn.number = @new_number ORDER BY mn.travel_time DESC
		SELECT TOP 1 @last_GAI_post_number = mn.GAI_post_number FROM KB301_Lagunov.Посты.main mn WHERE mn.number = @new_number ORDER BY mn.travel_time DESC
		IF @last_travel_time IS NOT NULL
		BEGIN
			IF @new_direction = @last_direction
			BEGIN
				PRINT N'Машина два раза подряд въехала/выехала'
			END
			ELSE
			BEGIN
				IF @new_travel_time < @last_travel_time OR DATEDIFF(minute, @last_travel_time, @new_travel_time) < 5
				BEGIN
					PRINT N'Невалидное время проезда'
				END
				ELSE
				BEGIN
					INSERT INTO KB301_Lagunov.Посты.main
					VALUES
					(@new_GAI_post_number, @new_number, @new_travel_time, @new_direction)
					IF @region = 66
					BEGIN
						IF @last_direction = 1 and @new_direction = 0
						BEGIN
							UPDATE KB301_Lagunov.Посты.auto_status SET auto_status.id_status = 3 WHERE auto_status.number = @new_number
						END
						ELSE
						BEGIN
							IF	@last_GAI_post_number = @new_GAI_post_number
							BEGIN
								UPDATE KB301_Lagunov.Посты.auto_status SET auto_status.id_status = 2 WHERE auto_status.number = @new_number
							END
							ELSE
							BEGIN
								UPDATE KB301_Lagunov.Посты.auto_status SET auto_status.id_status = 0 WHERE auto_status.number = @new_number
							END
						END
					END
					ELSE
					BEGIN
						IF @last_direction = 0 and @new_direction = 1
						BEGIN
							IF @last_GAI_post_number = @new_GAI_post_number
							BEGIN
								UPDATE KB301_Lagunov.Посты.auto_status SET auto_status.id_status = 2 WHERE auto_status.number = @new_number
							END
							ELSE
							BEGIN
								UPDATE KB301_Lagunov.Посты.auto_status SET auto_status.id_status = 1 WHERE auto_status.number = @new_number
							END
						END
						ELSE
						BEGIN
							UPDATE KB301_Lagunov.Посты.auto_status SET auto_status.id_status = 0 WHERE auto_status.number = @new_number
						END
					END
				END
			END
		END
		ELSE
		BEGIN
			INSERT INTO KB301_Lagunov.Посты.main
			VALUES
			(@new_GAI_post_number, @new_number, @new_travel_time, @new_direction)
			INSERT INTO KB301_Lagunov.Посты.auto_status
				VALUES 
					(@new_number, 0)
		END
		FETCH NEXT FROM @cursor INTO @new_direction, @new_travel_time, @new_GAI_post_number, @new_number
	END
	CLOSE @cursor;

DROP TRIGGER Посты.insert_new_auto

CREATE VIEW Посты.main_view
 AS
	SELECT main.GAI_post_number AS N'Пост ГАИ', 
	main.number AS N'Номер', 
	-- Извлечение основного или расширенного регионального кода
	COALESCE(
		-- Если длина номера 8 символов, берем последние 2 цифры
		CASE 
			WHEN LEN(main.number) = 8 
			THEN CAST(SUBSTRING(main.number, 7, 2) AS SMALLINT) 
		END,
		-- Если длина номера 9 символов, проверяем корректность первой цифры, берем последние 3 цифры
		CASE 
			WHEN LEN(main.number) = 9 
				 --AND LEFT(SUBSTRING(main.number, 7, 3), 1) IN ('1', '2', '7')
			THEN CAST(SUBSTRING(main.number, 7, 3) AS SMALLINT)
		END
	) AS N'Код региона',
	COALESCE(
		regions.region_name,
		aux_regions.region_name
	) AS N'Название региона',
	main.travel_time AS N'Время проезда', 
	N'Направление движения' = CASE main.direction 
	WHEN 0 THEN N'Въезд' WHEN 1 THEN N'Выезд' END, 
	st_ls.status_name AS N'Статус автомобиля' 

	FROM KB301_Lagunov.Посты.main AS main
	JOIN KB301_Lagunov.Посты.auto_status au_st
	ON main.number = au_st.number
	JOIN KB301_Lagunov.Посты.status_list st_ls
	ON au_st.id_status = st_ls.id_status
	LEFT JOIN KB301_Lagunov.Посты.regionsCSV AS regions
	ON CAST(SUBSTRING(main.number, 7, CASE WHEN LEN(main.number) = 8 THEN 2 ELSE 3 END) AS SMALLINT) = regions.region_code
	-- Соединение с вспомогательной таблицей регионов (regions_aux)
	LEFT JOIN KB301_Lagunov.Посты.regions_aux AS aux
	ON CAST(SUBSTRING(main.number, 7, CASE WHEN LEN(main.number) = 8 THEN 2 ELSE 3 END) AS SMALLINT) = aux.ex_region_code
	LEFT JOIN KB301_Lagunov.Посты.regionsCSV AS aux_regions
	ON aux.region_code = aux_regions.region_code
DROP VIEW Посты.main_view

CREATE VIEW Посты.main_only_last_travel_view
 AS
	SELECT mn.GAI_post_number AS N'Пост ГАИ', 
	mn.number AS N'Номер',
	mn.travel_time AS N'Время проезда', 
	N'Направление движения' = CASE mn.direction 
	WHEN 0 THEN N'Въезд' WHEN 1 THEN N'Выезд' END

	FROM KB301_Lagunov.Посты.main AS mn
	JOIN (
		SELECT main.number, MAX(main.travel_time) AS LastTravelTime
		FROM KB301_Lagunov.Посты.main
		GROUP BY main.number
	) AS LastPass
	ON mn.number = LastPass.number AND mn.travel_time = LastPass.LastTravelTime;


INSERT INTO KB301_Lagunov.Посты.main
  VALUES 
  (1, N'А122ВА66', '2024-10-10 14:49:10', 1),
  (1, N'В111ВТ166', '2024-11-10 15:40:10', 1),
  (1, N'А122ВА66', '2024-10-10 15:10:10', 0)

 SELECT * FROM KB301_Lagunov.Посты.main
 SELECT * FROM KB301_Lagunov.Посты.auto_status

EXEC Clean_Main
go


Go
DROP VIEW Посты.main_view
GO

SELECT * FROM Посты.regionsCSV
GO

EXEC Clean_Main
GO

--Тесты
--1) Попытка вставки записи с невалидным номером

SELECT * FROM Посты.main_view
GO

INSERT INTO KB301_Lagunov.Посты.main           --В номере есть "неправильные" кириллические буквы
  VALUES 
  (1, N'Г222АА166', '2024-10-10 15:00:00', 1)
go

SELECT * FROM Посты.main_view
GO

SELECT * FROM Посты.main_view
GO

INSERT INTO KB301_Lagunov.Посты.main           --Не соблюдается формат номера
  VALUES 
  (1, N'Р1В2BВ66', '2024-10-10 15:00:00', 1)
go

SELECT * FROM Посты.main_view
GO

SELECT * FROM Посты.main_view
GO

INSERT INTO KB301_Lagunov.Посты.main           --Не существует в России региона с кодом 99
  VALUES 
  (1, N'Р122BВ99', '2024-10-10 15:00:00', 1)
go

SELECT * FROM Посты.main_view
GO


--2) Попытка вставки записи с номером автомобиля, который уже въезжал/выезжал в/из город(а) и не может сделать это второй раз

SELECT * FROM Посты.main_view
GO

INSERT INTO KB301_Lagunov.Посты.main           
  VALUES 
  (1, N'А122ВА66', '2024-10-10 15:20:00', 0)
go

SELECT * FROM Посты.main_view
GO

--3) Попытка вставки записи с временем проезда автомобиля, которое отличается от времени последнего проезда этого же автомобиля меньше чем на 5 минут
SELECT * FROM Посты.main_view
GO

INSERT INTO KB301_Lagunov.Посты.main           
  VALUES 
  (1, N'А122ВА66', '2024-10-10 15:14:00', 1)  --Последний раз проезжал в 10 минут четвертого
go

SELECT * FROM Посты.main_view
GO

--4) Демонстрация присвоения статуса автомобилю

SELECT * FROM Посты.main_view
GO

INSERT INTO KB301_Lagunov.Посты.main           
  VALUES 
  (1, N'А999АА22', '2024-10-10 15:10:00', 0)  --Сделаем транзитный автомобиль
go

SELECT * FROM Посты.main_view WHERE [Номер] = N'А999АА22'
GO

INSERT INTO KB301_Lagunov.Посты.main           
  VALUES 
  (2, N'А999АА22', '2024-10-10 15:20:00', 1)  --Сделаем транзитный автомобиль
go

SELECT * FROM Посты.main_view WHERE [Номер] = N'А999АА22'
GO

INSERT INTO KB301_Lagunov.Посты.main           
  VALUES 
  (1, N'В999ВВ66', '2024-10-10 15:10:00', 1)  --Сделаем местный автомобиль (местные - те, которые зарегистрированы в Свердловской области)
go

SELECT * FROM Посты.main_view WHERE [Номер] = N'В999ВВ66'
GO

INSERT INTO KB301_Lagunov.Посты.main           
  VALUES 
  (2, N'В999ВВ66', '2024-10-10 15:20:00', 0)  --Сделаем местный автомобиль (местные - те, которые зарегистрированы в Свердловской области)
go

SELECT * FROM Посты.main_view WHERE [Номер] = N'В999ВВ66'
GO

INSERT INTO KB301_Lagunov.Посты.main           
  VALUES 
  (1, N'Е999ЕЕ122', '2024-11-10 15:10:00', 0)  --Сделаем иногородний автомобиль
go

SELECT * FROM Посты.main_view WHERE [Номер] = N'Е999ЕЕ122'
GO

INSERT INTO KB301_Lagunov.Посты.main           
  VALUES 
  (1, N'Е999ЕЕ122', '2024-11-10 15:20:00', 1)  --Сделаем иногородний автомобиль
go

SELECT * FROM Посты.main_view WHERE [Номер] = N'Е999ЕЕ122'
GO

INSERT INTO KB301_Lagunov.Посты.main           
  VALUES 
  (1, N'Е999ЕЕ122', '2024-11-10 15:30:00', 0)  --Сделаем иногородний автомобиль "прочим"
go

SELECT * FROM Посты.main_view WHERE [Номер] = N'Е999ЕЕ122'
GO 

--5) Извлечение всех записей с проездами автомобилей, которые зарегистрированы в Свердловский области

SELECT * FROM Посты.main_view WHERE [Название региона] = N'Свердловская область'
GO

--6) Извлечение записей проездов за определенную дату

SELECT * FROM Посты.main_view WHERE CONVERT(DATE, [Время проезда]) = '2024-10-10'
GO

--7) Извлечение записей проездов автомобилей категории "Местные"
SELECT * FROM Посты.main_view WHERE [Статус автомобиля] = N'Местные'
GO

--8) Последний проезд каждого автомобиля
SELECT 
    mv.[Пост ГАИ], 
    mv.[Номер], 
    mv.[Время проезда], 
    mv.[Направление движения]
FROM KB301_Lagunov.Посты.main_view mv
JOIN (
    SELECT [Номер], MAX([Время проезда]) AS LastTravelTime
    FROM KB301_Lagunov.Посты.main_view
    GROUP BY [Номер]
) AS LastPass
ON mv.[Номер] = LastPass.[Номер] AND mv.[Время проезда] = LastPass.LastTravelTime;

SELECT * FROM Посты.main_only_last_travel_view
	