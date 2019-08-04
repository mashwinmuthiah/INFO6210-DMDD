

---------------------------------------------------------------------------------------------------------------------- Functions

USE Murugappan_ashwin_test;

CREATE FUNCTION totalsales
(@y int,@m int)
RETURNS money
AS
BEGIN
	DECLARE @totalsale money;
	SELECT @totalsale = isnull(sum(TotalDue),0) from AdventureWorks2008R2.sales.SalesOrderHeader
	WHERE month(orderDate) = @m AND year(OrderDate) = @y
	RETURN @totalsale;
END

select dbo.totalsales(2007,5);

DROP FUNCTION totalsales;

-------------------------------
DROP SCHEMA quiz2;
CREATE SCHEMA quiz2;

DROP TABLE quiz2.Department;
CREATE TABLE quiz2.Department
 (DepartmentID INT PRIMARY KEY,
  Name VARCHAR(50));
 
DROP TABLE quiz2.Employee;
CREATE TABLE quiz2.Employee
(EmployeeID INT PRIMARY KEY,
 LastName VARCHAR(50),
 FirsName VARCHAR(50),
 Salary DECIMAL(10,2),
 DepartmentID INT REFERENCES Department(DepartmentID),
 TerminateDate DATE);

DROP TABLE quiz2.Project;
CREATE TABLE quiz2.Project
(ProjectID INT PRIMARY KEY,
 Name VARCHAR(50));

DROP TABLE quiz2.Assignment;
CREATE TABLE quiz2.Assignment
(EmployeeID INT REFERENCES quiz2.Employee(EmployeeID),
 ProjectID INT REFERENCES quiz2.Project(ProjectID),
 StartDate DATE,
 EndDate DATE
 PRIMARY KEY (EmployeeID, ProjectID, StartDate));

DROP TABLE quiz2.SalaryAudit;
CREATE TABLE quiz2.SalaryAudit
(LogID INT IDENTITY,
 EmployeeID INT,
 OldSalary DECIMAL(10,2),
 NewSalary DECIMAL(10,2),
 ChangedBy VARCHAR(50) DEFAULT original_login(),
 ChangeTime DATETIME DEFAULT GETDATE());

/* There is a business rule that the company can not have have more than 10 active projects at the same time 
   and an active project team average size can not be greater than 50 empoyees. 
   An active project is a project which has at least one employee working on it. 
   Write a SINGLE table-level constraint to implement the rule. */

DROP FUNCTION quiz2.checkProject;
CREATE FUNCTION quiz2.checkProject(@pid int)
returns SMALLINT
AS
BEGIN
	DECLARE @checkresults SMALLINT = 0;
	DECLARE @countproject SMALLINT = 0;
	DECLARE @countEmployee SMALLINT = 0;
	SELECT @countproject = COUNT(DISTINCT projectId) from quiz2.Project;
	SELECT @countEmployee = COUNT(a.employeeId) from quiz2.Assignment a join quiz2.project p on a.projectid = p.projectId where p.projectId = @pid;
	if @countproject >10 
		SET @checkresults = 1;
	if @countEmployee >50 or @countEmployee <1
		SET @checkresults = 1;
RETURN @checkresults;
END

ALTER TABLE  quiz2.project ADD CONSTRAINT validproject CHECK (quiz2.checkProject(projectId) = 0) ;

------------------------------------------------------------------------------------------------------------------------------------------------------------ Triggers
/* There is a business rule a salary adjustment cannot be greater than 10%.
   Also, any allowed adjustment must be logged in the SalaryAudit table.
   Please write a trigger to implement the rule. 
   Assume only one update takes place at a time. */


CREATE TRIGGER quiz2.updatesalary
on quiz2.Employee
after UPDATE
as BEGIN
	declare @diff float;
	SELECT @diff = (i.Salary - d.salary)/d.salary from INSERTED i join DELETED d on i.EmployeeID = d.EmployeeID;
	IF @diff<=0.10
		INSERT INTO quiz2.SalaryAudit(EmployeeID, OldSalary, NewSalary, ChangedBy)
		SELECT i.EmployeeID,i.salary,d.salary,(i.Salary - d.salary)/d.salary
		from INSERTED i join DELETED d on i.EmployeeID = d.EmployeeID;
	ELSE
		BEGIN
			ROLLBACK TRAN;
			RAISERROR('salary Increased more than 10%',16,1);
		END;
END;


CREATE SCHEMA prep;

CREATE TABLE prep.Customer
(CustomerID VARCHAR(20) PRIMARY KEY,
CustomerLName VARCHAR(30),
CustomerFName VARCHAR(30),
CustomerStatus VARCHAR(10));

CREATE TABLE prep.SaleOrder
(OrderID INT IDENTITY PRIMARY KEY,
CustomerID VARCHAR(20) REFERENCES prep.Customer(CustomerID),
OrderDate DATE,
OrderAmountBeforeTax INT);

CREATE TABLE prep.SaleOrderDetail
(OrderID INT REFERENCES prep.SaleOrder(OrderID),
ProductID INT,
Quantity INT,
UnitPrice INT,
PRIMARY KEY (OrderID, ProductID));

/* Write a trigger to update the CustomerStatus column of Customer
 based on the total of OrderAmountBeforeTax for all orders
 placed by the customer. If the total exceeds 5,000, put Preferred
 in the CustomerStatus column. */

CREATE TRIGGER prep.toupdatecustomerstatus
on prep.SaleOrder
after INSERT,UPDATE,DELETE
as BEGIN
	DECLARE @total money = 0;
	DECLARE @cusid varchar(20);
	DECLARE @status varchar(10);

	SELECT @cusid = isnull(i.customerID,d.customerId) from INSERTED i full join DELETED d on i.customerid = d.customerid;
	SELECT @total = sum(OrderAmountBeforeTax) from prep.SaleOrder where customerId = @cusid;
	IF @total > 5000
		set @status = 'perferred'
	ELSE
		set @status = 'regular'
	UPDATE prep.customer set customerstatus = @status where customerId = @cusid;
END

insert prep.Customer values ('002','Mary','Rodman','Regular');
insert prep.SaleOrder values ('002','2018-03-21',2000);
select * from prep.Customer;

insert prep.SaleOrder values ('002','2018-03-23',5000);
select * from prep.Customer;

update prep.SaleOrder set OrderAmountBeforeTax = 2500
       where CustomerID = '002' and OrderDate = '2018-03-23';
select * from prep.Customer;

insert prep.SaleOrder values ('002','2018-03-28',6000);
select * from prep.Customer;

delete prep.SaleOrder where CustomerID = '002' and OrderDate = '2018-03-28';
select * from prep.Customer;

drop table prep.saleorderdetail;
drop table prep.saleorder;
drop table prep.customer;
