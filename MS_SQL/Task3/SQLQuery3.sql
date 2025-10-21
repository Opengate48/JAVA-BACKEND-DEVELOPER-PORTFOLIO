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

CREATE SCHEMA ����� 
GO

CREATE TABLE KB301_Lagunov.�����.regions_aux
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
	FOR SELECT reg.region_code FROM KB301_Lagunov.�����.regionsCSV reg
	OPEN @cur
	FETCH NEXT FROM @cur INTO @i
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO KB301_Lagunov.�����.regions_aux
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
	DELETE KB301_Lagunov.�����.main
	DELETE KB301_Lagunov.�����.auto_status
END

CREATE TABLE KB301_Lagunov.�����.auto_status
(
	number nvarchar(18) NOT NULL,
	id_status tinyint NOT NULL
	CONSTRAINT PK_number PRIMARY KEY (number)
)
GO
DROP TABLE  KB301_Lagunov.�����.auto_status
GO

CREATE TABLE KB301_Lagunov.�����.status_list
(
	id_status tinyint NOT NULL,
	status_name nvarchar(30) NOT NULL
	CONSTRAINT PK_id_status PRIMARY KEY (id_status)
)
GO

INSERT INTO KB301_Lagunov.�����.status_list
  VALUES 
  (0, N'������'),
  (1, N'����������'),
  (2, N'�����������'),
  (3, N'�������')

CREATE TABLE KB301_Lagunov.�����.main
(
	GAI_post_number tinyint NOT NULL, 
	number nvarchar(18) NOT NULL,
	travel_time smalldatetime NOT NULL,
	direction BIT NOT NULL
	CONSTRAINT PK_main PRIMARY KEY (GAI_post_number, number, travel_time, direction)
)
GO

DROP TABLE  KB301_Lagunov.�����.main
GO
DROP TABLE  KB301_Lagunov.�����.auto_status
GO

ALTER TABLE KB301_Lagunov.�����.main ADD 
	CONSTRAINT chk_number CHECK (
	(((main.number LIKE N'[������������][1-9][0-9][0-9][������������][������������][0-9][0-9]' )OR 
	(main.number LIKE N'[������������][0-9][1-9][0-9][������������][������������][0-9][0-9]') OR 
	(main.number LIKE N'[������������][0-9][0-9][1-9][������������][������������][0-9][0-9]')) and LEN(main.number) = 8) OR
	(((main.number LIKE N'[������������][1-9][0-9][0-9][������������][������������][127][0-9][0-9]') OR 
	(main.number LIKE N'[������������][0-9][1-9][0-9][������������][������������][127][0-9][0-9]') OR 
	(main.number LIKE N'[������������][0-9][0-9][1-9][������������][������������][127][0-9][0-9]')) and LEN(main.number) = 9)
	)
GO

ALTER TABLE KB301_Lagunov.�����.main   
DROP CONSTRAINT chk_number  
GO 

SELECT name 
FROM sys.check_constraints 
WHERE parent_object_id = OBJECT_ID('KB301_Lagunov.�����.main')

EXEC Fill_regions_aux
go

SELECT *  FROM KB301_Lagunov.�����.regions_aux
go

