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

CREATE SCHEMA Страны 
GO

SELECT * FROM KB301_Lagunov.Страны.Countries
SELECT * FROM KB301_Lagunov.Страны.Cities
SELECT * FROM KB301_Lagunov.Страны.Languages

ALTER TABLE KB301_Lagunov.Страны.Languages ADD 
	CONSTRAINT FK_count_code_for_langs FOREIGN KEY (Код_страны) 
	REFERENCES KB301_Lagunov.Страны.Countries(Код)
GO
ALTER TABLE KB301_Lagunov.Страны.Cities ADD 
	CONSTRAINT FK_count_code_for_cities FOREIGN KEY (Код_страны) 
	REFERENCES KB301_Lagunov.Страны.Countries(Код)
GO
ALTER TABLE KB301_Lagunov.Страны.Countries ADD 
	CONSTRAINT FK_capit_code_for_counts FOREIGN KEY (Код_столицы) 
	REFERENCES KB301_Lagunov.Страны.Cities(Код)
GO
ALTER TABLE KB301_Lagunov.Страны.Cities DROP CONSTRAINT FK_count_code_for_cities


CREATE FUNCTION Страны.fn_GetTotalVNDChange(@PopulationThreshold INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalVNDChange INT;

    SELECT 
        @TotalVNDChange = ABS(SUM(COALESCE(C.ВНД, 0) - COALESCE(C.ВНД_пред, 0)))
    FROM 
        KB301_Lagunov.Страны.Countries C
    JOIN 
        KB301_Lagunov.Страны.Cities CI ON C.Код_столицы = CI.Код
    WHERE 
        CI.Население > @PopulationThreshold;

    RETURN @TotalVNDChange;
END;
GO

--1) Выдать список языков с количеством стран, где есть этот язык, и количеством стран,
--где этот язык официальный.
SELECT 
    L.Название AS N'Язык',
    COUNT(L.Код_страны) AS N'Количество стран',
    SUM(CASE WHEN L.Официальный = 1 THEN 1 ELSE 0 END) AS N'Количество стран с официальным языком'
FROM 
    KB301_Lagunov.Страны.Languages L
GROUP BY 
    L.Название
ORDER BY 
    [Количество стран] DESC;

--2)Определите, на сколько суммарно изменился ВНД стран, у которых население столицы
--превышает 1 000 000 человек. Для тех стран, у которых нет значения ВНД, принять его равным 0.
--В ответе укажите модуль полученного значения.
--(533849)
SELECT 
    ABS(SUM(COALESCE(C.ВНД, 0) - COALESCE(C.ВНД_пред, 0))) AS N'Изменение ВНД'
FROM 
    KB301_Lagunov.Страны.Countries C
JOIN 
    KB301_Lagunov.Страны.Cities CI ON C.Код_столицы = CI.Код
WHERE 
    CI.Население > 1000000;

--3) Создать функцию, которая по количеству человек определяет, на сколько суммарно изменился ВНД стран,
--у которых население столицы превышает количество.
SELECT Страны.fn_GetTotalVNDChange(1000000) AS N'Изменение ВНД';

--4) Определите среднее население стран Европы, в которых наиболее популярный официальный язык
--используют менее 60% населения.
--(2129900)
SELECT 
    AVG(Страны.Население) AS Среднее_население
FROM 
    (SELECT 
        C.Население
     FROM 
        KB301_Lagunov.Страны.Countries C
     JOIN 
        KB301_Lagunov.Страны.Languages L ON C.Код = L.Код_страны
     WHERE 
        C.Континент = 'Europe' 
        AND L.Официальный = 1
     GROUP BY 
        C.Код, C.Население
     HAVING 
        MAX(L.Процент) < 60
    ) AS Страны;

