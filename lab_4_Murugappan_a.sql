-- Part A

-- step 1
Create Database MURUGAPPAN_ASHWIN_TEST;

USE MURUGAPPAN_ASHWIN_TEST;

-- step 2
CREATE TABLE
	TargetCustomers(TargetID INT NOT NULL PRIMARY KEY,
	FirstName varchar(30) NOT NULL,
	LastName varchar(30) NOT NULL,
	Address varchar(30) NOT NULL,
	City varchar(30) NOT NULL,
	State varchar(30) NOT NULL,
	ZipCode INT NOT NULL);

CREATE TABLE
	MailingLists(MailingListsID INT NOT NULL PRIMARY KEY,
	MailingList varchar(30) NOT NULL);

CREATE TABLE
	TargetMailingLists(TargetID INT FOREIGN KEY REFERENCES TargetCustomers(TargetID),
	MailingListID INT FOREIGN KEY REFERENCES MailingLists(MailingListsID)
	Constraint PKTargetMailingLists Primary Key Clustered
	(TargetID,MailingListID));

-- Adding sample data

INSERT
	INTO
		TargetCustomers(TargetID,FirstName,LastName,Address,City,State,ZipCode)
	VALUES 
	(1,'Ashwin','Murugappan','110 ward street','Boston','MA',02120),
	(2,'Mahesh','Naga','5 Peterborough St.','Boston','MA',02113),
	(3,'Ajith','venkatasulu','110 ward street','Boston','MA',02120),
	(4,'Rob','Martin','10 Stephen St','Boston','MA',02115),
	(5,'Lady','Gaya','10 Malibu Fun House','Boston','MA',02115);

INSERT
	INTO 
		MailingLists(MailingListsID,MailingList)
	VALUES
		(1,'Fist products'),
		(2,'Books'),
		(3,'Guns'),
		(4,'Basement Guides'),
		(5,'Gardening');
INSERT 
	INTO
		TargetMailingLists(TargetID,MailingListID)
	VALUES
		(1,5),
		(1,3),
		(2,4),
		(3,3),
		(4,2),
		(5,1);
	
-- Trying out queries

SELECT
	*
FROM
	TargetCustomers
WHERE
	ZipCode = 2120;
--
SELECT
	*
FROM
	MailingLists;
--
SELECT
	*
FROM
	TargetCustomers;
--
SELECT
	c.TargetID,
	LastName ,
	MailingList,
	CASE
		WHEN Zipcode = 2120 then 'South Boston'
		WHEN Zipcode = 2113 then 'North Boston'
		WHEN Zipcode = 2115 then 'East Boston'
		ELSE 'West Boston'
	END AS Location
FROM
	TargetCustomers c
JOIN TargetMailingLists m on
	c.TargetID = m.TargetID
JOIN MailingLists l on
	l.MailingListsID = m.MailingListID;
--
SELECT
	RANK() OVER (
	ORDER by ZipCode DESC) AS [Closest],
	Address
FROM
	TargetCustomers;
--
SELECT
	RANK() OVER (PARTITION by ZipCode
ORDER BY
	lastname DESC) AS [Closest],
	FirstName,
	Address
FROM
	TargetCustomers;
--
SELECT
	FirstName
FROM
	TargetCustomers
WHERE
	FirstName LIKE '%m%';
--
SELECT
	*
FROM
	TargetCustomers
WHERE
	LastName NOT IN ('Murugappan');
--
SELECT
	COUNT(*) AS 'COUNT'
FROM
	TargetCustomers
WHERE
	ZipCode = 02120;

-- 
WITH temp AS (
SELECT
	DISTINCT ZipCode,
	LastName
FROM
	TargetCustomers) SELECT
	DISTINCT t2.ZipCode,
	STUFF(( SELECT ', ' + RTRIM(CAST(LastName as char))
	FROM
		temp t1
	WHERE
		t1.ZipCode = t2.ZipCode FOR XML PATH('')) ,1,2,'') AS LastNames
