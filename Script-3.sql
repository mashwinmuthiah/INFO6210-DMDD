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
		SELECT
			SalesOrderID,
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
	WHERE
		p.ProductID = 937
	GROUP BY
		p.name;

select
	pdt.name,
	avg(pr.rating) as rating
from
	Production.Product pdt
join Production.ProductReview pr on
	pdt.ProductID = pr.ProductID
where
	pr.ProductID = 937
group by
	pdt.Name;
-- Exercise 7
 /* Use the SubTotal value in SalesOrderHeader to calculate
 total value. What is the total value of products sold to
 an address in 'Seattle'? */
select
	ad.city,
	sum(SubTotal) as total_value
from
	Sales.SalesOrderHeader soh
join Person.Address ad on
	soh.ShipToAddressID = ad.AddressID
where
	ad.city = 'Seattle'
group by
	ad.city;
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

SELECT
	ProductID,
	Name,
	CAST(SellStartDate as date) as SellingStartDate
from
	Production.Product
WHERE
	color = 'black'
	and sellstartdate > '01/01/2007'
Order by
	SellStartDate;

--2-2
/* Retrieve the customer ID, account number, oldest order date
 and total number of orders for each customer.
 Use column aliases to make the report more presentable.
 Sort the returned data by the total number of orders in
 the descending order.
 Hint: You need to work with the Sales.SalesOrderHeader table. */

SELECT
	CustomerId,
	AccountNumber,
	CAST(MIN(OrderDate) as Date) as [Date] ,
	COUNT(SalesOrderId) as [No.Of orders]
	from Sales.SalesOrderHeader
GROUP BY
	CustomerId,
	AccountNumber
ORDER BY
	[No.Of orders] DESC


--2-3
/* Write a query to select the product id, name, and list price
 for the product(s) that have the highest list price.
 Hint: You’ll need to use a simple subquery to get the highest
 list price and use it in a WHERE clause. */

SELECT
	ProductId,
	Name,
	ListPrice
from
	Production.Product
WHERE
	ListPrice = (
		SELECT MAX(listprice)
	from
		Production.Product);
--2-4
/* Write a query to retrieve the total quantity sold for each product.
 Include only products that have a total quantity sold greater than
 3000. Sort the results by the total quantity sold in the descending
 order. Include the product ID, product name, and total quantity
 sold columns in the report.
*/
select
	p.ProductID,
	Name,
	sum(OrderQty) [Total Quantity]
from
	Production.Product p
JOIN sales.salesOrderDetail h ON
	p.ProductID = h.ProductID
GROUP BY p.ProductID,name
HAVING
	sum(OrderQty) > 3000
ORDER by
	[Total Quantity] DESC;

--2-5
/* Write a SQL query to generate a list of customer ID's and
 account numbers that have never placed an order before.
 Sort the list by CustomerID in the ascending order. */

SELECT
	CustomerID,
	AccountNumber
from
	sales.Customer
where
	CustomerID not IN (
		SELECT customerID
	from
		sales.salesOrderHeader)
ORDER BY
	CustomerID ;

--2-6
/* Write a query to create a report containing customer id,
 first name, last name and email address for all customers.
 Sort the returned data by CustomerID. */

SELECT
	CustomerID,
	FirstName,
	LastName,
	EmailAddress
FROM
	sales.Customer c
JOIN Person.Person p ON
	c.PersonID = p.BusinessEntityID
JOIN Person.EmailAddress e on
	c.PersonID = e.BusinessEntityID
ORDER BY
	CustomerId;

-- Lab 3 Exercise.
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

SELECT c.CustomerID, c.TerritoryID,
 COUNT(o.SalesOrderid) [Total Orders],
CASE     WHEN COUNT(o.SalesOrderid) = 1 THEN 'One Time' 
         WHEN COUNT(o.SalesOrderid) between 2 and 5 THEN 'Regular' 
         WHEN COUNT(o.SalesOrderid) between 6 and 12 THEN 'Often'  
         WHEN COUNT(o.SalesOrderid) > 12 THEN 'Very Often'  
         ELSE 'No Orders'
		 END AS FREQUENCY
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader o
 ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;

-- Lab 3-2
/* Modify the following query to add a rank without gaps in the
 ranking based on total orders in the descending order. Also
 partition by territory.*/

SELECT c.CustomerID, c.TerritoryID,
 COUNT(o.SalesOrderid) [Total Orders],DENSE_RANK() OVER(PARTITION BY c.TerritoryID ORDER BY COUNT(o.SalesOrderid) DESC ) as Rank
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader o
 ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;

-- Lab 3-3
/* Write a query that returns the highest bonus amount
 ever received by male sales people in Canada. */

SELECT
	TOP 1 with TIES Bonus
from
	sales.salesperson s
join HumanResources.Employee e ON
	s.BusinessEntityID = e.BusinessEntityID
join sales.SalesTerritory t on
	s.TerritoryID = t.TerritoryID
where
	e.gender = 'M'
	and t.name = 'canada'
ORDER BY
	bonus DESC

	
-- Lab 3-4
/* Write a query to list the most popular product color for each month
 of 2007, considering all products sold in each month. The most
 popular product color had the highest total quantity sold for
 all products in that color.
 Return the most popular product color and the total quantity of
 the sold products in that color for each month in the result set.
 Sort the returned data by month.

 Exclude the products that don't have a specified color. */
with temp as 
(SELECT
	color,
	SUM(OrderQty) [totalqty],month(OrderDate) [Months],
	RANK() OVER(PARTITION BY month(OrderDate)
ORDER BY
	SUM(OrderQty) DESC) as Rankings
from
	Sales.SalesOrderHeader h
JOIN sales.SalesOrderDetail d on
	h.SalesOrderID = d.SalesOrderID
JOIN production.Product p on
	d.ProductID = p.ProductId
WHERE Color is not NULL and datepart(YEAR,OrderDate) = 2007
GROUP BY
	color,month(OrderDate))
SELECT * from temp where Rankings = 1;

-- Lab 3-5
/* Write a query to retrieve the distinct customer id's and
 account numbers for the customers who have placed an order
 before but have never purchased the product 708. Sort the
 results by the customer id in the ascending order. */

SELECT
	CustomerId,
	AccountNumber
FROM
	sales.SalesOrderHeader
EXCEPT SELECT
	h.CustomerId,
	h.AccountNumber
from
	sales.SalesOrderHeader h
JOIN sales.SalesOrderDetail d on
	d.SalesOrderID = h.SalesOrderID
where
	d.productId = 708
order by
	customerId

