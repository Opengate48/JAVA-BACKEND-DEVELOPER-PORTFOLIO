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
/*������� � ���� ������
 [��� ����] ����� � ������ ������� */
CREATE TABLE KB301_Lagunov.������.wallet
(
	id_currency char(3) NOT NULL, 
	amount money NOT NULL
	CONSTRAINT PK_id_cur PRIMARY KEY (id_currency)
)
GO
CREATE TABLE KB301_Lagunov.������.currency_table
(
	id_sale_currency char(3) NOT NULL, 
	id_buy_currency char(3) NOT NULL,
	exchange_rate smallmoney NOT NULL
	CONSTRAINT PK_id_exch PRIMARY KEY (id_sale_currency, id_buy_currency)
	
)
GO


INSERT INTO KB301_Lagunov.������.wallet
  VALUES 
 ('USD', 200)
 , ('EUR', 200)
 , ('GBP', 200)
 , ('JPY', 200)
 , ('CHF', 200)
 , ('CAD', 200)
 , ('AUD', 200)
 , ('RUB', 200)
GO

INSERT INTO KB301_Lagunov.������.currency_table
  VALUES 
 ('USD', 'USD', 1.0000)
 , ('USD', 'EUR', 0.9194)
 , ('USD', 'GBP', 0.7756)
 , ('USD', 'JPY', 152.0700)
 , ('USD', 'CHF', 0.8637)
 , ('USD', 'CAD', 1.3916)
 , ('USD', 'AUD', 1.5202)
 , ('USD', 'RUB', 97.3737)

 , ('EUR', 'USD', 1.0877)
 , ('EUR', 'EUR', 1.0000)
 , ('EUR', 'GBP', 0.8437)
 , ('EUR', 'JPY', 165.3700)
 , ('EUR', 'CHF', 0.9394)
 , ('EUR', 'CAD', 1.5138)
 , ('EUR', 'AUD', 1.6534)
 , ('EUR', 'RUB', 105.9260)

 , ('GBP', 'USD', 1.2892)
 , ('GBP', 'EUR', 1.1851)
 , ('GBP', 'GBP', 1.0000)
 , ('GBP', 'JPY', 195.9500)
 , ('GBP', 'CHF', 1.1133)
 , ('GBP', 'CAD', 1.7942)
 , ('GBP', 'AUD', 1.9596)
 , ('GBP', 'RUB', 125.5260)

 , ('JPY', 'USD', 0.6578)
 , ('JPY', 'EUR', 0.6048)
 , ('JPY', 'GBP', 0.5102)
 , ('JPY', 'JPY', 1.0000)
 , ('JPY', 'CHF', 0.5681)
 , ('JPY', 'CAD', 0.9156)
 , ('JPY', 'AUD', 1.0001)
 , ('JPY', 'RUB', 0.6406)

 , ('CHF', 'USD', 1.1582)
 , ('CHF', 'EUR', 1.0646)
 , ('CHF', 'GBP', 0.8980)
 , ('CHF', 'JPY', 175.9800)
 , ('CHF', 'CHF', 1.0000)
 , ('CHF', 'CAD', 1.6121)
 , ('CHF', 'AUD', 1.7593)
 , ('CHF', 'RUB', 112.7800)

 , ('CAD', 'USD', 0.7184)
 , ('CAD', 'EUR', 0.6603)
 , ('CAD', 'GBP', 0.5570)
 , ('CAD', 'JPY', 109.17)
 , ('CAD', 'CHF', 0.6204)
 , ('CAD', 'CAD', 1.0000)
 , ('CAD', 'AUD', 1.0912)
 , ('CAD', 'RUB', 69.9500)

 , ('AUD', 'USD', 0.6583)
 , ('AUD', 'EUR', 0.6050)
 , ('AUD', 'GBP', 0.5104)
 , ('AUD', 'JPY', 100.0500)
 , ('AUD', 'CHF', 0.5684)
 , ('AUD', 'CAD', 0.9162)
 , ('AUD', 'AUD', 1.0000)
 , ('AUD', 'RUB', 64.0900)

 , ('RUB', 'USD', 0.0103)
 , ('RUB', 'EUR', 0.0094)
 , ('RUB', 'GBP', 0.0079)
 , ('RUB', 'JPY', 1.5603)
 , ('RUB', 'CHF', 0.0088)
 , ('RUB', 'CAD', 0.0142)
 , ('RUB', 'AUD', 0.0156)
 , ('RUB', 'RUB', 1.0000)
GO
--���������� ��������
CREATE PROCEDURE GetWalletContent
AS
BEGIN
SELECT wallet.id_currency as N'������', wallet.amount as N'������' From KB301_Lagunov.������.wallet wallet
END
GO

CREATE FUNCTION GetWalletContent2()
RETURNS TABLE 
AS
RETURN SELECT wallet.id_currency as N'������', wallet.amount as N'������' From KB301_Lagunov.������.wallet wallet
GO