CREATE TRIGGER �����.insert_new_auto ON KB301_Lagunov.�����.main INSTEAD OF INSERT 
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
				PRINT N'�������� ������ ������'
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
				PRINT N'�������� ������ ������'
				FETCH NEXT FROM @cursor INTO @new_direction, @new_travel_time, @new_GAI_post_number, @new_number
				CONTINUE
			END CATCH
		END
		IF (NOT EXISTS (SELECT regionsCSV.region_code FROM regionsCSV WHERE regionsCSV.region_code = @region) AND NOT EXISTS (SELECT regions_aux.ex_region_code FROM regions_aux WHERE regions_aux.ex_region_code = @region))
		BEGIN
			PRINT N'�������� ������ ������'
			FETCH NEXT FROM @cursor INTO @new_direction, @new_travel_time, @new_GAI_post_number, @new_number
			CONTINUE
		END
		SELECT TOP 1 @last_travel_time = mn.travel_time FROM KB301_Lagunov.�����.main mn WHERE mn.number = @new_number ORDER BY mn.travel_time DESC
		SELECT TOP 1 @last_direction = mn.direction FROM KB301_Lagunov.�����.main mn WHERE mn.number = @new_number ORDER BY mn.travel_time DESC
		SELECT TOP 1 @last_GAI_post_number = mn.GAI_post_number FROM KB301_Lagunov.�����.main mn WHERE mn.number = @new_number ORDER BY mn.travel_time DESC
		IF @last_travel_time IS NOT NULL
		BEGIN
			IF @new_direction = @last_direction
			BEGIN
				PRINT N'������ ��� ���� ������ �������/�������'
			END
			ELSE
			BEGIN
				IF @new_travel_time < @last_travel_time OR DATEDIFF(minute, @last_travel_time, @new_travel_time) < 5
				BEGIN
					PRINT N'���������� ����� �������'
				END
				ELSE
				BEGIN
					INSERT INTO KB301_Lagunov.�����.main
					VALUES
					(@new_GAI_post_number, @new_number, @new_travel_time, @new_direction)
					IF @region = 66
					BEGIN
						IF @last_direction = 1 and @new_direction = 0
						BEGIN
							UPDATE KB301_Lagunov.�����.auto_status SET auto_status.id_status = 3 WHERE auto_status.number = @new_number
						END
						ELSE
						BEGIN
							IF	@last_GAI_post_number = @new_GAI_post_number
							BEGIN
								UPDATE KB301_Lagunov.�����.auto_status SET auto_status.id_status = 2 WHERE auto_status.number = @new_number
							END
							ELSE
							BEGIN
								UPDATE KB301_Lagunov.�����.auto_status SET auto_status.id_status = 0 WHERE auto_status.number = @new_number
							END
						END
					END
					ELSE
					BEGIN
						IF @last_direction = 0 and @new_direction = 1
						BEGIN
							IF @last_GAI_post_number = @new_GAI_post_number
							BEGIN
								UPDATE KB301_Lagunov.�����.auto_status SET auto_status.id_status = 2 WHERE auto_status.number = @new_number
							END
							ELSE
							BEGIN
								UPDATE KB301_Lagunov.�����.auto_status SET auto_status.id_status = 1 WHERE auto_status.number = @new_number
							END
						END
						ELSE
						BEGIN
							UPDATE KB301_Lagunov.�����.auto_status SET auto_status.id_status = 0 WHERE auto_status.number = @new_number
						END
					END
				END
			END
		END
		ELSE
		BEGIN
			INSERT INTO KB301_Lagunov.�����.main
			VALUES
			(@new_GAI_post_number, @new_number, @new_travel_time, @new_direction)
			INSERT INTO KB301_Lagunov.�����.auto_status
				VALUES 
					(@new_number, 0)
		END
		FETCH NEXT FROM @cursor INTO @new_direction, @new_travel_time, @new_GAI_post_number, @new_number
	END
	CLOSE @cursor;

DROP TRIGGER �����.insert_new_auto