--5) Создать дополнительную таблицу страны_итог (код_страны, count_города, min_населения),
--где count_города – количество городов в данной стране, min_населения – город с наименьшим населением.
--Прописать связи, соответствующие ограничения. Заполнить соответственно таблицу данными
--Создать в таблице с городами триггер, который синхронизирует Cities и страны_итог
--выводит предупреждение.
CREATE TABLE KB301_Lagunov.Страны.страны_итог (
    код_страны varchar(3),
    count_города SMALLINT NOT NULL,
    min_населения INT NOT NULL,
	CONSTRAINT PK_страны_итог_код_страны PRIMARY KEY (код_страны),
    CONSTRAINT FK_страны_итог_код_страны FOREIGN KEY (код_страны) REFERENCES KB301_Lagunov.Страны.Countries(Код)
    ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO KB301_Lagunov.Страны.страны_итог (код_страны, count_города, min_населения)
SELECT 
    C.Код,
    COUNT(CI.Код) AS count_города,
    ISNULL(MIN(CI.Население), 0) AS min_населения -- Если нет городов, устанавливаем население 0
FROM 
    KB301_Lagunov.Страны.Countries C
LEFT JOIN 
    KB301_Lagunov.Страны.Cities CI ON C.Код = CI.Код_страны
GROUP BY 
    C.Код;
SELECT * FROM KB301_Lagunov.Страны.страны_итог



SELECT * FROM KB301_Lagunov.Страны.Cities
DELETE FROM KB301_Lagunov.Страны.Cities WHERE Cities.Название = 'Qandahar'
INSERT INTo KB301_Lagunov.Страны.Cities VALUES (2, 'Konstantinopol', 'AFG', 'Visantia', 1000000)
SELECT * FROM KB301_Lagunov.Страны.страны_итог

CREATE TRIGGER trg_UpdateCountriesSummary
ON KB301_Lagunov.Страны.Cities
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Обновление информации по странам в таблице страны_итог
    MERGE KB301_Lagunov.Страны.страны_итог AS target
    USING (
        -- Собираем актуальную информацию по странам
        SELECT 
            Код_страны,
            COUNT(Код) AS count_города,
            ISNULL(MIN(Население), 0) AS min_населения
        FROM 
            KB301_Lagunov.Страны.Cities
        GROUP BY 
            Код_страны
    ) AS source
    ON target.код_страны = source.Код_страны
    -- Если данные в таблице страны_итог есть, обновляем
    WHEN MATCHED THEN 
        UPDATE SET 
            count_города = source.count_города,
            min_населения = source.min_населения
    -- Если в таблице страны_итог нет записи для страны, добавляем
    WHEN NOT MATCHED THEN 
        INSERT (код_страны, count_города, min_населения)
        VALUES (source.Код_страны, source.count_города, source.min_населения)
    -- Если удалены все города, удаляем запись из страны_итог
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;
END;
GO
/*
--ТРИГГЕР (обновлять или добавлять значения в связанной таблице)
CREATE TRIGGER Страны.Sync
ON KB301_Lagunov.Страны.Cities
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- ОБНОВЛЕНИЕ Count_города В ТАБЛИЦЕ Страны_итог
    UPDATE KB301_Lagunov.Страны.cтраны_итог
    SET Count_города = (
        SELECT COUNT(*)
        FROM KB301_Lagunov.Страны.Cities
        WHERE Cities.Код_страны = KB301_Lagunov.Страны.страны_итог.код_страны
    )
    WHERE Код_страны IN (
        SELECT DISTINCT Код_страны 
        FROM INSERTED
    );

    -- ОБНОВЛЕНИЕ Max_население В ТАБЛИЦЕ Страны_итог
    UPDATE KB301_Lagunov.Страны.[Страны_итог]
    SET min_населения = (
        SELECT MIN(Cities.Население)
        FROM KB301_Lagunov.Страны.Cities
        WHERE Cities.Код_страны = KB301_Lagunov.Страны.страны_итог.код_страны
    )
    WHERE Код_страны IN (
        SELECT DISTINCT Код_страны 
        FROM INSERTED
    );
END;

*/


CREATE PROCEDURE Страны.GetIntervals
AS
BEGIN
	DECLARE @a float,
	@b float,
	@c float,
	@d float,
	@const_for_mixed DECIMAL(10,2),
	@const_for_unlimited DECIMAL(10,2),
	@limit_for_mixed DECIMAL(10,2),
	@intersect_point float,
	@prev_intersect_point float,
	@prev_prev_intersect_point float,
	@midlle INT,
	@cur_tariff_name NVARCHAR(50),
	@cursor CURSOR

	CREATE TABLE #inter_points (
		intersect_point float
	)

	SELECT @const_for_mixed = Tariffs.SubscriptionFee FROM Страны.Tariffs WHERE Tariffs.TariffName = 'Смешанный'
	SELECT @const_for_unlimited = Tariffs.SubscriptionFee FROM Страны.Tariffs WHERE Tariffs.TariffName = 'Безлимитный'
	SELECT @limit_for_mixed = Tariffs.IncludedMinutes FROM Страны.Tariffs WHERE Tariffs.TariffName = 'Смешанный'

	SELECT @a = Tariffs.ExtraMinuteRate FROM Страны.Tariffs WHERE Tariffs.TariffName = 'Без абонентской платы'
	SET @b = 0
	SELECT @c = Tariffs.ExtraMinuteRate FROM Страны.Tariffs WHERE Tariffs.TariffName = 'Смешанный'
	SET @d = @const_for_mixed - @limit_for_mixed * @c
	
	IF (@a != @c)
	BEGIN
		IF (((@d - @b)/(@a - @c)) > @limit_for_mixed)
		BEGIN
			INSERT INTO #inter_points VALUES
				((@d - @b)/(@a - @c))
		END
	END
	
	IF (((@const_for_mixed - @b)/@a) <= @limit_for_mixed AND ((@const_for_mixed - @b)/@a) > 0)
	BEGIN
		INSERT INTO #inter_points VALUES
			((@const_for_mixed - @b)/@a)
	END

	INSERT INTO #inter_points VALUES
		((@const_for_unlimited - @b)/@a)

	IF NOT(@a = @c AND @b = @d)
	BEGIN
		INSERT INTO #inter_points VALUES
			((@const_for_unlimited - @d)/@c)
	END

	INSERT INTO #inter_points VALUES
		(43200)

	CREATE TABLE #Intervals (
		TariffName NVARCHAR(50), -- Название тарифа
		bigining INT,
		ending INT
	);

	SET @cursor = CURSOR FOR SELECT * FROM #inter_points ORDER BY #inter_points.intersect_point ASC
	OPEN @cursor
	SET @prev_intersect_point = 0
	FETCH NEXT FROM @cursor INTO @intersect_point
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @midlle = CAST(@prev_intersect_point + (@intersect_point - @prev_intersect_point)/2 AS INT)
		SELECT @cur_tariff_name = Страны.GetBestTariff(@midlle)
		IF EXISTS (SELECT * FROM #Intervals WHERE #Intervals.TariffName = @cur_tariff_name AND #Intervals.ending = @prev_intersect_point)
		BEGIN
			SET @prev_prev_intersect_point = @prev_intersect_point
			SELECT @prev_intersect_point = #Intervals.bigining FROM #Intervals WHERE #Intervals.TariffName = @cur_tariff_name AND #Intervals.ending = @prev_prev_intersect_point
			DELETE FROM #Intervals WHERE #Intervals.TariffName = @cur_tariff_name AND #Intervals.ending = @prev_prev_intersect_point
		END
		INSERT INTO #Intervals VALUES
			(@cur_tariff_name, CAST(@prev_intersect_point AS DECIMAL(10,2)), CAST(@intersect_point AS INT))
		SET @prev_intersect_point = @intersect_point
		FETCH NEXT FROM @cursor INTO @intersect_point
	END
	CLOSE @cursor
	SELECT #Intervals.TariffName as 'Тариф', CAST(#Intervals.bigining AS nvarchar) + ' - ' + CAST(#Intervals.ending AS nvarchar) as 'Интервал'  FROM #Intervals
	DROP TABLE #inter_points
	DROP TABLE #Intervals
END

DROP PROCEDURE Страны.GetIntervals
go
EXEC Страны.GetIntervals
GO

--4-я лабараторная
CREATE TABLE KB301_Lagunov.Страны.Tariffs (
    TariffName NVARCHAR(50) PRIMARY KEY, -- Название тарифа
    SubscriptionFee DECIMAL(10, 2) NOT NULL, -- Абонентская плата
    IncludedMinutes INT NOT NULL, -- Количество минут, включенных в абонентскую плату
    ExtraMinuteRate DECIMAL(10, 2) NOT NULL -- Стоимость минуты сверх включенных минут
);

INSERT INTO KB301_Lagunov.Страны.Tariffs (TariffName, SubscriptionFee, IncludedMinutes, ExtraMinuteRate)
VALUES 
('Без абонентской платы', 0, 0, 1.5),
('Безлимитный', 1000, 43200, 0), -- Условный предел для безлимита
('Смешанный', 600, 300, 0.5);
GO

INSERT INTO KB301_Lagunov.Страны.Tariffs (TariffName, SubscriptionFee, IncludedMinutes, ExtraMinuteRate)
VALUES 
('Без абонентской платы', 0, 0, 0.75),
('Безлимитный', 400, 43200, 0), -- Условный предел для безлимита
('Смешанный', 200, 300, 2);
GO

DELETE KB301_Lagunov.Страны.Tariffs
GO

CREATE FUNCTION Страны.GetBestTariff (@Minutes INT)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @Minutes <= 0 OR @Minutes >= 43200
    BEGIN
        RETURN N'Недопустимое количество минут.'
    END
    DECLARE @BestTariff NVARCHAR(50);
    
    -- Таблица с расчетом стоимости каждого тарифа
    WITH TariffCosts AS (
        SELECT 
            TariffName,
            CASE 
                WHEN @Minutes <= IncludedMinutes THEN SubscriptionFee
                ELSE SubscriptionFee + (@Minutes - IncludedMinutes) * ExtraMinuteRate
            END AS TotalCost
        FROM Tariffs
    )
    
    -- Определение тарифа с минимальной стоимостью
    SELECT TOP 1 @BestTariff = TariffName
    FROM TariffCosts
    ORDER BY TotalCost ASC;
    
    RETURN @BestTariff;
END;

DROP FUNCTION Страны.GetBestTariff

SELECT Страны.GetBestTariff(225) AS BestTariff;