--����� ������ �������� � ��������� ������
CREATE PROCEDURE GetWalletAmount
	@currency_name char(3)
AS
BEGIN
	DECLARE @cur_cursor CURSOR, @accumulate_var money, @operand1 money, @operand2 money
	SET @accumulate_var = 0
	SET @cur_cursor = CURSOR
	FOR SELECT wallet.amount, c_t.exchange_rate  From KB301_Lagunov.������.wallet wallet
	JOIN KB301_Lagunov.������.currency_table c_t
	ON c_t.id_sale_currency = wallet.id_currency
	WHERE c_t.id_buy_currency = @currency_name
	OPEN @cur_cursor
	FETCH NEXT FROM @cur_cursor INTO @operand1, @operand2
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @accumulate_var = @accumulate_var + (@operand1 * @operand2)
		FETCH NEXT FROM @cur_cursor INTO @operand1, @operand2
	END
	CLOSE @cur_cursor
	PRINT N'������ �������� � ' + @currency_name + ' = ' + CAST(@accumulate_var AS varchar)
END
GO

--���������� ������� ��������� �������
CREATE PROCEDURE AddIncome
	@currency_name char(3),
	@amount money
AS
BEGIN
	DECLARE @sum_var money, @old_amount money
	SELECT @old_amount = wallet.amount FROM KB301_Lagunov.������.wallet WHERE wallet.id_currency = @currency_name
	IF @old_amount IS NOT NULL
	BEGIN
		SET @sum_var = @old_amount + @amount
		IF @sum_var <= 922337203685477.5807
		BEGIN
			UPDATE KB301_Lagunov.������.wallet SET wallet.amount = @sum_var WHERE wallet.id_currency = @currency_name
		END
		ELSE
		BEGIN
			PRINT N'������������ ��������'
		END
	END
	ELSE
	BEGIN
		PRINT N'������ ' + @currency_name + N' ��� � ��������.'
		INSERT INTO KB301_Lagunov.������.wallet
		VALUES
		(@currency_name,@amount)
	END
END
GO

--������ �������� � �������� � ��������� ������
CREATE PROCEDURE AddExpence
	@currency_name char(3),
	@amount money
AS
BEGIN
	DECLARE @sum_var money, @old_amount money
	SELECT @old_amount = wallet.amount FROM KB301_Lagunov.������.wallet WHERE wallet.id_currency = @currency_name
	IF @old_amount IS NOT NULL
	BEGIN
		SET @sum_var = @old_amount - @amount
		IF @sum_var > 0
		BEGIN
			UPDATE KB301_Lagunov.������.wallet SET wallet.amount = @sum_var WHERE wallet.id_currency = @currency_name
		END
		ELSE IF @sum_var = 0
		BEGIN
			DELETE KB301_Lagunov.������.wallet WHERE wallet.id_currency = @currency_name
		END
		ELSE
		BEGIN
			PRINT '�������� ����������� - �� ������� ������ ' + @currency_name
		END
	END
	ELSE
	BEGIN
		PRINT N'������ ' + @currency_name + N' ��� � ��������.'
	END
END
GO


--��������� @amount ������ @currency_from �������� � @currency_to
CREATE PROCEDURE ConvertExpence
	@currency_from char(3),
	@currency_to char(3),
	@amount money
AS
BEGIN
	DECLARE @sum_var money, @old_amount money, @coef money, @sum_var2 money, @old_amount2 money
	SELECT @old_amount = wallet.amount FROM KB301_Lagunov.������.wallet WHERE wallet.id_currency = @currency_from
	IF @old_amount IS NOT NULL
	BEGIN
		SET @sum_var = @old_amount - @amount
	END
	ELSE
	BEGIN
		SET @sum_var = 0 - @amount
	END
	IF @sum_var >= 0
	BEGIN
		SELECT @coef = currency_table.exchange_rate FROM KB301_Lagunov.������.currency_table WHERE currency_table.id_sale_currency = @currency_from AND currency_table.id_buy_currency = @currency_to
		SELECT @old_amount2 = wallet.amount FROM KB301_Lagunov.������.wallet WHERE wallet.id_currency = @currency_to
		IF @old_amount2 IS NOT NULL
		BEGIN
			SET @sum_var2 = @old_amount2 + @amount*@coef
			IF @sum_var2 <= 922337203685477.5807
			BEGIN
				IF @sum_var > 0
				BEGIN
					UPDATE KB301_Lagunov.������.wallet SET wallet.amount = @sum_var WHERE wallet.id_currency = @currency_from
				END
				ELSE
				BEGIN
					DELETE KB301_Lagunov.������.wallet WHERE wallet.id_currency = @currency_from
				END
				UPDATE KB301_Lagunov.������.wallet SET wallet.amount = @sum_var2 WHERE wallet.id_currency = @currency_to
			END
			ELSE
			BEGIN
				PRINT '������������ ��������'
			END
		END
		ELSE
		BEGIN
			PRINT N'������ ' + @currency_to + N' ��� � ��������.'
			IF	@amount*@coef <= 922337203685477.5807
			BEGIN
				UPDATE KB301_Lagunov.������.wallet SET wallet.amount = @sum_var WHERE wallet.id_currency = @currency_from
				INSERT INTO KB301_Lagunov.������.wallet
				VALUES
				(@currency_to, @amount*@coef)
			END
			ELSE
			BEGIN
				PRINT '������������ ��������'
			END
		END
	END
	ELSE
	BEGIN
		PRINT '�������� ����������� - �� ������� ������ ' + @currency_from
	END
