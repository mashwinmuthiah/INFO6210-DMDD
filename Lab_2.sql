USE AdventureWorks2008R2;

-- Question 2-1 --
/* Select product id, name and selling start date for all products
 that started selling after 01/01/2007 and had a black color.
 Use the CAST function to display the date only. Sort the returned
 data by the selling start date. */

SELECT
	ProductID,
	Name,
	CAST(SellStartDate as date)
FROM
	production.product
WHERE
	SellStartDate > '01/01/2007'
	AND Color = 'black'
ORDER BY
	SellStartDate;
	
-- Question 2-2 --
/* Retrieve the customer ID, account number, oldest order date
 and total number of orders for each customer.
 Use column aliases to make the report more presentable.
 Sort the returned data by the total number of orders in
 the descending order. */

SELECT
	CustomerID as "Customer ID",
	AccountNumber as "Account No.",
	COUNT(SalesOrderId) as "No.of order",
	MIN(OrderDate) as "Oldest Order Date"
FROM
	Sales.SalesOrderHeader
GROUP BY
	CustomerId,
	AccountNumber
ORDER BY
	"No.of order" DESC;

-- Question 2-3--
/* Write a query to select the product id, name, and list price
 for the product(s) that have the highest list price.*/

SELECT
	ProductId,
	Name,
	ListPrice
FROM
	production.product
WHERE
	ListPrice = (
		SELECT MAX(ListPrice)
	FROM
		production.product);
	
-- Question 2-4--
/* Write a query to retrieve the total quantity sold for each product.
 Include only products that have a total quantity sold greater than
 3000. Sort the results by the total quantity sold in the descending
 order. Include the product ID, product name, and total quantity
 sold columns in the report.*/

SELECT
	p.ProductId,
	Name,
	SUM(OrderQty) AS "Total order quantity"
FROM
	production.product p
JOIN Sales.SalesOrderDetail s ON
	p.ProductId = s.ProductId
GROUP BY
	p.ProductId,
	p.Name
HAVING
	SUM(OrderQty)>3000
ORDER BY
	"Total order quantity" DESC;

-- Question 2-5--
/* Write a SQL query to generate a list of customer ID's and
 account numbers that have never placed an order before.
 Sort the list by CustomerID in the ascending order. */

SELECT
	customerId,
	AccountNumber
FROM
	sales.customer
WHERE
	customerid NOT IN (
		SELECT customerid
	FROM
		sales.salesorderheader)
ORDER BY
	customerId;


-- Question 2-6--
/* Write a query to create a report containing customer id,
 first name, last name and email address for all customers.
 Sort the returned data by CustomerID. */

SELECT
	customerId,
	FirstName,
	Lastname,
	EmailAddress
FROM
	sales.customer s
JOIN person.person p on
	s.customerId = p.BusinessEntityid
JOIN person.emailaddress e ON
	s.customerId = e.businessentityid
ORDER BY
	customerId;
 