USE AdventureWorks2008R2;

/* CASE function allows conditional processing. */
-- Example of a CASE function
-- The ROUND function does number rounding

SELECT
	ProductID ,
	Name ,
	ListPrice ,
	(
		SELECT ROUND(AVG(ListPrice), 2) AS AvgPrice
	FROM
		Production.Product) AP ,
	CASE
		WHEN ListPrice - (
			SELECT ROUND(AVG(ListPrice), 2) AS AvgPrice
		FROM
			Production.Product) = 0 THEN 'Average Price'
		WHEN ListPrice - (
			SELECT ROUND(AVG(ListPrice), 2) AS AvgPrice
		FROM
			Production.Product) < 0 THEN 'Below Average Price'
		ELSE 'Above Average Price'
	END AS PriceComparison
FROM
	Production.Product
ORDER BY
	ListPrice DESC;


/*
 Use the RANK function without/with the PARTITION BY clause
 to return the rank of each row.
*/
-- Without PARTITION BY
/*
 If the PARTITIAN BY clause is not used, the entire row set
 returned by a query will be treated as a single big partition.
*/

SELECT
	RANK() OVER (
	ORDER BY OrderQty DESC) as [Rank],
	SalesOrderID,
	ProductID,
	UnitPrice,
	OrderQty
FROM
	Sales.SalesOrderDetail
WHERE
	UnitPrice >75;

-- With PARTITION BY
/*
 When the PARTITIAN BY clause is used, the ranking will be
 performed within each partitioning value.
*/
SELECT
	RANK() OVER (PARTITION BY ProductID
ORDER BY
	OrderQty DESC) as [Rank],
	SalesOrderID,
	ProductID,
	UnitPrice,
	OrderQty
FROM
	Sales.SalesOrderDetail
WHERE
	UnitPrice >75;
	
-- RANK
/*
If two or more rows tie for a rank, each tied row receives the same
rank. For example, if the two top salespeople have the same SalesYTD
value, they are both ranked one. The salesperson with the next highest
SalesYTD is ranked number three, because there are two rows that are
ranked higher. Therefore, the RANK function does not always return
consecutive integers. Sometimes we say the RANK function creates gaps.
*/

-- DENSE_RANK
/*
If two or more rows tie for a rank in the same partition, each tied
row receives the same rank. For example, if the two top salespeople
have the same SalesYTD value, they are both ranked one. The
salesperson with the next highest SalesYTD is ranked number two. This
is one more than the number of distinct rows that come before this
row. Therefore, the numbers returned by the DENSE_RANK function do not
have gaps and always have consecutive ranks.
*/

SELECT i.ProductID, p.Name, i.LocationID, i.Quantity
 ,DENSE_RANK() OVER
 (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS Rank
FROM Production.ProductInventory AS i
INNER JOIN Production.Product AS p
 ON i.ProductID = p.ProductID
WHERE i.LocationID BETWEEN 3 AND 4
ORDER BY i.LocationID;

