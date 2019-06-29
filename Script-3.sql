USE adventureworks2008R2;

-- Lab 2 Exercise 

SELECT
	COUNT(CreditCardID) as [cards]
FROM
	Sales.SalesOrderHeader;

SELECT
	CustomerID,
	AccountNumber,
	COUNT(SalesOrderID) AS '# of Orders'
FROM
	AdventureWorks2008R2.Sales.SalesOrderHeader
GROUP BY
	CustomerID,
	AccountNumber
ORDER BY
	'# of Orders' DESC;
-- Exercise 1
 /* Retrieve only the following columns from the
 Production.Product table:
Product ID
Name
Selling start date
Selling end date
Size
Weight */
SELECT
	ProductID,
	Name,
	sellstartdate,
	sellenddate,
	Size,
	weight
from
	production.product
	-- Exercise 2
 /* Select all info for all orders with no credit card id. */
	select
		*
	from
		sales.salesorderheader
	where
		CreditCardId is null;
-- Exercise 3
 /* Select all info for all products with size specified. */
select
	*
from
	production.product
where
	size is not null;
-- Exercise 4
 /* Select all information for products that started selling
 between January 1, 2007 and December 31, 2007. */
select
	*
from
	production.product
where
	sellstartdate between '1/1/2007' and '12/31/2007'
	-- Exercise 5
 /* Select all info for all orders placed in June 2007 using date
 functions, and include a column for an estimated delivery date
 that is 7 days after the order date. */
	SELECT
		DATEADD(DAY,
		7,
		OrderDate) AS [Est. Delivery Date]
	FROM
		Sales.SalesOrderHeader
	WHERE
		DATEPART(MONTH,
		OrderDate) = 6
		and DATEPART(YEAR,
		OrderDate) = 2007;
-- Exercise 6
 /* Determine the date that is 30 days from today and display only
 the date in mm/dd/yyyy format (4-digit year). */
SELECT
	CONVERT(CHAR(20),
	dateadd(day,
	30,
	getdate()),
	101)
	-- Exercise 7
 /* Determine the number of orders, overall total due,
 average of total due, amount of the smallest amount due, and
 amount of the largest amount due for all orders placed in May
 2008. Make sure all columns have a descriptive heading. */
	select
		count(salesorderid),
		sum(totaldue),
		avg(totaldue),
		min(totaldue),
		max(totaldue)
	from
		sales.salesorderheader
	where
		datepart(MONTH,
		orderdate) = 5
		and datepart(year,
		orderdate) = 2008;
-- Exercise 8
 /* Retrieve the Customer ID, total number of orders and overall total
 due for the customers who placed more than one order in 2007
 and sort the result by the overall total due in the descending
 order. */
select
	CustomerID,
	count(SalesOrderID) [NoOfOrder],
	sum(TotalDue)
from
	sales.salesorderheader
WHERE
	datepart(YEAR,
	orderdate) = 2007
GROUP BY
	CustomerID
HAVING
	count(SalesOrderID) > 1 ;
-- Exercise 9
 /*
 Provide a unique list of the sales person ids who have sold
 the product id 777. Sort the list by the sales person id. */
SELECT
	DISTINCT (SalesPersonID)
FROM
	sales.salesorderheader s
JOIN sales.SalesOrderDetail d on
	s.SalesOrderID = d.SalesOrderID
WHERE
	d.ProductID = 777
ORDER BY
	SalesPersonID;
-- Exercise 10
 /* List the product ID, name, list price, size of products
 Under the ‘Bikes’ category (ProductCategoryID = 1) and
 Subcategory ‘Mountain Bikes’. */
SELECT
	p.ProductID,
	p.Name,
	p.ListPrice,
	p.Size
FROM
	Production.Product p
JOIN Production.ProductSubcategory s ON
	p.ProductSubcategoryID = s.ProductSubcategoryID
WHERE
	s.ProductCategoryID = 1
	AND s.name = 'Mountain Bikes';
-- Exercise 11
 /* List the SalesOrderID and currency name for each order. */
select
	soh.SalesOrderID,
	crc.Name
from
	Sales.SalesOrderHeader soh
join Sales.CurrencyRate cr on
	soh.CurrencyRateID = cr.CurrencyRateID
join Sales.Currency crc on
	cr.ToCurrencyCode = crc.CurrencyCode;
	