CREATE VIEW �����.main_view
 AS
	SELECT main.GAI_post_number AS N'���� ���', 
	main.number AS N'�����', 
	-- ���������� ��������� ��� ������������ ������������� ����
	COALESCE(
		-- ���� ����� ������ 8 ��������, ����� ��������� 2 �����
		CASE 
			WHEN LEN(main.number) = 8 
			THEN CAST(SUBSTRING(main.number, 7, 2) AS SMALLINT) 
		END,
		-- ���� ����� ������ 9 ��������, ��������� ������������ ������ �����, ����� ��������� 3 �����
		CASE 
			WHEN LEN(main.number) = 9 
				 --AND LEFT(SUBSTRING(main.number, 7, 3), 1) IN ('1', '2', '7')
			THEN CAST(SUBSTRING(main.number, 7, 3) AS SMALLINT)
		END
	) AS N'��� �������',
	COALESCE(
		regions.region_name,
		aux_regions.region_name
	) AS N'�������� �������',
	main.travel_time AS N'����� �������', 
	N'����������� ��������' = CASE main.direction 
	WHEN 0 THEN N'�����' WHEN 1 THEN N'�����' END, 
	st_ls.status_name AS N'������ ����������' 

	FROM KB301_Lagunov.�����.main AS main
	JOIN KB301_Lagunov.�����.auto_status au_st
	ON main.number = au_st.number
	JOIN KB301_Lagunov.�����.status_list st_ls
	ON au_st.id_status = st_ls.id_status
	LEFT JOIN KB301_Lagunov.�����.regionsCSV AS regions
	ON CAST(SUBSTRING(main.number, 7, CASE WHEN LEN(main.number) = 8 THEN 2 ELSE 3 END) AS SMALLINT) = regions.region_code
	-- ���������� � ��������������� �������� �������� (regions_aux)
	LEFT JOIN KB301_Lagunov.�����.regions_aux AS aux
	ON CAST(SUBSTRING(main.number, 7, CASE WHEN LEN(main.number) = 8 THEN 2 ELSE 3 END) AS SMALLINT) = aux.ex_region_code
	LEFT JOIN KB301_Lagunov.�����.regionsCSV AS aux_regions
	ON aux.region_code = aux_regions.region_code
DROP VIEW �����.main_view

CREATE VIEW �����.main_only_last_travel_view
 AS
	SELECT mn.GAI_post_number AS N'���� ���', 
	mn.number AS N'�����',
	mn.travel_time AS N'����� �������', 
	N'����������� ��������' = CASE mn.direction 
	WHEN 0 THEN N'�����' WHEN 1 THEN N'�����' END

	FROM KB301_Lagunov.�����.main AS mn
	JOIN (
		SELECT main.number, MAX(main.travel_time) AS LastTravelTime
		FROM KB301_Lagunov.�����.main
		GROUP BY main.number
	) AS LastPass
	ON mn.number = LastPass.number AND mn.travel_time = LastPass.LastTravelTime;


INSERT INTO KB301_Lagunov.�����.main
  VALUES 
  (1, N'�122��66', '2024-10-10 14:49:10', 1),
  (1, N'�111��166', '2024-11-10 15:40:10', 1),
  (1, N'�122��66', '2024-10-10 15:10:10', 0)

 SELECT * FROM KB301_Lagunov.�����.main
 SELECT * FROM KB301_Lagunov.�����.auto_status

EXEC Clean_Main
go


Go
DROP VIEW �����.main_view
GO

SELECT * FROM �����.regionsCSV
GO

EXEC Clean_Main
GO

--�����
--1) ������� ������� ������ � ���������� �������

SELECT * FROM �����.main_view
GO

INSERT INTO KB301_Lagunov.�����.main           --� ������ ���� "������������" ������������� �����
  VALUES 
  (1, N'�222��166', '2024-10-10 15:00:00', 1)
go

SELECT * FROM �����.main_view
GO

SELECT * FROM �����.main_view
GO

INSERT INTO KB301_Lagunov.�����.main           --�� ����������� ������ ������
  VALUES 
  (1, N'�1�2B�66', '2024-10-10 15:00:00', 1)
go

SELECT * FROM �����.main_view
GO

SELECT * FROM �����.main_view
GO

INSERT INTO KB301_Lagunov.�����.main           --�� ���������� � ������ ������� � ����� 99
  VALUES 
  (1, N'�122B�99', '2024-10-10 15:00:00', 1)
go

SELECT * FROM �����.main_view
GO


--2) ������� ������� ������ � ������� ����������, ������� ��� �������/������� �/�� �����(�) � �� ����� ������� ��� ������ ���

