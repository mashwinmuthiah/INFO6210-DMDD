----------------------------------------------------------------------------------------------------------------------- reports with a multi-valued column 
USE AdventureWorks2008R2;

SELECT distinct customerId,SalesPersonId from sales.SalesOrderHeader order by customerId desc ;

SELECT
	DISTINCT h.customerId,
	COALESCE(stuff((
		SELECT DISTINCT ', ' + RTRIM(cast(salesPersonID as char))
	FROM
		sales.SalesOrderHeader
	where
		customerId = h.customerId for xml PATH('')),1,2,''),'') as salespersonId
FROM
	sales.SalesOrderHeader h
join sales.SalesOrderHeader s on
	h.customerId = s.customerId
order by
	customerId desc;
	
-----------------------------------------

/* Write a query to retrieve the top five customers of each territory.
   Use the sum of TotalDue in SalesOrderHeader to determine the total purchase amounts.
   The top 5 customers have the five highest total purchase amounts. Your solution
   should retrieve a tie if there is any. The report should have the following format.
   Sort the report by TerritoryID.

TerritoryID	Top5Customers
	1		Harui Roger, Camacho Lindsey, Bready Richard, Ferrier Fran?ois, Vanderkamp Margaret
	2		DeGrasse Kirk, Lum Richard, Hirota Nancy, Duerr Bernard, Browning Dave
	3		Hendricks Valerie, Kirilov Anton, Kennedy Mitch, Abercrombie Kim, Huntsman Phyllis
	4		Vessa Robert, Cereghino Stacey, Dockter Blaine, Liu Kevin, Arthur John
	5		Dixon Andrew, Allen Phyllis, Cantoni Joseph, Hendergart James, Dennis Helen   
*/
	
WITH temp AS
   (SELECT DISTINCT
	    sh.TerritoryID, 
	    pp.FirstName,
	    pp.LastName,
	    SUM(sh.TotalDue) AS TotalSum,
	    RANK() OVER (PARTITION BY sh.TerritoryID ORDER BY SUM(sh.TotalDue) DESC ) AS OrderRank
	FROM Sales.SalesOrderHeader sh
	INNER JOIN Sales.Customer sc ON sh.CustomerID = sc.CustomerID
	INNER JOIN Person.Person pp ON sc.PersonID = pp.BusinessEntityID
	GROUP BY sh.TerritoryID, pp.FirstName, pp.LastName) 
	
SELECT DISTINCT 
	t2.TerritoryID, 
	STUFF(
		(SELECT  ', '+RTRIM(CAST(LastName as char)) +' '+ RTRIM(CAST(FirstName as char))   
		FROM temp t1 
		WHERE t1.TerritoryID = t2.TerritoryID 
		AND t1.OrderRank< 6
		FOR XML PATH('')) , 1, 2, '') AS listCustomers
FROM temp t2
ORDER BY TerritoryID;
-------------------------------------------
WITH Temp AS
(select SalesPersonID, CustomerID, 
rank() over (partition by SalesPersonID order by sum(TotalDue) desc)  as MostImporttantCustomers
from [Sales].[SalesOrderHeader]
where SalesPersonID is not null
group by SalesPersonID, CustomerID)

select distinct t2.SalesPersonID,
STUFF((SELECT  ', '+RTRIM(CAST(CustomerID as char))  
       FROM temp t1
       WHERE t1.SalesPersonID = t2.SalesPersonID
	         and t1.MostImporttantCustomers <=5
       FOR XML PATH('')) , 1, 2, '') AS TopCustomers
from temp t2;







