
--Q1

create function ufSalesByMonthYear
(@month int, @year int)
returns money
As
Begin 
	Declare @sale money;
	select @sale = isnull( sum(TotalDue) , 0)
	   from sales.SalesOrderHeader
	   where month(orderDate) = @month AND year(OrderDate) = @year
	return @sale;
End
	
-- Test run
select dbo.ufSalesByMonthYear(5, 2007);

-- House keeping
drop function dbo.ufSalesByMonthYear;


-- Q2

CREATE TABLE DateRange
(DateID INT IDENTITY,
 DateValue DATE,
 Month INT,
 DayOfWeek INT);

create procedure dbo.uspFillDateRange
@startDate date,
@daysAfter int
AS BEGIN
	Declare @counter int = 0;
	declare @tempdate date;
	while (@counter < @daysAfter)
	Begin 
	    set @tempdate = DATEADD(dd, @counter, @startDate);
		Insert into dbo.DateRange (DateValue, month, DayOfWeek)
			values( @tempdate, month(@tempdate), DATEPART(dw, @tempdate));
			set @counter += 1;
	End
	Return;
End
Go

--Test run
exec dbo.uspFillDateRange '1-1-2018' , 7 ;

select * from dbo.DateRange;

-- Housekeeping

drop proc dbo.uspFillDateRange ;
drop TABLE dbo.DateRange;


--Q3

/* With three tables as defined below: */
CREATE TABLE Customer
(CustomerID VARCHAR(20) PRIMARY KEY,
 CustomerLName VARCHAR(30),
 CustomerFName VARCHAR(30),
 CustomerStatus VARCHAR(10));

CREATE TABLE SaleOrder
(OrderID INT IDENTITY PRIMARY KEY,
 CustomerID VARCHAR(20) REFERENCES Customer(CustomerID),
 OrderDate DATE,
 OrderAmountBeforeTax MONEY);

CREATE TABLE SaleOrderDetail
(OrderID INT REFERENCES SaleOrder(OrderID),
 ProductID INT,
 Quantity INT,
 UnitPrice INT,
 PRIMARY KEY (OrderID, ProductID));

Create trigger trUpdateCustomerStatus
on dbo.saleOrder
after INSERT, UPDATE, DELETE
As begin
	declare @total money = 0;
	declare @custid varchar(20);
	declare @status varchar(10);

	select @custid = isnull (i.CustomerID, d.CustomerID)
	   from inserted i full join deleted d 
	   on i.CustomerID = d.CustomerID;

	select @total = sum(OrderAmountBeforeTax)
	   from saleOrder
   	   where CustomerID = @custid;

	if @total > 5000
		set @status = 'preferred'
	else
		set @status = 'regular';

	update Customer
		set CustomerStatus = @status
		where CustomerID = @custid 
end

-- Test run
insert Customer values ('002','Mary','Rodman','Regular');
insert SaleOrder values ('002','2018-03-21',2000);
select * from Customer;

insert SaleOrder values ('002','2018-03-23',5000);
select * from Customer;

update SaleOrder set OrderAmountBeforeTax = 2500
       where CustomerID = '002' and OrderDate = '2018-03-23';
select * from Customer;

insert SaleOrder values ('002','2018-03-28',6000);
select * from Customer;

delete SaleOrder where CustomerID = '002' and OrderDate = '2018-03-28';
select * from Customer;

-- Housekeeping
drop table saleorderdetail;
drop table saleorder;
drop table customer;


--Q4

WITH orders AS
     (SELECT CustomerID, COUNT(SalesOrderID) AS TotalOrders
	  FROM Sales.SalesOrderHeader
	  GROUP BY CustomerID),
     products AS
     (SELECT soh.CustomerID, COUNT(DISTINCT sod.ProductID) AS UniqueProductsPurchased
      FROM Sales.SalesOrderHeader AS soh
      JOIN Sales.SalesOrderDetail AS sod 
	       ON soh.SalesOrderID = sod.SalesOrderID
      GROUP BY soh.CustomerID)
SELECT c.CustomerID, p.FirstName, p.LastName, orders.totalOrders, products.UniqueProductsPurchased
FROM Sales.Customer AS c
JOIN Person.Person p 
     ON c.PersonID =  p.BusinessEntityID
JOIN  orders
     ON orders.CustomerID = c.CustomerID
JOIN  products 
     ON products.CustomerID = c.CustomerID
ORDER BY c.CustomerID;

