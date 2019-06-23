-- Lab 3 
USE AdventureWorks2008R2;

-- Lab 3-1

/* Modify the following query to add a column that identifies the
 frequency of repeat customers and contains the following values
 based on the number of orders during 2007:
'No Orders' for count = 0
'One Time' for count = 1
'Regular' for count range of 2-5
'Often' for count range of 6-12
'Very Often' for count greater than 12
 Give the new column an alias to make the report more readable. */

SELECT
	c.CustomerID,
	c.TerritoryID,
	COUNT(o.SalesOrderid) [Total Orders],
	CASE
		WHEN COUNT(o.SalesOrderid) = 0 THEN 'No Order'
		WHEN COUNT(o.SalesOrderid) = 1 THEN 'One Time'
		WHEN COUNT(o.SalesOrderid) BETWEEN 2 AND 5 THEN 'Regular'
		WHEN COUNT(o.SalesOrderid) BETWEEN 6 AND 12 THEN 'Often'
		ELSE 'Very Often'
	END
FROM
	Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader o ON
	c.CustomerID = o.CustomerID
WHERE
	DATEPART(year,
	OrderDate) = 2007
GROUP BY
	c.TerritoryID,
	c.CustomerID;


-- Lab 3-2

/* Modify the following query to add a rank without gaps in the
 ranking based on total orders in the descending order. Also
 partition by territory.*/

SELECT
	c.CustomerID,
	c.TerritoryID,
	COUNT(o.SalesOrderid) [Total Orders] ,
	DENSE_RANK() OVER (PARTITION BY c.TerritoryID
ORDER BY
	COUNT(o.SalesOrderid)) as Ranking
FROM
	Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader o ON
	c.CustomerID = o.CustomerID
WHERE
	DATEPART(year,
	OrderDate) = 2007
GROUP BY
	c.TerritoryID,
	c.CustomerID;


-- Lab 3-3

/* Write a query that returns the highest bonus amount
 ever received by male sales people in Canada. */

SELECT
	TOP (1) p.bonus
FROM
	Sales.SalesPerson p
LEFT JOIN sales.SalesTerritory t ON
	p.TerritoryId = t.TerritoryId
LEFT JOIN HumanResources.Employee e ON
	p.BusinessEntityID = e.BusinessEntityID
WHERE
	t.name = 'Canada'
	AND e.gender = 'm'
ORDER BY
	p.bonus DESC


-- Lab 3-4
/* Write a query to list the most popular product color for each month
 of 2007, considering all products sold in each month. The most
 popular product color had the highest total quantity sold for
 all products in that color.
 Return the most popular product color and the total quantity of
 the sold products in that color for each month in the result set.
 Sort the returned data by month.

 Exclude the products that don't have a specified color. */
		
WITH temp AS (
	SELECT MONTH(h.OrderDate) [MonthOfYear],
	p.Color [color],
	SUM(d.OrderQty) [TotalQualtity],
	RANK() OVER (PARTITION BY MONTH(h.OrderDate)
ORDER BY
	SUM(d.OrderQty) DESC) AS ColorRank
FROM
	sales.salesorderheader h
JOIN sales.salesorderdetail d ON
	h.salesorderid = d.salesorderid
JOIN production.product p ON
	d.productid = p.productid
WHERE
	color IS NOT NULL
GROUP by
	MONTH(h.OrderDate),
	p.color) SELECT
	MonthOfYear,
	color,
	TotalQualtity
FROM
	temp
WHERE
	ColorRank = 1

-- Lab 3-5
/* Write a query to retrieve the distinct customer id's and
 account numbers for the customers who have placed an order
 before but have never purchased the product 708. Sort the
 results by the customer id in the ascending order. */

SELECT
	DISTINCT(h.CustomerId),
	c.AccountNumber
FROM
	sales.SalesOrderHeader h
LEFT JOIN sales.Customer c ON
	h.CustomerId = c.CustomerId
LEFT JOIN sales.SalesOrderDetail d ON
	h.SalesOrderId = d.salesOrderId
WHERE
	d.ProductId NOT IN (708)
ORDER BY
	h.CustomerId
	