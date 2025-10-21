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
CREATE SCHEMA �������� 
GO
/*������� � ���� ������
 [��� ����] ����� � ������ ������� */
CREATE TABLE KB301_Lagunov.��������.storage_transaction
(
	id_shop tinyint NOT NULL, 
	id_stuff int NOT NULL,
	price decimal(11,2) NOT NULL,
	in_out decimal(11,2) NOT NULL,
	trans_time smalldatetime NOT NULL
)
GO
CREATE TABLE KB301_Lagunov.��������.category
(
	id_cat tinyint NOT NULL, 
	cat_name nvarchar(20) NOT NULL
	CONSTRAINT PK_id_cat PRIMARY KEY (id_cat)
)
GO
CREATE TABLE KB301_Lagunov.��������.stuffs
(
	id_stuff int NOT NULL, 
	stuff_name nvarchar(30) NOT NULL,
	id_cat tinyint NOT NULL,
	metric nvarchar(2)
	CONSTRAINT PK_id_stuff PRIMARY KEY (id_stuff)
)
GO
CREATE TABLE KB301_Lagunov.��������.shops
(
	shop_name nvarchar(20) NOT NULL, 
	street nvarchar(20) NOT NULL,
	building nvarchar(20) NOT NULL,
	open_time time NOT NULL,
	close_time time NOT NULL,
	id_shop tinyint NOT NULL
	CONSTRAINT PK_id_shop PRIMARY KEY (id_shop)
)
GO
ALTER TABLE KB301_Lagunov.��������.storage_transaction ADD 
	CONSTRAINT FK_id_shop FOREIGN KEY (id_shop) 
	REFERENCES KB301_Lagunov.��������.shops(id_shop)
	ON UPDATE CASCADE
GO		
ALTER TABLE KB301_Lagunov.��������.storage_transaction ADD 
	CONSTRAINT FK_id_stuff FOREIGN KEY (id_stuff) 
	REFERENCES KB301_Lagunov.��������.stuffs(id_stuff)
	ON UPDATE CASCADE
GO
ALTER TABLE KB301_Lagunov.��������.stuffs ADD 
	CONSTRAINT FK_id_cat FOREIGN KEY (id_cat) 
	REFERENCES KB301_Lagunov.��������.category(id_cat)
	ON UPDATE CASCADE
GO

INSERT INTO KB301_Lagunov.��������.category
  VALUES 
 (1,N'�������')
 , (2,N'����')
GO

INSERT INTO KB301_Lagunov.��������.stuffs
  VALUES 
 (1,N'����������', 1, N'�')
 , (2,N'���������', 1, N'�')
 , (3,N'�������� �����', 2, N'��')
 , (4,N'���������� ������������', 2, N'��')
GO

INSERT INTO KB301_Lagunov.��������.shops
  VALUES 
 (N'7-Eleven', N'�������', N'69A', N'08:00', N'19:00', 1)
 , (N'� ���� �����', N'���������', N'228�', N'07:00', N'20:00', 2)
 , (N'���������� ���������', N'����� ��������', N'228�', N'08:00', N'19:00', 3)
GO

