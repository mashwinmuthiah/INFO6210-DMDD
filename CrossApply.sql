USE murugappan_ashwin_test;

/* Use the function below and Person.Person to create a report.
   Include the SalespersonID, LastName, FirstName, SalesOrderID, OrderDate and TotalDue
   columns in the report. Don't modify the function.
   Sort he report by SalespersonID. */

-- Get a salesperson's orders

drop FUNCTION dbo.ufGetSalespersonOrders;

create function dbo.ufGetSalespersonOrders
(@spid int)
returns table
as return
select SalespersonID,CustomerID, SalesOrderID, OrderDate, TotalDue
from AdventureWorks2008R2.Sales.SalesOrderHeader
where SalespersonID=@spid;


SELECT DISTINCT
    sh.SalesPersonID, 
    pp.FirstName,
    pp.LastName,
    ufo.SalesOrderID,
    ufo.CustomerID,
    ufo.OrderDate,
    ufo.TotalDue
FROM AdventureWorks2008R2.Sales.SalesOrderHeader sh
INNER JOIN AdventureWorks2008R2.Sales.SalesPerson sp ON sh.SalesPersonID = sp.BusinessEntityID
INNER JOIN AdventureWorks2008R2.Person.Person pp ON sp.BusinessEntityID = pp.BusinessEntityID
CROSS APPLY dbo.ufGetSalespersonOrders(sh.SalesPersonID) ufo
ORDER BY sh.SalesPersonID;