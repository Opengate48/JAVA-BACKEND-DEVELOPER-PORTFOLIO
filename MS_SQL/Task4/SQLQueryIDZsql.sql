USE master
/*��������� � ��������� ���� SQL �������
��� �������� ���������������� ���� ������*/
GO --����������� ������ (BATH)

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Lagunov'
)
ALTER DATABASE KB301_Lagunov set single_user with rollback immediate
GO
/* ���������, ���������� �� �� ������� ���� ������
� ������ [��� ����], ���� ��, �� ��������� ��� �������
 ���������� � ���� ����� */

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Lagunov'
)
DROP DATABASE KB301_Lagunov
GO
CREATE DATABASE KB301_Lagunov
GO
-- ������� ���� ������

USE KB301_Lagunov
GO
/* ��������� � ��������� ���� ������ ��� ����������� ������ � ��� 
��� � ���� ������ ���������� ������ � ����� ������ ���� ���
 ��� ���������� �� ������� */

CREATE SCHEMA ������ 
GO

SELECT * FROM KB301_Lagunov.������.Countries
SELECT * FROM KB301_Lagunov.������.Cities
SELECT * FROM KB301_Lagunov.������.Languages

ALTER TABLE KB301_Lagunov.������.Languages ADD 
	CONSTRAINT FK_count_code_for_langs FOREIGN KEY (���_������) 
	REFERENCES KB301_Lagunov.������.Countries(���)
GO
ALTER TABLE KB301_Lagunov.������.Cities ADD 
	CONSTRAINT FK_count_code_for_cities FOREIGN KEY (���_������) 
	REFERENCES KB301_Lagunov.������.Countries(���)
GO
ALTER TABLE KB301_Lagunov.������.Countries ADD 
	CONSTRAINT FK_capit_code_for_counts FOREIGN KEY (���_�������) 
	REFERENCES KB301_Lagunov.������.Cities(���)
GO
ALTER TABLE KB301_Lagunov.������.Cities DROP CONSTRAINT FK_count_code_for_cities


CREATE FUNCTION ������.fn_GetTotalVNDChange(@PopulationThreshold INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalVNDChange INT;

    SELECT 
        @TotalVNDChange = ABS(SUM(COALESCE(C.���, 0) - COALESCE(C.���_����, 0)))
    FROM 
        KB301_Lagunov.������.Countries C
    JOIN 
        KB301_Lagunov.������.Cities CI ON C.���_������� = CI.���
    WHERE 
        CI.��������� > @PopulationThreshold;

    RETURN @TotalVNDChange;
END;
GO

--1) ������ ������ ������ � ����������� �����, ��� ���� ���� ����, � ����������� �����,
--��� ���� ���� �����������.
SELECT 
    L.�������� AS N'����',
    COUNT(L.���_������) AS N'���������� �����',
    SUM(CASE WHEN L.����������� = 1 THEN 1 ELSE 0 END) AS N'���������� ����� � ����������� ������'
FROM 
    KB301_Lagunov.������.Languages L
GROUP BY 
    L.��������
ORDER BY 
    [���������� �����] DESC;

--2)����������, �� ������� �������� ��������� ��� �����, � ������� ��������� �������
--��������� 1 000 000 �������. ��� ��� �����, � ������� ��� �������� ���, ������� ��� ������ 0.
--� ������ ������� ������ ����������� ��������.
--(533849)
SELECT 
    ABS(SUM(COALESCE(C.���, 0) - COALESCE(C.���_����, 0))) AS N'��������� ���'
FROM 
    KB301_Lagunov.������.Countries C
JOIN 
    KB301_Lagunov.������.Cities CI ON C.���_������� = CI.���
WHERE 
    CI.��������� > 1000000;

--3) ������� �������, ������� �� ���������� ������� ����������, �� ������� �������� ��������� ��� �����,
--� ������� ��������� ������� ��������� ����������.
SELECT ������.fn_GetTotalVNDChange(1000000) AS N'��������� ���';

