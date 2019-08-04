
/* Second Last NUID Digit 1 or 2 */

-- Your Name:Ashwin Muthiah Murugappan
-- Your NUID:001472427

-- Question 1 (2 points)
USE AdventureWorks2008R2;
/* The following SQL query generates a report in a vertical format.
   Please convert the query to a PIVOT query that creates a report
   containing the same data but in a horizontal format.
   The returned report should have the format like the one listed below,
   with NULL converted to 0. Use an alias to create a column heading.
   The example format below may not contain all the returned data. */
    
SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date], 
       SUM(TotalDue) AS [Sale Amount]
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '5-1-2008' AND '5-5-2008'
GROUP BY TerritoryID, OrderDate
ORDER BY TerritoryID, OrderDate;

TerritoryID	2008-5-1		2008-5-2	2008-5-3	2008-5-4	2008-5-5
	1		640355.3651		3513.7676	10004.2614	2220.8956	7148.2785
	2		187500.0667		0.00		0.00		0.00		0.00
	3		281836.1068		0.00		0.00		0.00		0.00

SELECT TerritoryID,isnull([2008-5-1],0),isnull([2008-5-2],0),isnull([2008-5-3],0),isnull([2008-5-4],0),isnull([2008-5-5],0)
FROM 
(SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date],TotalDue FROM Sales.SalesOrderHeader) SourceTable
PIVOT(
	SUM(TotalDue) FOR [Order Date] IN ([2008-5-1],[2008-5-2],[2008-5-3],[2008-5-4],[2008-5-5])
) AS PivotTable;
	
-- Question 2 (2 points)

/* Given the following table and data, please write a query
   using UNPIVOT to normalize the data. The output data
   needs to have the format displayed below:
   
   TileID	Color
	520		Yellow
	520		Red
	520		Green
	680		Black
	680		White
	680		Red
	680		Purple
	680		Brown
*/
USE MURUGAPPAN_ASHWIN_TEST;
CREATE TABLE [dbo].[Tiles](
	[TileID] [int] NULL,
	[Color1] [varchar](20) NULL,
	[Color2] [varchar](20) NULL,
	[Color3] [varchar](20) NULL,
	[Color4] [varchar](20) NULL,
	[Color5] [varchar](20) NULL
)
GO
INSERT [dbo].[Tiles] ([TileID], [Color1], [Color2], [Color3], [Color4], [Color5]) VALUES (520, N'Yellow', N'Red', N'Green', NULL, NULL)
GO
INSERT [dbo].[Tiles] ([TileID], [Color1], [Color2], [Color3], [Color4], [Color5]) VALUES (680, N'Black', N'White', N'Red', N'Purple', N'Brown')
GO
INSERT [dbo].[Tiles] ([TileID], [Color1], [Color2], [Color3], [Color4], [Color5]) VALUES (720, N'Red', N'Pink', N'Black', N'Green', NULL)
GO
INSERT [dbo].[Tiles] ([TileID], [Color1], [Color2], [Color3], [Color4], [Color5]) VALUES (760, N'Red', N'Yellow', N'Purple', N'Silver', N'Green')
GO
INSERT [dbo].[Tiles] ([TileID], [Color1], [Color2], [Color3], [Color4], [Color5]) VALUES (800, N'Yellow', N'White', N'Black', NULL, NULL)
GO

SELECT * from [dbo].[Tiles];

SELECT TileID,color FROM
(SELECT TileID,Color1,Color2,Color3,Color4,Color5 from [dbo].[Tiles]) as orginal
UNPIVOT
(color FOR colors IN (Color1,Color2,Color3,Color4,Color5)) as unp;

-- Question 3 (3 points)

/* Write a query to retrieve the top 3 customers, based on the total purchase,
   for each region. The top 3 customers have the 3 highest total purchase amounts.
   Use TotalDue of SalesOrderHeader to calculate the total purchase.
   Also calculate the top 3 customers' total purchase amount.
   Return the data in the following format.

territoryid	Total Sale	Top5Customers
	1		2639574		29818, 29617, 29580
	2		1899953		29701, 29966, 29844
	3		2203384		29827, 29913, 29924
	4		2521259		30117, 29646, 29716
	5		1950980		29715, 29507, 29624
	6		2742459		29722, 29614, 29639
	7		1873658		30103, 29712, 29923
	8		938793		29995, 29693, 29917
	9		583812		29488, 29706, 30059
	10		1565145		30050, 29546, 29587
*/
USE AdventureWorks2008R2;
with temp AS
	(SELECT DISTINCT
		sh.TerritoryID,sum(sh.TotalDue) [Total_Sale],sh.CustomerID,
		RANK() OVER (PARTITION BY TerritoryID ORDER BY SUM(sh.TotalDue) DESC ) AS OrderRank
	FROM sales.SalesOrderHeader sh
	GROUP BY sh.TerritoryID,sh.CustomerID)