INSERT INTO KB301_Lagunov.��������.storage_transaction
  VALUES 
 (1, 1, 228.69, 16, N'2024-05-08 12:35')
 , (1, 1, 228.69, 17, N'2024-05-09 12:35')
 , (1, 2, 420.99, 2, N'2024-05-08 12:30')
 , (1, 2, 420.99, 0, N'2024-05-09 12:30')
 , (1, 3, 130.66, 8, N'2024-05-08 12:20')
 , (1, 3, 130.66, 16, N'2024-05-09 12:20')
 , (1, 4, 89.99, 7, N'2024-05-08 07:35')
 , (1, 4, 89.99, 3, N'2024-05-09 07:35')

 , (2, 1, 48.99, 5, N'2024-05-08 06:30')
 , (2, 1, 48.99, 5, N'2024-05-09 06:30')
 , (2, 2, 421.99, 8, N'2024-05-08 06:30')
 , (2, 2, 421.99, 7, N'2024-05-09 06:30')
 , (2, 3, 99.99, 7, N'2024-05-08 06:35')
 , (2, 3, 99.99, 9, N'2024-05-09 06:35')
 , (2, 4, 109.99, 7, N'2024-05-08 06:30')
 , (2, 4, 109.99, 7, N'2024-05-09 06:30')

 , (3, 1, 69.99, 35, N'2024-05-08 06:30')
 , (3, 1, 69.99, 20, N'2024-05-09 06:30')
 , (3, 2, 79.99, 26, N'2024-05-08 06:30')
 , (3, 2, 79.99, 23, N'2024-05-09 06:30')
 , (3, 3, 124.99, 18, N'2024-05-08 06:35')
 , (3, 3, 124.99, 30, N'2024-05-09 06:35')
 , (3, 4, 139.99, 22, N'2024-05-08 06:30')
 , (3, 4, 139.99, 23, N'2024-05-09 06:30')
GO

SELECT sh.shop_name as N'�������'
, sh.street + ', ' + sh.building as N'�����' 
From KB301_Lagunov.��������.shops sh							 --�������� � ������ ���������, ������� �������� ����� 19:30
	WHERE sh.close_time < N'19:30'
GO
 --���� �� ��� ������ �� ���� ��������� �� 08.05.2024 
SELECT sh.shop_name as N'�������'
, st.stuff_name  as N'�����'
, tr.price as N'����' 
From KB301_Lagunov.��������.shops sh
	JOIN KB301_Lagunov.��������.storage_transaction tr
	ON sh.id_shop = tr.id_shop
	JOIN KB301_Lagunov.��������.stuffs st
	ON st.id_stuff = tr.id_stuff
	
	where  tr.trans_time <= N'2024-05-09 00:00'
GO


SELECT st.stuff_name  as N'�����'
, ct.cat_name as N'���������'
, MIN(tr.price) as N'����������� ����' 
From KB301_Lagunov.��������.storage_transaction tr    --����������� ���� ������� �� ��������� "�������" �� ���� ���������
	JOIN KB301_Lagunov.��������.stuffs st
	ON st.id_stuff = tr.id_stuff
	JOIN KB301_Lagunov.��������.category ct
	ON st.id_cat = ct.id_cat
	WHERE ct.cat_name = N'�������'
	GROUP BY st.stuff_name, ct.cat_name
GO

SELECT st.stuff_name  as N'�����'
, MIN(tr.price) as N'����������� ����' 
From KB301_Lagunov.��������.storage_transaction tr  --����������� ���� ������� ������ �� ���� ���������
	JOIN KB301_Lagunov.��������.stuffs st
	ON tr.id_stuff = st.id_stuff
	JOIN KB301_Lagunov.��������.category ct
	ON ct.id_cat = st.id_cat
	GROUP BY st.stuff_name
GO
/*
SELECT sh.shop_name as N'�������', st.stuff_name  as N'�����', MIN(tr.price) OVER (PARTITION BY sh.shop_name, st.stuff_name) as N'����������� ����' From KB301_Lagunov.��������.shops sh
	JOIN KB301_Lagunov.��������.storage_transaction tr
	ON tr.id_shop = sh.id_shop
	JOIN KB301_Lagunov.��������.stuffs st
	ON st.id_stuff = st.id_stuff
	WHERE tr.trans_time < N'2024-05-09 00:00'
	GROUP BY sh.shop_name, st.stuff_name, tr.price
GO
*/

SELECT sh.shop_name as N'�������'
, stu.stuff_name as N'�����'
, st.in_out as N'��������' 
From KB301_Lagunov.��������.storage_transaction st  --���������� ����������� ������� ������ �� ���� ��������� �� 08.05.2024
	JOIN KB301_Lagunov.��������.shops sh
	ON st.id_shop = sh.id_shop
	JOIN KB301_Lagunov.��������.stuffs stu
	ON st.id_stuff = stu.id_stuff
	WHERE N'2024-05-08 00:00' < st.trans_time  AND st.trans_time < N'2024-05-09 00:00'