SELECT * FROM �����.main_view
GO

INSERT INTO KB301_Lagunov.�����.main           
  VALUES 
  (1, N'�122��66', '2024-10-10 15:20:00', 0)
go

SELECT * FROM �����.main_view
GO

--3) ������� ������� ������ � �������� ������� ����������, ������� ���������� �� ������� ���������� ������� ����� �� ���������� ������ ��� �� 5 �����
SELECT * FROM �����.main_view
GO

INSERT INTO KB301_Lagunov.�����.main           
  VALUES 
  (1, N'�122��66', '2024-10-10 15:14:00', 1)  --��������� ��� �������� � 10 ����� ����������
go

SELECT * FROM �����.main_view
GO

--4) ������������ ���������� ������� ����������

SELECT * FROM �����.main_view
GO

INSERT INTO KB301_Lagunov.�����.main           
  VALUES 
  (1, N'�999��22', '2024-10-10 15:10:00', 0)  --������� ���������� ����������
go

SELECT * FROM �����.main_view WHERE [�����] = N'�999��22'
GO

INSERT INTO KB301_Lagunov.�����.main           
  VALUES 
  (2, N'�999��22', '2024-10-10 15:20:00', 1)  --������� ���������� ����������
go

SELECT * FROM �����.main_view WHERE [�����] = N'�999��22'
GO

INSERT INTO KB301_Lagunov.�����.main           
  VALUES 
  (1, N'�999��66', '2024-10-10 15:10:00', 1)  --������� ������� ���������� (������� - ��, ������� ���������������� � ������������ �������)
go

SELECT * FROM �����.main_view WHERE [�����] = N'�999��66'
GO

INSERT INTO KB301_Lagunov.�����.main           
  VALUES 
  (2, N'�999��66', '2024-10-10 15:20:00', 0)  --������� ������� ���������� (������� - ��, ������� ���������������� � ������������ �������)
go

SELECT * FROM �����.main_view WHERE [�����] = N'�999��66'
GO

INSERT INTO KB301_Lagunov.�����.main           
  VALUES 
  (1, N'�999��122', '2024-11-10 15:10:00', 0)  --������� ����������� ����������
go

SELECT * FROM �����.main_view WHERE [�����] = N'�999��122'
GO

INSERT INTO KB301_Lagunov.�����.main           
  VALUES 
  (1, N'�999��122', '2024-11-10 15:20:00', 1)  --������� ����������� ����������
go

SELECT * FROM �����.main_view WHERE [�����] = N'�999��122'
GO

INSERT INTO KB301_Lagunov.�����.main           
  VALUES 
  (1, N'�999��122', '2024-11-10 15:30:00', 0)  --������� ����������� ���������� "������"
go

SELECT * FROM �����.main_view WHERE [�����] = N'�999��122'
GO 

--5) ���������� ���� ������� � ��������� �����������, ������� ���������������� � ������������ �������

SELECT * FROM �����.main_view WHERE [�������� �������] = N'������������ �������'
GO

--6) ���������� ������� �������� �� ������������ ����

SELECT * FROM �����.main_view WHERE CONVERT(DATE, [����� �������]) = '2024-10-10'
GO

--7) ���������� ������� �������� ����������� ��������� "�������"
SELECT * FROM �����.main_view WHERE [������ ����������] = N'�������'
GO

--8) ��������� ������ ������� ����������
SELECT 
    mv.[���� ���], 
    mv.[�����], 
    mv.[����� �������], 
    mv.[����������� ��������]
FROM KB301_Lagunov.�����.main_view mv
JOIN (
    SELECT [�����], MAX([����� �������]) AS LastTravelTime
    FROM KB301_Lagunov.�����.main_view
    GROUP BY [�����]
) AS LastPass
ON mv.[�����] = LastPass.[�����] AND mv.[����� �������] = LastPass.LastTravelTime;

SELECT * FROM �����.main_only_last_travel_view
	