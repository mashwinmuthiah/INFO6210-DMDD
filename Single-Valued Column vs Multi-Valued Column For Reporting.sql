USE AdventureWorks2008R2;
/* Single-Valued Column vs Multi-Valued Column For Reporting */

/* For one customer */

-- vertical list

SELECT SalesOrderID
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 14328
ORDER BY SalesOrderID;

-- horizontal list

DECLARE @list varchar(max) = '';

SELECT @list = @list + ' ' + RTRIM(CAST(SalesOrderID as char)) + ',' 
FROM Sales.SalesOrderHeader 
WHERE CustomerID = 14328
ORDER BY SalesOrderID;

SELECT LEFT(@list, LEN(@list) -1) AS Orders;

/* For many customers */

-- vertical list

SELECT DISTINCT h.CustomerID, p.FirstName, p.LastName, h.SalesOrderID   
FROM Sales.SalesOrderHeader h
JOIN Sales.Customer c
ON h.CustomerID = c.CustomerID
JOIN Person.Person p
ON c.PersonID = p.BusinessEntityID
ORDER BY CustomerID, SalesOrderID;

-- horizontal list

SELECT DISTINCT h.CustomerID, p.FirstName, p.LastName,
STUFF((SELECT  ', '+RTRIM(CAST(SalesOrderID as char))  
       FROM Sales.SalesOrderHeader 
       WHERE CustomerID = c.customerid
       ORDER BY SalesOrderID
       FOR XML PATH('')) , 1, 2, '') AS Orders
FROM Sales.SalesOrderHeader h
JOIN Sales.Customer c
ON h.CustomerID = c.CustomerID
JOIN Person.Person p
ON c.PersonID = p.BusinessEntityID
ORDER BY CustomerID;