GO

--������� ���� ������� ������ ��������� � ������ ��������
SELECT sh.shop_name as N'�������'
, ct.cat_name as N'��������� �������'
, CAST(AVG(tr.price) as decimal(11,2)) as N'������� ���� ������� �� ���������' 
FROM KB301_Lagunov.��������.shops sh 
	JOIN KB301_Lagunov.��������.storage_transaction tr
	ON sh.id_shop = tr.id_shop
	JOIN KB301_Lagunov.��������.stuffs st
	ON st.id_stuff = tr.id_stuff
	JOIN KB301_Lagunov.��������.category ct
	ON ct.id_cat = st.id_cat
	GROUP BY sh.shop_name, ct.cat_name
GO

/*
SELECT sh.shop_name as N'�������', st.stuff_name as N'�����', tr.price as N'���������� ���� ������' FROM KB301_Lagunov.��������.shops sh
	JOIN KB301_Lagunov.��������.storage_transaction tr
	ON sh.id_shop = tr.id_shop
	JOIN KB301_Lagunov.��������.stuffs st
	ON st.id_stuff = tr.id_stuff
	WHERE tr.price = (SELECT MIN(tr.price) OVER (PARTITION BY st.stuff_name) FROM KB301_Lagunov.��������.shops sh
	JOIN KB301_Lagunov.��������.storage_transaction tr
	ON sh.id_shop = tr.id_shop
	JOIN KB301_Lagunov.��������.stuffs st
	ON st.id_stuff = tr.id_stuff)
	GROUP BY sh.shop_name, st.stuff_name, tr.price
GO
*/

SELECT  DISTINCT sh.shop_name AS N'�������'
, st.stuff_name as N'�����'
, tr.price as N'����� ������� ���� �� ����� �� ���� 3-� ���������' 
FROM KB301_Lagunov.��������.shops sh                                --� ����� �������� ������� ����� ����� ������� ���������� ������
	JOIN KB301_Lagunov.��������.storage_transaction tr
	ON sh.id_shop = tr.id_shop
	JOIN KB301_Lagunov.��������.stuffs st
	ON st.id_stuff = tr.id_stuff
	where st.stuff_name = N'����������'
	ORDER BY tr.price ASC
go

SELECT sh.shop_name as N'�������'
, ct.cat_name as N'��������� �������'
, AVG(tr.price) as N'������� ���� ������� �� ���������' 
FROM KB301_Lagunov.��������.shops sh --������� ���� ������� �� ��������� "�������" � 7-Eleven � "� ���� �����"
	JOIN KB301_Lagunov.��������.storage_transaction tr
	ON sh.id_shop = tr.id_shop
	JOIN KB301_Lagunov.��������.stuffs st
	ON st.id_stuff = tr.id_stuff
	JOIN KB301_Lagunov.��������.category ct
	ON ct.id_cat = st.id_cat
	WHERE sh.shop_name = N'7-Eleven' AND ct.id_cat = 1
	GROUP BY sh.shop_name, ct.cat_name
UNION
SELECT sh.shop_name as N'�������'
, ct.cat_name as N'��������� �������'
, AVG(tr.price) as N'������� ���� ������� �� ���������' 
FROM KB301_Lagunov.��������.shops sh
	JOIN KB301_Lagunov.��������.storage_transaction tr
	ON sh.id_shop = tr.id_shop
	JOIN KB301_Lagunov.��������.stuffs st
	ON st.id_stuff = tr.id_stuff
	JOIN KB301_Lagunov.��������.category ct
	ON ct.id_cat = st.id_cat
	WHERE sh.shop_name = N'� ���� �����' AND ct.id_cat = 1
	GROUP BY sh.shop_name, ct.cat_name
GO