--4) ���������� ������� ��������� ����� ������, � ������� �������� ���������� ����������� ����
--���������� ����� 60% ���������.
--(2129900)
SELECT 
    AVG(������.���������) AS �������_���������
FROM 
    (SELECT 
        C.���������
     FROM 
        KB301_Lagunov.������.Countries C
     JOIN 
        KB301_Lagunov.������.Languages L ON C.��� = L.���_������
     WHERE 
        C.��������� = 'Europe' 
        AND L.����������� = 1
     GROUP BY 
        C.���, C.���������
     HAVING 
        MAX(L.�������) < 60
    ) AS ������;

--5) ������� �������������� ������� ������_���� (���_������, count_������, min_���������),
--��� count_������ � ���������� ������� � ������ ������, min_��������� � ����� � ���������� ����������.
--��������� �����, ��������������� �����������. ��������� �������������� ������� �������
--������� � ������� � �������� �������, ������� �������������� Cities � ������_����
--������� ��������������.
CREATE TABLE KB301_Lagunov.������.������_���� (
    ���_������ varchar(3),
    count_������ SMALLINT NOT NULL,
    min_��������� INT NOT NULL,
	CONSTRAINT PK_������_����_���_������ PRIMARY KEY (���_������),
    CONSTRAINT FK_������_����_���_������ FOREIGN KEY (���_������) REFERENCES KB301_Lagunov.������.Countries(���)
    ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO KB301_Lagunov.������.������_���� (���_������, count_������, min_���������)
SELECT 
    C.���,
    COUNT(CI.���) AS count_������,
    ISNULL(MIN(CI.���������), 0) AS min_��������� -- ���� ��� �������, ������������� ��������� 0
FROM 
    KB301_Lagunov.������.Countries C
LEFT JOIN 
    KB301_Lagunov.������.Cities CI ON C.��� = CI.���_������
GROUP BY 
    C.���;
SELECT * FROM KB301_Lagunov.������.������_����



SELECT * FROM KB301_Lagunov.������.Cities
DELETE FROM KB301_Lagunov.������.Cities WHERE Cities.�������� = 'Qandahar'
INSERT INTo KB301_Lagunov.������.Cities VALUES (2, 'Konstantinopol', 'AFG', 'Visantia', 1000000)
SELECT * FROM KB301_Lagunov.������.������_����

CREATE TRIGGER trg_UpdateCountriesSummary
ON KB301_Lagunov.������.Cities
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- ���������� ���������� �� ������� � ������� ������_����
    MERGE KB301_Lagunov.������.������_���� AS target
    USING (
        -- �������� ���������� ���������� �� �������
        SELECT 
            ���_������,
            COUNT(���) AS count_������,
            ISNULL(MIN(���������), 0) AS min_���������
        FROM 
            KB301_Lagunov.������.Cities
        GROUP BY 
            ���_������
    ) AS source
    ON target.���_������ = source.���_������
    -- ���� ������ � ������� ������_���� ����, ���������
    WHEN MATCHED THEN 
        UPDATE SET 
            count_������ = source.count_������,
            min_��������� = source.min_���������
    -- ���� � ������� ������_���� ��� ������ ��� ������, ���������
    WHEN NOT MATCHED THEN 
        INSERT (���_������, count_������, min_���������)
        VALUES (source.���_������, source.count_������, source.min_���������)
    -- ���� ������� ��� ������, ������� ������ �� ������_����
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;
END;
GO
/*
--������� (��������� ��� ��������� �������� � ��������� �������)
CREATE TRIGGER ������.Sync
ON KB301_Lagunov.������.Cities
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- ���������� Count_������ � ������� ������_����
    UPDATE KB301_Lagunov.������.c�����_����
    SET Count_������ = (
        SELECT COUNT(*)
        FROM KB301_Lagunov.������.Cities
        WHERE Cities.���_������ = KB301_Lagunov.������.������_����.���_������
    )
    WHERE ���_������ IN (
        SELECT DISTINCT ���_������ 
        FROM INSERTED
    );

    -- ���������� Max_��������� � ������� ������_����
    UPDATE KB301_Lagunov.������.[������_����]
    SET min_��������� = (
        SELECT MIN(Cities.���������)
        FROM KB301_Lagunov.������.Cities
        WHERE Cities.���_������ = KB301_Lagunov.������.������_����.���_������
    )
    WHERE ���_������ IN (
        SELECT DISTINCT ���_������ 
        FROM INSERTED
    );
END;

*/


CREATE PROCEDURE ������.GetIntervals
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

	SELECT @const_for_mixed = Tariffs.SubscriptionFee FROM ������.Tariffs WHERE Tariffs.TariffName = '���������'
	SELECT @const_for_unlimited = Tariffs.SubscriptionFee FROM ������.Tariffs WHERE Tariffs.TariffName = '�����������'
	SELECT @limit_for_mixed = Tariffs.IncludedMinutes FROM ������.Tariffs WHERE Tariffs.TariffName = '���������'

	SELECT @a = Tariffs.ExtraMinuteRate FROM ������.Tariffs WHERE Tariffs.TariffName = '��� ����������� �����'
	SET @b = 0
	SELECT @c = Tariffs.ExtraMinuteRate FROM ������.Tariffs WHERE Tariffs.TariffName = '���������'
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
		TariffName NVARCHAR(50), -- �������� ������
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
		SELECT @cur_tariff_name = ������.GetBestTariff(@midlle)
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
	SELECT #Intervals.TariffName as '�����', CAST(#Intervals.bigining AS nvarchar) + ' - ' + CAST(#Intervals.ending AS nvarchar) as '��������'  FROM #Intervals
	DROP TABLE #inter_points
	DROP TABLE #Intervals
END

DROP PROCEDURE ������.GetIntervals
go
EXEC ������.GetIntervals
GO

--4-� ������������
CREATE TABLE KB301_Lagunov.������.Tariffs (
    TariffName NVARCHAR(50) PRIMARY KEY, -- �������� ������
    SubscriptionFee DECIMAL(10, 2) NOT NULL, -- ����������� �����
    IncludedMinutes INT NOT NULL, -- ���������� �����, ���������� � ����������� �����
    ExtraMinuteRate DECIMAL(10, 2) NOT NULL -- ��������� ������ ����� ���������� �����
);

INSERT INTO KB301_Lagunov.������.Tariffs (TariffName, SubscriptionFee, IncludedMinutes, ExtraMinuteRate)
VALUES 
('��� ����������� �����', 0, 0, 1.5),
('�����������', 1000, 43200, 0), -- �������� ������ ��� ���������
('���������', 600, 300, 0.5);
GO

INSERT INTO KB301_Lagunov.������.Tariffs (TariffName, SubscriptionFee, IncludedMinutes, ExtraMinuteRate)
VALUES 
('��� ����������� �����', 0, 0, 0.75),
('�����������', 400, 43200, 0), -- �������� ������ ��� ���������
('���������', 200, 300, 2);
GO

DELETE KB301_Lagunov.������.Tariffs
GO

CREATE FUNCTION ������.GetBestTariff (@Minutes INT)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @Minutes <= 0 OR @Minutes >= 43200
    BEGIN
        RETURN N'������������ ���������� �����.'
    END
    DECLARE @BestTariff NVARCHAR(50);
    
    -- ������� � �������� ��������� ������� ������
    WITH TariffCosts AS (
        SELECT 
            TariffName,
            CASE 
                WHEN @Minutes <= IncludedMinutes THEN SubscriptionFee
                ELSE SubscriptionFee + (@Minutes - IncludedMinutes) * ExtraMinuteRate
            END AS TotalCost
        FROM Tariffs
    )
    
    -- ����������� ������ � ����������� ����������
    SELECT TOP 1 @BestTariff = TariffName
    FROM TariffCosts
    ORDER BY TotalCost ASC;
    
    RETURN @BestTariff;
END;

DROP FUNCTION ������.GetBestTariff

SELECT ������.GetBestTariff(225) AS BestTariff;