-- Lab 3 exercise

-- Exercise 1
/*
 SELECT ProductID, Name, ListPrice FROM Production.Product.
 Use the CASE function to display "Expensive" if ListPrice > 3000
 "Medium" if ListPrice > 1000
"Low" if ListPrice <= 1000.
 ORDER the results DESC BY ListPrice.
*/

SELECT
	ProductID,
	Name,
	ListPrice,
	CASE
		WHEN ListPrice > 3000 THEN 'Expensive'
		WHEN ListPrice > 1000 THEN 'Medium'
		ELSE 'Low'
	END AS Pricecategory
FROM
	Production.Product
order by
	ListPrice DESC;

 -- Exercise 2
/*
 SELECT SalesOrderID, CustomerID, TotalDue
 FROM Sales.SalesOrderHeader
 WHERE TotalDue > 10000
 and RANK them with gaps in the desc order of TotalDue
*/

SELECT
	SalesOrderID,
	CustomerID,
	TotalDue,
	RANK() OVER (
ORDER BY
	TotalDue DESC ) as Ranks
FROM
	Sales.SalesOrderHeader
WHERE
	TotalDue > 10000

-- Exercise 3

/*
 SELECT SalesOrderID, CustomerID, TotalDue
 FROM Sales.SalesOrderHeader
 WHERE TotalDue > 10000
 and RANK them with gaps in the desc order of TotalDue
 also PARTITION BY CustomerID
*/
SELECT
	SalesOrderId,
	CustomerID,
	TotalDue,
	RANK() OVER (PARTITION BY CustomerID
ORDER BY
	TotalDue DESC) [Ranks]
FROM
	Sales.SalesOrderHeader
WHERE
	TotalDue >10000

-- Exercise 4
/*
 SELECT SalesOrderID, CustomerID, TotalDue
 FROM Sales.SalesOrderHeader
 WHERE TotalDue > 10000
 and RANK them with gaps in the desc order of TotalDue
 also PARTITION BY CustomerID
 Display only the highest total due amount for each customer.
*/

WITH temp AS (
	SELECT SalesOrderID,
	CustomerID,
	TotalDue,
	RANK() OVER(PARTITION by CustomerID
ORDER BY
	TotalDue DESC) [Rank]
FROM
	Sales.SalesOrderHeader
WHERE
	TotalDue > 10000) SELECT
	*
FROM
	temp
WHERE
	Rank = 1;

-- Exercise 5
/* List the product id, product name, and order date of each
 product sold in 2008.
*/

SELECT
	 DISTINCT p.ProductID,
	p.Name,
	s.OrderDate
FROM
	Sales.SalesOrderHeader s
JOIN Sales.SalesOrderDetail d ON
	s.SalesOrderID = d.SalesOrderID
JOIN Production.Product p ON
	d.ProductID = p.ProductID
WHERE
	datepart(YEAR,
	OrderDate) = 2008
	
-- Exercise 6
/* What is the name and average rating for the product with
 ProductID = 937? */
SELECT
	p.name,
	AVG(rating) [Rating]
from
	Production.Product p
JOIN Production.ProductReview r ON
	p.ProductID = r.ProductID
WHERE p.ProductID = 937
GROUP BY
	p.name;

select pdt.name, avg(pr.rating) as rating
from Production.Product pdt
join Production.ProductReview pr
on pdt.ProductID = pr.ProductID
where pr.ProductID = 937
group by pdt.Name;


-- Exercise 7
/* Use the SubTotal value in SalesOrderHeader to calculate
 total value. What is the total value of products sold to
 an address in 'Seattle'? */

select ad.city, sum(SubTotal) as total_value
from Sales.SalesOrderHeader soh
join Person.Address ad on soh.ShipToAddressID = ad.AddressID
where ad.city = 'Seattle'
group by ad.city;

-- Lab 2 Questions 

-- 2-1

/* Select product id, name and selling start date for all products
 that started selling after 01/01/2007 and had a black color.
 Use the CAST function to display the date only. Sort the returned
 data by the selling start date.
 Hint: a: You need to work with the Production.Product table.
 b: The syntax for CAST is CAST(expression AS data_type),
 where expression is the column name we want to format and
 we can use DATE as data_type for this question to display
 just the date. */
USE adventureworks2008R2;
SELECT ProductID,Name,SellStartDate from Production.Product