FROM
	temp t2
ORDER BY
	ZipCode DESC;

--
UPDATE
	MailingLists
SET
	MailingList = 'Dog'
WHERE
	MailingListsID = 4;
--
SELECT
	*
FROM
	(
		SELECT ROW_NUMBER () OVER (
		ORDER BY TargetID) AS RowNum,
		*
	FROM
		TargetCustomers) sub
WHERE
	RowNum = 3
--
 Select
		*
	FROM
		TargetCustomers
	WHERE
		TargetID = (
			SELECT max(TargetID)
		FROM
			TargetCustomers);
		
--
SELECT
	TOP 1 WITH TIES *
FROM
	TargetCustomers
ORDER BY
	ZipCode DESC;
--
SELECT
	CONCAT(TC.FirstName, ' ', TC.LastName) AS 'COMPLETE_NAME'
FROM
	TargetCustomers TC ;

-- Step 3 

DROP TABLE IF EXISTS TargetCustomers;
DROP TABLE IF EXISTS MailingLists;
DROP TABLE IF EXISTS TargetMailingLists;

CREATE TABLE
	TargetCustomers(TargetID INT NOT NULL PRIMARY KEY,
	FirstName varchar(30) NOT NULL,
	LastName varchar(30) NOT NULL,
	Address varchar(30) NOT NULL,
	City varchar(30) NOT NULL,
	State varchar(30) NOT NULL,
	ZipCode INT NOT NULL);

CREATE TABLE
	MailingLists(MailingListsID INT NOT NULL PRIMARY KEY,
	MailingList varchar(30) NOT NULL);

CREATE TABLE
	TargetMailingLists(TargetID INT FOREIGN KEY REFERENCES TargetCustomers(TargetID),
	MailingListID INT FOREIGN KEY REFERENCES MailingLists(MailingListsID)
	Constraint PKTargetMailingLists Primary Key Clustered
	(TargetID,MailingListID));

--------------------------------------------------------------------------------------------

-- Part B 

USE AdventureWorks2008R2;

WITH temp AS (
	SELECT DISTINCT CustomerID,
	SalesPersonID,
	ISNULL(CAST(SalesPersonID AS varchar(20)),'') idNEW
FROM
	Sales.SalesOrderHeader) SELECT
	DISTINCT t2.CustomerID,
	STUFF( (
		SELECT ', ' + RTRIM(CAST(idNEW as char))
	FROM
		temp t1
	WHERE
		t1.CustomerID = t2.CustomerID FOR XML PATH('')) ,1,2,'') AS listSalesPersonID
FROM
	temp t2
ORDER BY
	CustomerID DESC;

--------------------------------------------------------------------------------------------

-- Part C

WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
 SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,
 b.EndDate, 0 AS ComponentLevel
 FROM Production.BillOfMaterials AS b
 WHERE b.ProductAssemblyID = 992 AND b.EndDate IS NULL
 UNION ALL
 SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty,
 bom.EndDate, ComponentLevel + 1
 FROM Production.BillOfMaterials AS bom
 INNER JOIN Parts AS p
 ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL
)
SELECT AssemblyID, ComponentID, ListPrice, PerAssemblyQty, ComponentLevel
INTO #TempTable 
FROM Parts AS p
    INNER JOIN Production.Product AS pr
    ON p.ComponentID = pr.ProductID
ORDER BY ComponentLevel, AssemblyID, ComponentID;

SELECT CAST((
(SELECT SUM(ListPrice)
FROM #TempTable
WHERE ComponentLevel = 0  AND  ComponentID = 815)
-
(SELECT SUM(ListPrice)
FROM #TempTable
WHERE ComponentLevel = 1 and AssemblyID = 815 )) AS DECIMAL(8,4)) AS TotalCost;

IF EXISTS (SELECT * from #TempTable)
DROP TABLE #TempTable;
