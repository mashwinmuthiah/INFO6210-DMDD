USE AdventureWorks2008R2;
------------------------------------------------------------------------------------------------------------------------- Pivot
-- SQL statement to create the vertical format

SELECT DaysToManufacture, AVG(StandardCost) AS AverageCost 
FROM Production.Product
GROUP BY DaysToManufacture
ORDER BY DaysToManufacture;

-- Pivot table with one row and five columns

SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days, 
[0], [1], [2], [4]
FROM
(SELECT DaysToManufacture, StandardCost 
    FROM Production.Product) AS SourceTable
PIVOT
(
AVG(StandardCost)
FOR DaysToManufacture IN ([0], [1], [2], [4])
) AS PivotTable;

-- SQL statement to create the vertical format

SELECT EmployeeID, COUNT(PurchaseOrderID) AS [Order Count]
FROM Purchasing.PurchaseOrderHeader
WHERE EmployeeID IN (250, 251, 256, 257, 260)
GROUP BY EmployeeID
ORDER BY EmployeeID;

-- Pivot table with one row and six columns
SELECT 'Order Count' AS ' ',[250],[251],[256],[257],[260]
FROM
(SELECT EmployeeID,PurchaseOrderID FROM Purchasing.PurchaseOrderHeader) as SourceTable
PIVOT
(COUNT(PurchaseOrderID) FOR EmployeeID IN ([250],[251],[256],[257],[260])) as PivotTable

-- SQL statement to create the vertical format

SELECT EmployeeID, VendorID, COUNT(PurchaseOrderID) AS [Order Count]
FROM Purchasing.PurchaseOrderHeader
WHERE EmployeeID IN (250, 251, 256, 257, 260)
GROUP BY EmployeeID, VendorID
ORDER BY EmployeeID, VendorID;

-- Pivot table

SELECT VendorID,[250] AS Emp1, [251] AS Emp2, [256] AS Emp3, [257] AS Emp4, [260] AS Emp5
FROM (SELECT EmployeeID, VendorID, PurchaseOrderID FROM Purchasing.PurchaseOrderHeader ) as SourceTable
PIVOT
(COUNT(PurchaseOrderID)FOR EmployeeID IN
( [250], [251], [256], [257], [260] )
) AS PivotTable
ORDER by PivotTable.VendorID

USE AdventureWorks2012;

-- PIVOT Exercise Question
-- SQL statement to create the vertical format

SELECT TerritoryID, SalesPersonID, COUNT(SalesOrderID) AS [Order
Count]
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IN (280, 281, 282, 283, 284, 285, 286, 287,
 288, 289, 290, 291, 292, 293, 294, 295)
GROUP BY TerritoryID, SalesPersonID
ORDER BY TerritoryID, SalesPersonID;

-- SQL statement to create the Pivot

SELECT TerritoryID,[280], [281], [282], [283], [284], [285], [286], [287],
 [288], [289], [290], [291], [292], [293], [294], [295]
 FROM
(SELECT TerritoryID, SalesPersonID,SalesOrderID FROM Sales.SalesOrderHeader) as sourcetable
PIVOT
(COUNT(SalesOrderID) for SalesPersonID in ([280], [281], [282], [283], [284], [285], [286], [287],
 [288], [289], [290], [291], [292], [293], [294], [295])) as pivottable

 
--- Vertical Table 
SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date], COUNT(CustomerID) AS [Customer Count]
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '3-1-2008' AND '3-5-2008'
GROUP BY TerritoryID, OrderDate
ORDER BY TerritoryID, OrderDate;


--pivot table
SELECT
	TerritoryID,
	[2008-3-1],
	[2008-3-2],
	[2008-3-3],
	[2008-3-4],
	[2008-3-5]
FROM(SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date],CustomerID
	FROM Sales.SalesOrderHeader) SourceTable 
PIVOT( COUNT (CustomerID) FOR [Order Date] IN ([2008-3-1],
	[2008-3-2],
	[2008-3-3],
	[2008-3-4],
	[2008-3-5]) ) AS PivotTable;
------------------------------------------------------------------------------------------------------------------------ UnPivot
USE murugappan_ashwin_test;

CREATE TABLE dbo.CustomerPhone
(CustomerID INT,
 Phone1 varchar(20),
 Phone2 varchar(20),
 Phone3 varchar(20));

-- Insert some demo data
INSERT INTO CustomerPhone
VALUES
(1, 4252223535, 2061237878, NULL),
(2, 4255554343, 4256142000, 4257776565),
(3, 2057575, NULL, NULL);


-- See what we have in demo table
SELECT * FROM CustomerPhone;

SELECT CustomerId,phone FROM
(SELECT CustomerId,Phone1,Phone2,Phone3 from dbo.CustomerPhone) as orginal
UNPIVOT
(phone for phones in (Phone1,Phone2,Phone3)) as unp;


DROP TABLE dbo.CustomerPhone;