END
GO

--������ @amount ������ @currency_buy �� @currency_sale
CREATE PROCEDURE BuyCurrencyByCurrency
	@currency_buy char(3),
	@currency_sale char(3),
	@amount money
AS
BEGIN
	DECLARE @sum_var money, @old_amount money, @coef money, @sum_var2 money, @old_amount2 money, @amount2 money
	SELECT @old_amount = wallet.amount FROM KB301_Lagunov.������.wallet WHERE wallet.id_currency = @currency_sale
	IF @old_amount IS NOT NULL
	BEGIN
		SELECT @coef = currency_table.exchange_rate FROM KB301_Lagunov.������.currency_table WHERE currency_table.id_sale_currency = @currency_sale AND currency_table.id_buy_currency = @currency_buy
		SET @amount2 = @amount/@coef
		SET @sum_var = @old_amount - @amount2
		IF @sum_var >= 0
		begin
			SELECT @old_amount2 = wallet.amount FROM KB301_Lagunov.������.wallet WHERE wallet.id_currency = @currency_buy
			IF @old_amount2 IS NOT NULL
			BEGIN
				SET @sum_var2 = @old_amount2 + @amount
				IF @sum_var2 <= 922337203685477.5807
				BEGIN
					IF @sum_var > 0
					BEGIN
						UPDATE KB301_Lagunov.������.wallet SET wallet.amount = @sum_var WHERE wallet.id_currency = @currency_sale
					END
					ELSE
					BEGIN
						DELETE KB301_Lagunov.������.wallet WHERE wallet.id_currency = @currency_sale
					END
					UPDATE KB301_Lagunov.������.wallet SET wallet.amount = @sum_var2 WHERE wallet.id_currency = @currency_buy
				END
				ELSE
				BEGIN
					PRINT '������������ ��������'
				END
			END
			ELSE
			BEGIN
				PRINT N'������ ' + @currency_buy + N' ��� � ��������.'
				IF	@amount <= 922337203685477.5807
				BEGIN
					UPDATE KB301_Lagunov.������.wallet SET wallet.amount = @sum_var WHERE wallet.id_currency = @currency_sale
					INSERT INTO KB301_Lagunov.������.wallet
					VALUES
					(@currency_buy, @amount)
				END
				ELSE
				BEGIN
					PRINT '������������ ��������'
				END
			END
		END
		ELSE
		BEGIN
			PRINT '�������� ����������� - �� ������� ������ ' + @currency_sale
		END
	end
	ELSE
	BEGIN
		PRINT '�������� ����������� - �� ������� ������ ' + @currency_sale
	END
END
GO


CREATE PROCEDURE CleanWallet
AS
BEGIN
	DECLARE @cur_cursor CURSOR, @id_cur CHAR(3)
	SET @cur_cursor = CURSOR
	FOR SELECT wallet.id_currency From KB301_Lagunov.������.wallet wallet
	OPEN @cur_cursor
	FETCH NEXT FROM @cur_cursor INTO @id_cur
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DELETE KB301_Lagunov.������.wallet WHERE wallet.id_currency = @id_cur
		FETCH NEXT FROM @cur_cursor INTO @id_cur
	END
	CLOSE @cur_cursor
END


--�������� ���������� ��������
SELECT * FROM GetWalletContent2()
GO

------------------------------------------------------
--�������� ������ ������� � ������
EXEC GetWalletAmount @currency_name = 'RUB'
GO

------------------------------------------------------
--��������� ����� amount = 100 ������ @currency_name = 'RUB' � ������� ���������
EXEC AddIncome @currency_name = 'RUB', @amount = 100500
GO

SELECT * FROM GetWalletContent2()
GO

------------------------------------------------------
--����� � �������� 300 ������
EXEC AddExpence @currency_name = 'RUB', @amount = 300
GO

SELECT * FROM GetWalletContent2()
GO

------------------------------------------------------
--��������� 100 ������ � ������� ���
EXEC ConvertExpence @currency_from = 'RUB', @currency_to = 'USD', @amount = 100
GO

SELECT * FROM GetWalletContent2()
GO

-------------------------------------------------------
--�������� ������� � ���������� ���������
exec CleanWallet
go

SELECT * FROM GetWalletContent2()
GO

--------------------------------------------------------
--������ 100 �������� �� �����
exec BuyCurrencyByCurrency @currency_buy = 'USD', @currency_sale = 'RUB', @amount = 100
go

SELECT * FROM GetWalletContent2()
GO