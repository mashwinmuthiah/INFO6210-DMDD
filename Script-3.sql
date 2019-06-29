use adventureworks2008R2

SELECT COUNT(CreditCardID) as [cards]  FROM Sales.SalesOrderHeader;

SELECT CustomerID, AccountNumber, COUNT(SalesOrderID) AS '# of Orders'
FROM AdventureWorks2008R2.Sales.SalesOrderHeader
GROUP BY CustomerID, AccountNumber
ORDER BY '# of Orders' DESC;

-- Exercise 1
/* Retrieve only the following columns from the
 Production.Product table:
Product ID
Name
Selling start date
Selling end date
Size
Weight */

SELECT ProductID,Name,sellstartdate,sellenddate,Size,weight from production.product

-- Exercise 2
/* Select all info for all orders with no credit card id. */

select * from sales.salesorderheader where CreditCardId is null;

-- Exercise 3
/* Select all info for all products with size specified. */
select * from production.product where size is not null;

-- Exercise 4
/* Select all information for products that started selling
 between January 1, 2007 and December 31, 2007. */

select * from production.product where sellstartdate between '1/1/2007' and '12/31/2007'
-- Exercise 5
/* Select all info for all orders placed in June 2007 using date
 functions, and include a column for an estimated delivery date
 that is 7 days after the order date. */

-- Exercise 6
/* Determine the date that is 30 days from today and display only
 the date in mm/dd/yyyy format (4-digit year). */
-- Exercise 7
/* Determine the number of orders, overall total due,
 average of total due, amount of the smallest amount due, and
 amount of the largest amount due for all orders placed in May
 2008. Make sure all columns have a descriptive heading. */
-- Exercise 8
/* Retrieve the Customer ID, total number of orders and overall total
 due for the customers who placed more than one order in 2007
 and sort the result by the overall total due in the descending
 order. */
-- Exercise 9
/*
 Provide a unique list of the sales person ids who have sold
 the product id 777. Sort the list by the sales person id. */
-- Exercise 10
/* List the product ID, name, list price, size of products
 Under the ‘Bikes’ category (ProductCategoryID = 1) and
 Subcategory ‘Mountain Bikes’. */
-- Exercise 11
/* List the SalesOrderID and currency name for each order. */