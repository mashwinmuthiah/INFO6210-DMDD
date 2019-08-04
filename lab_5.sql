USE MURUGAPPAN_ASHWIN_TEST;

-- Lab 5-1
DROP FUNCTION dbo.totalsalesyearmonth;
CREATE FUNCTION dbo.totalsalesyearmonth
(@y INT, @m INT)
RETURNS FLOAT
AS
BEGIN
	DECLARE @totalsum FLOAT;
	IF EXISTS (SELECT TotalDue
		FROM AdventureWorks2008R2.sales.salesOrderHeader
		WHERE YEAR(OrderDate) = @y AND MONTH(OrderDate) = @m)
	SELECT @totalsum = sum(TotalDue)
		FROM AdventureWorks2008R2.sales.salesOrderHeader
		WHERE YEAR(OrderDate) = @y AND MONTH(OrderDate) = @m;
	ELSE
		BEGIN
			SET @totalsum = 0;
		END
	RETURN @totalsum;
END;

SELECT dbo.totalsalesyearmonth(2008,3); -- Trial run Lab 5-1

--Lab 5-2
DROP TABLE dbo.DateRange;
DROP PROCEDURE dbo.populatetable;


CREATE TABLE
	dbo.DateRange (DateID INT IDENTITY,
	DateValue DATE,
	Month INT,
	DayOfWeek INT);

CREATE PROCEDURE dbo.populatetable
	@d DATE,@n INT
AS
BEGIN
	WHILE @n <> 0
		BEGIN
			INSERT INTO dbo.DateRange (DateValue,Month,DayOfWeek)
			SELECT @d,MONTH(@d),DATEPART(dw,@d)
			SET @d = DATEADD(d,1,@d);
			SET @n = @n - 1;
		END
END
-- Trial run Lab 5-2
DECLARE @d DATE;
DECLARE @n INT;

SET @d = GETDATE();
SET @n = 7;

EXEC dbo.populatetable @d,@n;

SELECT * FROM dbo.DateRange;

-- Lab 5-3

DROP TABLE dbo.Customer;
DROP TABLE dbo.SaleOrder;
DROP TABLE dbo.SaleOrderDetail;

CREATE TABLE dbo.Customer
(CustomerID VARCHAR(20) PRIMARY KEY,
CustomerLName VARCHAR(30),
CustomerFName VARCHAR(30),
CustomerStatus VARCHAR(10));

CREATE TABLE dbo.SaleOrder
(OrderID INT IDENTITY PRIMARY KEY,
CustomerID VARCHAR(20) REFERENCES dbo.Customer(CustomerID),
OrderDate DATE,
OrderAmountBeforeTax INT);

CREATE TABLE dbo.SaleOrderDetail
(OrderID INT REFERENCES dbo.SaleOrder(OrderID),
ProductID INT,
Quantity INT,
UnitPrice INT,
PRIMARY KEY (OrderID, ProductID));

DROP TRIGGER dbo.UpdateCustomerStatus;

CREATE TRIGGER dbo.UpdateCustomerStatus 
ON dbo.SaleOrder 
FOR INSERT,UPDATE
AS
	BEGIN
		DECLARE @ThisCustomerID INT;
		DECLARE @TotalAmountBeforeTax FLOAT;
	SELECT @ThisCustomerID = CustomerID FROM inserted;
SET
@TotalAmountBeforeTax = ( Select Sum(OrderAmountBeforeTax) FROM dbo.SaleOrder WHERE CustomerID = @ThisCustomerID);

IF @TotalAmountBeforeTax >= 5000
BEGIN
UPDATE
	dbo.Customer
SET
	CustomerStatus = 'Preffered'
WHERE
	CustomerID = @ThisCustomerID;
END;
END;


-- Lab 5-4

USE AdventureWorks2008R2;

WITH temp1 AS (
	SELECT CustomerID,
	count(SalesOrderID) TotalOrderCount
FROM
	Sales.SalesOrderHeader
GROUP BY
	CustomerID),
	
temp2 AS (
	SELECT CustomerID,
	count(DISTINCT sd.ProductID) TotalUniqueProducts
FROM
	Sales.SalesOrderHeader sh
JOIN Sales.SalesOrderDetail sd ON
	sh.SalesOrderID = sd.SalesOrderID
GROUP BY
	CustomerID) 
SELECT
	c.CustomerID,
	p.FirstName,
	p.LastName,
	t1.TotalOrderCount,
	t2.TotalUniqueProducts
FROM
	Sales.Customer c
JOIN Person.Person p ON
	c.PersonID = p.BusinessEntityID
JOIN temp1 t1 ON
	c.CustomerID = t1.CustomerID
JOIN temp2 t2 ON
	c.CustomerID = t2.CustomerID
ORDER BY
	c.CustomerID;




