SELECT DISTINCT
	t2.TerritoryID,sum(Total_Sale) [Total Sale],
	STUFF(
		(SELECT ', '+RTRIM(CAST(CustomerID as char))+' '
		FROM temp t1
		WHERE t1.TerritoryID = t2.TerritoryID
		AND t1.OrderRank <4
		FOR XML PATH('')),1,2,'') AS Top3Customers
FROM temp t2 WHERE OrderRank<4
GROUP BY TerritoryID
ORDER BY TerritoryID;
	

-- Question 4 (4 points)

/* Given the following tables, there is a business rule
   preventing a user from checking out a book if there is
   an unpaid fine. Please write a table-level constraint
   to implement the business rule. */
USE MURUGAPPAN_ASHWIN_TEST;

create table Book
(InventoryID int primary key,
 ISBN varchar (20),
 Title varchar(50),
 AuthorID int,
 CategoryID int);

create table Customer
(CustomerID int primary key,
 LastName varchar (50),
 FirstName varchar (50),
 PhoneNumber varchar (20));

create table CheckOut
(InventoryID int references Book(InventoryID),
 CustomerID int references Customer(CustomerID),
 CheckOutDate date,
 ReturnDate date
 primary key (InventoryID, CustomerID, CheckOutDate));

create table Fine
(CustomerID int references Customer(CustomerID),
 IssueDate date,
 Amount money,
 PaidDate date
 primary key (CustomerID, IssueDate));

DROP FUNCTION Checkcheckout;
CREATE FUNCTION Checkcheckout(@cid int)
RETURNS INT
AS
BEGIN
	DECLARE @checkflag SMALLINT = 0;
	DECLARE @amount money;
	DECLARE @pdate date;
	SELECT @amount = Amount FROM Fine
	WHERE Fine.CustomerID = @cid
	SELECT @pdate = PaidDate FROM Fine
	WHERE Fine.CustomerID = @cid
	IF @pdate is null and @amount > 0
		SET @checkflag = 1;
	RETURN @checkflag
END

ALTER TABLE CheckOut ADD CONSTRAINT validFine CHECK (dbo.Checkcheckout(CustomerID) = 0);

DROP table Fine;
DROP table CheckOut;
DROP table Customer;
-- Question 5 (4 points)

 /* Given the following tables, there is a $100
    club annual membership fee per customer.
    There is a business rule, if a customer has spent more
	than $5000 for the current year, then the membership fee
	is waived for the current year.
	
	Please write a trigger to implement the business rule.
	The membership fee is stored in the Customer table. */

USE MURUGAPPAN_ASHWIN_TEST;

DROP TABLE Customer;
create table dbo.Customer
(CustomerID int primary key,
 LastName varchar(50),
 FirstName varchar(50),
 MembershipFee money);

DROP table SalesOrder;
create table dbo.SalesOrder
(OrderID int primary key,
 CustomerID int references Customer(CustomerID),
 OrderDate date not null);

DROP table OrderDetailyeah ;
create table OrderDetailyeah 
(OrderID int references SalesOrder(OrderID),
 ProductID int,
 Quantity int not null,
 UnitPrice money not null
 primary key(OrderID, ProductID));

CREATE TRIGGER umemfee
ON SalesOrder
AFTER INSERT,UPDATE,DELETE
AS BEGIN
	DECLARE @t money = 0;
	DECLARE @cusid varchar(20);
	DECLARE @mf money = 0;

	SELECT @cusid = isnull(i.customerID, d.customerId) from INSERTED i FULL JOIN DELETED d on i.customerid = d.customerid;
	SELECT @t = sum(UnitPrice) from SaleOrder JOIN OrderDetail ON SaleOrder.OrderID = OrderDetail.OrderID
    WHERE customerId = @cusid AND DATEPART(year, OrderDate) = YEAR(GetDate());
	IF @t > 5000
		set @mf = 0
	ELSE
		set @mf = 100
	UPDATE Customer set MembershipFee = @mf where customerId = @cusid;
END
