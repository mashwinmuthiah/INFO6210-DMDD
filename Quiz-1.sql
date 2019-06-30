USE AdventureWorks2008R2

/* Using the content of AdventureWorks2008R2,
 please retrieve a unique list of the customer id of
 the customers who have purchased both Product 710
 and Product 715, but have never purchased Product 716.
 Sort the returned data by the customer id.
*/

(
	SELECT DISTINCT CustomerID
FROM
	sales.salesOrderHeader h
JOIN sales.salesorderdetail d on
	h.SalesOrderID = d.SalesOrderID
where
	d.ProductID = 710
UNION
SELECT
	DISTINCT CustomerID
FROM
	sales.salesOrderHeader h
JOIN sales.salesorderdetail d on
	h.SalesOrderID = d.SalesOrderID
where
	d.ProductID = 715)
EXCEPT SELECT
DISTINCT CustomerID
FROM
sales.salesOrderHeader h
JOIN sales.salesorderdetail d on
h.SalesOrderID = d.SalesOrderID
where
d.ProductID = 716
ORDER by
CustomerId;

/* Using the content of AdventureWorks2008R2, write a query to
 retrieve the customers who have purchased only Product 921
 for all orders and not any other product.
 Sort the returned data by the customer id. */

SELECT
	customerID
from
	sales.SalesOrderHeader h
JOIN sales.SalesOrderDetail d on
	h.SalesOrderID = d.SalesOrderID
WHERE
	d.ProductID = 921
EXCEPT SELECT
	customerID
from
	sales.SalesOrderHeader h
JOIN sales.SalesOrderDetail d on
	h.SalesOrderID = d.SalesOrderID
WHERE
	d.ProductID NOT IN (921)
ORDER by
	customerID;


-- Question 5 (3 points)
/* Using the content of AdventureWorks2008R2,
 write a query to retrieve the salesperson id who had
 the largest total-quantity-sold decrease from
 March 2007 to April 2007.
*/
with temp as (
	select SalesPersonID,
	RANK() OVER(
	order by sum(OrderQty)) [Ranks]
from
	sales.SalesOrderHeader h
join sales.SalesOrderDetail d on
	h.SalesOrderID = d.SalesOrderID
WHERE
	OrderDate NOT BETWEEN '03/01/2007' and '04/01/2007'
GROUP by
	SalesPersonID ) SELECT
	SalesPersonID
from
	temp
where
	Ranks = 1;

