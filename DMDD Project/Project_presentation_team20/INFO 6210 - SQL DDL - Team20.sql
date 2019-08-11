/* This file is used to populate our(team20) project data. We are using MURUGAPPAN_ASHWIN_TEST database. It contains:
 * 1. creation of all tables via INSERT(most tables), STORE PROCEDURE(Users table) and Data Import Wizard(few tables - Accounts, Permissions,SamlAuthenticationConfig,SamlAuthenticationConfigAccountsMapping)
 * 2. DATA ENCRYPTION - EncryptedPassword column in Users
 * 3. check constraints on some tables
 * 4. three views
 */

USE MURUGAPPAN_ASHWIN_TEST;

------------------------------------------------------------------------------------------------------------------------------------------- Dropping All Tables
DROP TABLE dbo.Accounts;
DROP TABLE dbo.Permissions;
DROP TABLE dbo.SamlAuthenticationConfig;
DROP TABLE dbo.SamlAuthenticationConfigAccountsMapping;
DROP TABLE dbo.UserRoleMapping;
DROP TABLE dbo.UserUserGroupMapping;
DROP TABLE dbo.AccountsRoleMapping;
DROP TABLE dbo.UserAccountsMapping;
DROP TABLE dbo.UserGroupAccountMapping;
DROP TABLE dbo.Accounts;
DROP TABLE dbo.Department;
DROP TABLE dbo.Team;
DROP TABLE dbo.Users;
DROP TABLE dbo.Roles;
DROP TABLE dbo.UserGroup;
------------------------------------------------------------------------------------------------------------------------------------------- Table Accounts
CREATE TABLE dbo.Accounts
 (
 AccountId INT NOT NULL IDENTITY UNIQUE,
 UserId INT NOT NULL REFERENCES dbo.Users(UserId),
 RoleId INT NOT NULL REFERENCES dbo.Roles(RoleId),
 UserGroupId INT NOT NULL REFERENCES dbo.UserGroup(UserGroupId),
 Version DECIMAL,
 AdminId INT,
 SubscriptionStartDate DATE,
 SubscriptionEndDate DATE,
 Description VARCHAR(100),
 CreatedOn DATE,
 CreatedById INT,
 ModifiedOn DATE,
 ModifiedById INT,
 Active BIT NOT NULL,
 CONSTRAINT PKACCOUNT PRIMARY KEY CLUSTERED (AccountId,UserId,RoleId,UserGroupId)
 );  
 
------------------------------------------------------------------------------------------------------------------------------------------- Table Permissions
CREATE TABLE dbo.Permissions
 (
 PermissionId INT NOT NULL IDENTITY UNIQUE,
 AccountId INT NOT NULL,
 PermissionType VARCHAR(50) NOT NULL,
 Description VARCHAR(100),
 Active BIT NOT NULL,
 FOREIGN KEY (AccountId) REFERENCES dbo.Accounts(AccountId)
 ); 
 
------------------------------------------------------------------------------------------------------------------------------------------- Table SamlAuthenticationConfig
CREATE TABLE dbo.SamlAuthenticationConfig
 (
 SamlAuthenticationConfigId INT NOT NULL IDENTITY UNIQUE,
 Version INT,
 LoginUrl VARCHAR(50),
 LogoutUrl VARCHAR(50),
 Certifiation Varchar(50),
 UserNameAttributes Varchar(50),
 EmailAddressAttributes Varchar(50)
 );

------------------------------------------------------------------------------------------------------------------------------------------- Table SamlAuthenticationConfigAccountsMapping
CREATE TABLE dbo.SamlAuthenticationConfigAccountsMapping
 (
 SamlAuthenticationConfigId INT NOT NULL REFERENCES dbo.SamlAuthenticationConfig(SamlAuthenticationConfigId),
 AccountId INT NOT NULL REFERENCES dbo.Accounts(AccountId),
 CONSTRAINT PKSamlAuthenticationConfigAccountsMapping PRIMARY KEY CLUSTERED  (SamlAuthenticationConfigId, AccountId)
 );

------------------------------------------------------------------------------------------------------------------------------------------- Table Department

CREATE TABLE dbo.Department (
	DepartmentId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	DepartmentName VARCHAR(30) NOT NULL,
	DepartmentHeadId INT NOT NULL ,
	Description VARCHAR(255)
);

EXEC MURUGAPPAN_ASHWIN_TEST.sys.sp_addextendedproperty 'MS_Description', 'Contains The details of the Major departments available in the Company.', 'schema', 'dbo', 'table', 'Department' ;

------------------------------------------------------------------------------------------------------------------------------------------- Table Team

CREATE TABLE dbo.Team(
	TeamId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	DepartmentId INT NOT NULL REFERENCES dbo.Department(DepartmentId),
	TeamName VARCHAR(30),
	TeamManagerId INT NOT NULL,
	TeamLeadId INT NOT NULL,
	Description VARCHAR(255)
);

------------------------------------------------------------------------------------------------------------------------------------------- Table Users

CREATE TABLE dbo.Users (
	UserId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	TeamId INT NOT NULL,
	FOREIGN KEY (TeamId) REFERENCES dbo.Team(TeamId),
	FName VARCHAR(30) NOT NULL,
	LName VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	DeskPhone INT NOT NULL,
	PersonalPhone INT,
	DateOfBirth DATE,
	EncryptedPassword VARCHAR(225) NOT NULL,
	Gender VARCHAR(30),
	CreatedById INT,
	CreatedOn Date,
	ModifiedOn Date,
	ModifiesById INT,
	Active BIT NOT NULL
);
ALTER TABLE dbo.Users ADD CONSTRAINT check_age CHECK (datediff(yy,CONVERT(datetime,DateOfBirth),GETDATE()) < 100);      
ALTER TABLE dbo.Users ADD CONSTRAINT check_gender CHECK (Gender IN ('M','F','O'));
ALTER TABLE dbo.Users ADD CONSTRAINT check_createdate_users CHECK (datediff(dy,CONVERT(datetime,CreatedOn),GETDATE()) >= 0);  

------------------------------------------------------------------------------------------------------------------------------------------- Table Roles

CREATE TABLE dbo.Roles(
	RoleId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(30) NOT NULL,
	DisplayName VARCHAR(30) NOT NULL,
	CreatedById INT,
	CreatedOn DATE,
	Description VARCHAR(255)	
);
ALTER TABLE dbo.Roles ADD CONSTRAINT check_createdate_roles CHECK (datediff(dy,CONVERT(datetime,CreatedOn),GETDATE()) >= 0);  

------------------------------------------------------------------------------------------------------------------------------------------- Table UserGroup

CREATE TABLE dbo.UserGroup(
	 UserGroupId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	 Name VARCHAR(30) NOT NULL,
	 AdminId INT NOT NULL,
	 UserGroupType VARCHAR(30),
	 UserGroupEmail VARCHAR(30),
	 CreatedById INT,
	 CreatedOn Date,
	 ModifiedOn Date,
	 ModifiesById INT,
	 Description VARCHAR(255),
	 Active BIT NOT NULL
);
ALTER TABLE dbo.UserGroup ADD CONSTRAINT check_createdate_UserGroup CHECK (datediff(dy,CONVERT(datetime,CreatedOn),GETDATE()) >= 0);  

------------------------------------------------------------------------------------------------------------------------------------------- Table UserRoleMapping

CREATE TABLE dbo.UserRoleMapping(
	UserId INT NOT NULL REFERENCES dbo.Users(UserId),
	RoleID INT NOT NULL REFERENCES dbo.Roles(RoleId),
	AssignedOn Date,
	AssignedById INT,
	Active BIT NOT NULL
	CONSTRAINT PKUserRoleMapping PRIMARY KEY CLUSTERED (UserId,RoleID)
);
ALTER TABLE dbo.UserRoleMapping ADD CONSTRAINT check_createdate_UserRoleMapping CHECK (datediff(dy,CONVERT(datetime,AssignedOn),GETDATE()) >= 0);
ALTER TABLE dbo.UserRoleMapping ADD CONSTRAINT check_user_role_mapping_pk CHECK (dbo.UserRoleMappingCheck(UserId,RoleID) = 1); 

------------------------------------------------------------------------------------------------------------------------------------------- Table UserUserGroupMapping 

CREATE TABLE dbo.UserUserGroupMapping(
	UserId INT NOT NULL REFERENCES dbo.Users(UserId),
	UserGroupId INT NOT NULL REFERENCES dbo.UserGroup(UserGroupId),
	CreatedOn Date,
	CreatedById INT,
	ValidTill Date,
	Active BIT NOT NULL
	CONSTRAINT PKUserUserGroupMapping PRIMARY KEY CLUSTERED (UserId,UserGroupId)
);
ALTER TABLE dbo.UserUserGroupMapping ADD CONSTRAINT check_createdate_UserUserGroupMapping CHECK (datediff(dy,CONVERT(datetime,CreatedOn),GETDATE()) >= 0);  


------------------------------------------------------------------------------------------------------------------------------------------- Table Accounts

CREATE TABLE dbo.Accounts
 (
 AccountId INT NOT NULL IDENTITY UNIQUE,
 UserId INT NOT NULL, --REFERENCES dbo.Users(UserId),
 RoleId INT NOT NULL, --REFERENCES dbo.Roles(RoleId),
 UserGroupId INT NOT NULL, --REFERENCES dbo.UserGroup(UserGroupId),
 Version DECIMAL,
 AdminId INT,
 SubscriptionStartDate DATE,
 SubscriptionEndDate DATE,
 Description VARCHAR(100),
 CreatedOn DATE,
 CreatedById INT,
 ModifiedOn DATE,
 ModifiedById INT,
 Active BIT NOT NULL,
 CONSTRAINT PKACCOUNT PRIMARY KEY CLUSTERED (AccountId,UserId,RoleId,UserGroupId)
 );
------------------------------------------------------------------------------------------------------------------------------------------- Table AccountsRoleMapping 

CREATE TABLE dbo.AccountsRoleMapping(
	AccountId INT NOT NULL REFERENCES dbo.Accounts(AccountId),
	RoleID INT NOT NULL REFERENCES dbo.Roles(RoleId),
	CreatedOn Date,
	CreatedById INT,
	CONSTRAINT PKAccountsRoleMapping PRIMARY KEY CLUSTERED (AccountId,RoleID)
);
ALTER TABLE dbo.AccountsRoleMapping ADD CONSTRAINT check_createdate_AccountsRoleMapping CHECK (datediff(dy,CONVERT(datetime,CreatedOn),GETDATE()) >= 0);  

------------------------------------------------------------------------------------------------------------------------------------------- Table UserAccountsMapping

CREATE TABLE dbo.UserAccountsMapping(
	UserId INT NOT NULL REFERENCES dbo.Users(UserId),
	AccountId INT NOT NULL REFERENCES dbo.Accounts(AccountId),
	CreatedOn Date,
	CreatedById INT,
	LastLogin Date,
	LastLogout Date,
	ValidTill Date,
	CONSTRAINT PKUserAccountsMapping PRIMARY KEY CLUSTERED (AccountId,UserId)
);
ALTER TABLE dbo.UserAccountsMapping ADD CONSTRAINT check_createdate_UserAccountsMapping CHECK (datediff(dy,CONVERT(datetime,CreatedOn),GETDATE()) >= 0);  

------------------------------------------------------------------------------------------------------------------------------------------- Table UserGroupAccountMapping

CREATE TABLE dbo.UserGroupAccountMapping(
	AccountId INT NOT NULL REFERENCES dbo.Accounts(AccountId),
	UserGroupId INT NOT NULL REFERENCES dbo.UserGroup(UserGroupId),
	AssignedOn Date,
	AssignedById INT,
	CONSTRAINT PKUserGroupAccountMapping PRIMARY KEY CLUSTERED (AccountId,UserGroupId)
);
ALTER TABLE dbo.UserGroupAccountMapping ADD CONSTRAINT check_createdate_UserGroupAccountMapping CHECK (datediff(dy,CONVERT(datetime,AssignedOn),GETDATE()) >= 0);  

--------------------------------------------------------------------- Function to check if we can enter a record in UserRoleMapping
DROP FUNCTION dbo.UserRoleMappingCheck;

CREATE FUNCTION UserRoleMappingCheck(@UserId INT, @RoleId INT)
RETURNS BIT 
AS
BEGIN
	DECLARE @UserCount smallint = 0
	SELECT @UserCount = COUNT(1)
	FROM dbo.Users
	WHERE UserId = @UserId;

	DECLARE @RoleCount smallint = 0
	SELECT @RoleCount = COUNT(1)
	FROM dbo.Roles
	WHERE RoleId = @RoleId;

	RETURN 
	(
		CASE WHEN @UserCount > 0 AND @RoleCount > 0 THEN
			1 
		ELSE 
			0
		END
	)	
	
END;
----------------------------------------------------------------------------------------------Encrypted Password - Insert Data Using Procedure only

DROP PROCEDURE dbo.AddUsers;
CREATE PROCEDURE dbo.AddUsers
	@pTeamId INT,
	@pFName VARCHAR(30),
	@pLName VARCHAR(30),
	@pEmail VARCHAR(50) ,
	@pDeskPhone INT,
	@pPersonalPhone INT,
	@pDateOfBirth DATE,
	@pEncryptedPassword VARCHAR(225), 
	@pGender VARCHAR(30),
	@pCreatedById INT,
	@pCreatedOn Date,
	@pModifiedOn Date,
	@pModifiesById INT,
	@pActive BIT 
AS
BEGIN
	
	SET NOCOUNT ON
	INSERT INTO dbo.Users(TeamId,FName,LName ,Email ,DeskPhone,PersonalPhone,DateOfBirth ,EncryptedPassword ,Gender,CreatedById ,CreatedOn ,ModifiedOn ,ModifiesById ,Active ) 
	VALUES (@pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,HASHBYTES('SHA2_512', @pEncryptedPassword) ,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive)
END
-------------------------------------------------------------------------------------------------------------------------------------------------------------- Inserting Data Table Department
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('Finance',10,'This is the Finance team');
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('Marketing',9,'This is the Marketing team');
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('OnlinePayments',8,'This is the OnlinePayments team');
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('SupplyChain',7,'This is the SupplyChain team');
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('DataInsignt',6,'This is the DataInsignt team');
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('Production',5,'This is the Production team');
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('Sales',4,'This is the Sales team');
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('MachineLearning',3,'This is the MachineLearning team');
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('R&D',2,'This is the Research and development team');
INSERT INTO dbo.Department (DepartmentName,DepartmentHeadId,Description) VALUES ('HR',1,'This is the Human resources team');
-------------------------------------------------------------------------------------------------------------------------------------------------------------- Inserting Data Table Teams
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (1,'FinanceAsia',20,20,'This is Finance Asia team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (1,'FinanceNorthAmerica',19,19,'This is Finance North America team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (2,'MarketingAsia',18,18,'This is Marketing Asia team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (2,'MarketingNorthAmerica',17,17,'This is Marketing North America team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (3,'OnlinePayments',16,16,'This is OnlinePayments team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (4,'SupplyChain',15,15,'This is SupplyChain team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (5,'DataInsigntAsia',14,14,'This is DataInsignt Asia team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (5,'DataInsigntNorthAmerica',13,13,'This is DataInsignt North America team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (6,'ProductionAsia',12,12,'This is Production Asia team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (6,'ProductionNorthAmerica',11,11,'This is Production North America team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (7,'Sales',10,10,'This is Sales team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (8,'MachineLearning',9,9,'This is MachineLearning team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (9,'development',8,8,'This is development team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (10,'HumanresourcesAsia',7,7,'This is Human resources Asia team');
INSERT INTO dbo.Team (DepartmentId,TeamName,TeamManagerId,TeamLeadId,Description) VALUES (10,'HumanresourcesNorthAmerica',6,6,'This is Human resources North America team');

-------------------------------------------------------------------------------------------------------------------------------------------------------------- Inserting Data Table Users

DECLARE @pTeamId INT;SET @pTeamId = 1;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'ashwin';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Muthiah';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'ashwin@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234567898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1234;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'11/05/1996');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'mypassword';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 2;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Mahesh';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Naga';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'Mahesh@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234567899;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1235;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'10/05/1995');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'yourpass';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/24/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/24/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;
--------------------
DECLARE @pTeamId INT;SET @pTeamId = 3;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'vijaya';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Lakshmi';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'vj@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234565898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1236;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'05/06/1993');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'obama';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='F';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/23/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/23/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 4;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'obama';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'brack';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'ob@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234457898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1237;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'08/25/1997');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'duckky';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/26/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/26/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 1;
DECLARE	@pFName VARCHAR(30);SET	@pFName = ' Robert';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  ' Downey Jr.';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'robert@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234364898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1238;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'07/15/1989');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'imironman';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 5;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Scarlett';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Johansson';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'Johansson@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234123498;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1239;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'03/19/1990');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'jonny';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='F';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 2;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/01/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/01/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 1;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Mark';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Ruffalo';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'Ruffalo@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1233267898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1240;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'02/09/1985');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'mypassword';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 6;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'sherlock';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Homes';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'homes@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1239567898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1241;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'10/25/1987');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'madman';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 7;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Eddard';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Stark';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'StarkE@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1984567898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1242;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'04/01/1983');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'winteriscomming';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 8;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Catelyn';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Stark';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'StarkC@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234567798;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1243;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'04/01/1985');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'dontgosouth';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 9;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Cersei';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Lannister';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'LannisterC@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234567889;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1244;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'07/11/1990');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'money';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='F';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 2;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 10;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Sansa';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Stark';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'StarkS@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234567888;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1245;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'11/05/1996');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'littlefinger';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='F';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 2;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 11;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Arya';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Stark';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'StarkA@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234467898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1246;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'06/03/1996');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'nottoday';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='F';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 2;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 12;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Khal';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Drogo';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'DrogoK@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234568987;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1247;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'05/29/1987');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'bloodrider';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 13;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Ygritte';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'snow';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'Ygritte@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1134567898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1234;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'10/15/1991');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'uknownnothing';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='F';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 14;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Jeor';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Mormont';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'Mormont@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1324567898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1248;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'09/25/1983');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'iloveyou';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 15;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Brienne';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Tarth';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'BT@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1236647898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1249;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'08/08/1991');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'protectsansa';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='F';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 2;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 11;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Robert';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Baratheon';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'BaratheonR@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234515998;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1250;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'02/05/1987');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'notafather';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 1;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 1;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 4;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Bran';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Stark';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'StarkB@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1964367898;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1251;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'11/14/1999');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'goodman';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 2;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

---------------
DECLARE @pTeamId INT;SET @pTeamId = 5;
DECLARE	@pFName VARCHAR(30);SET	@pFName = 'Davos';
DECLARE	@pLName VARCHAR(30);SET	@pLName =  'Seaworth';
DECLARE	@pEmail VARCHAR(50) ;SET	@pEmail = 'SeaworthD@gmail.com';
DECLARE	@pDeskPhone INT;SET	@pDeskPhone = 1234565498;
DECLARE	@pPersonalPhone INT;SET	@pPersonalPhone = 1252;
DECLARE	@pDateOfBirth DATE;SET	@pDateOfBirth = CONVERT(datetime,'07/22/1983');
DECLARE	@pEncryptedPassword VARCHAR(225);SET	@pEncryptedPassword = 'heiskinginthenorth';
DECLARE	@pGender VARCHAR(30);SET	@pGender ='M';
DECLARE	@pCreatedById INT;SET	@pCreatedById = 2;
DECLARE	@pCreatedOn Date;SET	@pCreatedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiedOn Date;SET	@pModifiedOn = CONVERT(datetime,'07/25/2019');
DECLARE	@pModifiesById INT;SET	@pModifiesById = 2;
DECLARE	@pActive BIT ;SET	@pActive = 1;
EXEC dbo.AddUsers @pTeamId,@pFName,@pLName ,@pEmail ,@pDeskPhone,@pPersonalPhone,@pDateOfBirth ,@pEncryptedPassword,@pGender,@pCreatedById ,@pCreatedOn ,@pModifiedOn ,@pModifiesById ,@pActive;

-------------------------------------------------------------------------------------------------------------------------------------------------------------- Inserting Data Table Roles

INSERT INTO dbo.Roles(Name,DisplayName,CreatedById,CreatedOn,Description) VALUES ('SoftwareEngineer','SF',3,GETDATE(),'This is a Software Engineer Role');
INSERT INTO dbo.Roles(Name,DisplayName,CreatedById,CreatedOn,Description) VALUES ('DataAnalyst','DA',3,GETDATE(),'This is a Data Analyst Role');
INSERT INTO dbo.Roles(Name,DisplayName,CreatedById,CreatedOn,Description) VALUES ('Accountant','AT',3,GETDATE(),'This is a Accountant Role');
INSERT INTO dbo.Roles(Name,DisplayName,CreatedById,CreatedOn,Description) VALUES ('BusinessIntelligence','BI',3,GETDATE(),'This is a Business Intelligence Role');
INSERT INTO dbo.Roles(Name,DisplayName,CreatedById,CreatedOn,Description) VALUES ('SupplyChainEngineer','SC',3,GETDATE(),'This is a Supply Chain Engineer Role');
INSERT INTO dbo.Roles(Name,DisplayName,CreatedById,CreatedOn,Description) VALUES ('SalesPerson','SP',3,GETDATE(),'This is a Sales Person Role');
INSERT INTO dbo.Roles(Name,DisplayName,CreatedById,CreatedOn,Description) VALUES ('HumanResources','HR',3,GETDATE(),'This is a Human Resources Role');
INSERT INTO dbo.Roles(Name,DisplayName,CreatedById,CreatedOn,Description) VALUES ('OnlinePayments','OP',3,GETDATE(),'This is a Online Payments manager Role');

-------------------------------------------------------------------------------------------------------------------------------------------------------------- Inserting Data Table UserRoleMapping 

INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES (1,8,GETDATE(),1,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(2,7,GETDATE(),19,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(3,6,GETDATE(),18,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(4,5,GETDATE(),17,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(5,4,GETDATE(),16,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(6,3,GETDATE(),15,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(7,2,GETDATE(),14,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(8,1,GETDATE(),13,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(9,8,GETDATE(),12,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(10,7,GETDATE(),2,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(11,6,GETDATE(),2,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(12,5,GETDATE(),2,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(13,4,GETDATE(),2,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(14,3,GETDATE(),2,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(15,2,GETDATE(),2,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(16,1,GETDATE(),3,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(17,8,GETDATE(),3,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(18,7,GETDATE(),3,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(19,6,GETDATE(),3,1);
INSERT INTO dbo.UserRoleMapping(UserId,RoleID,AssignedOn,AssignedById,Active) VALUES(20,5,GETDATE(),3,1);

-------------------------------------------------------------------------------------------------------------------------------------------------------------- Inserting Data Table UserGroup
INSERT INTO dbo.UserGroup (Name,AdminId,UserGroupType,UserGroupEmail,CreatedById,CreatedOn,ModifiedOn,ModifiesById,Description,Active)
VALUES ('AWS',3,'S','aws@gmail.com',3,GETDATE(),GETDATE(),3,'AWS group',1);
INSERT INTO dbo.UserGroup (Name,AdminId,UserGroupType,UserGroupEmail,CreatedById,CreatedOn,ModifiedOn,ModifiesById,Description,Active)
VALUES ('Azure',3,'S','Azure@gmail.com',3,GETDATE(),GETDATE(),3,'Azure group',1);
INSERT INTO dbo.UserGroup (Name,AdminId,UserGroupType,UserGroupEmail,CreatedById,CreatedOn,ModifiedOn,ModifiesById,Description,Active)
VALUES ('Tableau',3,'D','Tableau@gmail.com',3,GETDATE(),GETDATE(),3,'Tableau group',1);
INSERT INTO dbo.UserGroup (Name,AdminId,UserGroupType,UserGroupEmail,CreatedById,CreatedOn,ModifiedOn,ModifiesById,Description,Active)
VALUES ('SysAdmin',3,'D','SysAdmin@gmail.com',3,GETDATE(),GETDATE(),3,'SysAdmin group',1);

---------------------------------------------------------------------------------------------------------------------------------------------------------Inserting Data Table UserUserGroupMapping
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (1,4,GETDATE(),4,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (2,4,GETDATE(),4,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (3,4,GETDATE(),4,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (4,4,GETDATE(),4,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (5,4,GETDATE(),3,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (6,4,GETDATE(),3,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (7,4,GETDATE(),3,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (8,4,GETDATE(),3,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (9,4,GETDATE(),3,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (10,4,GETDATE(),2,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (11,4,GETDATE(),2,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (12,4,GETDATE(),2,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (13,4,GETDATE(),2,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (14,4,GETDATE(),2,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (15,4,GETDATE(),2,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (16,4,GETDATE(),2,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (17,4,GETDATE(),1,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (18,4,GETDATE(),1,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (19,4,GETDATE(),1,DATEADD(YEAR,1,GETDATE()),1);
INSERT INTO dbo.UserUserGroupMapping(UserId,UserGroupId,CreatedOn,CreatedById,ValidTill,Active) VALUES (20,4,GETDATE(),1,DATEADD(YEAR,1,GETDATE()),1);

----------------------------------------------------------------------------------------------------------------------------------------Inserting Data Table AccountsRoleMapping **

INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (1,8,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (2,7,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (3,6,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (4,5,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (5,4,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (6,3,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (7,2,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (8,1,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (9,8,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (10,7,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (11,6,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (12,5,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (13,4,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (14,3,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (15,2,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (16,1,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (17,8,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (18,7,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (19,6,GETDATE(),3);
INSERT INTO dbo.AccountsRoleMapping(AccountId,RoleID,CreatedOn,CreatedById) VALUES (20,5,GETDATE(),3);


------------------------------------------------------------------------------------------------------------------------------------Inserting Data Table UserAccountsMapping **

INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (1,1,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (2,2,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (3,3,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (4,4,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (5,5,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (6,6,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (7,7,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (8,8,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (9,9,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (10,10,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (11,11,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (12,12,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (13,13,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (14,14,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (15,15,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (16,16,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (17,17,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (18,18,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (19,19,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));
INSERT INTO dbo.UserAccountsMapping(UserId,AccountId,CreatedOn,CreatedById,LastLogin,LastLogout,ValidTill) VALUES (20,20,'07/27/2019',5,GETDATE(),GETDATE(),DATEADD(YEAR,1,'07/27/2019'));

---------------------------------------------------------------------------------------------------------------------------Inserting Data Table UserGroupAccountMapping **

INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (1,4,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (2,4,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (3,4,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (4,4,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (5,3,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (6,3,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (7,3,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (8,3,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (9,3,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (10,2,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (11,2,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (12,2,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (13,2,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (14,2,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (15,2,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (16,2,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (17,1,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (18,1,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (19,1,CONVERT(datetime,'07/27/2019'),2);
INSERT INTO dbo.UserGroupAccountMapping(AccountId,UserGroupId,AssignedOn,AssignedById) VALUES (20,1,CONVERT(datetime,'07/27/2019'),2);

-------------------------------------------------------------------------------------------------View
-- This view is to obtain the Accounts(Accounts table) which are active but do not have active permissions(permissions table)

CREATE VIEW V_ActiveAccountsWithOutAnyPermission
AS 
SELECT 
	a.AccountId AS Account_Id, 
	a.Description AS Account_Description,
	(CASE WHEN a.Active = 0 THEN 'Inactive' ELSE 'Active' END) AS Account_status, 
	(CASE WHEN p.Active = 0 THEN 'Inactive' ELSE 'Active' END) AS Permission_status 
FROM
	dbo.Accounts a
	JOIN
	dbo.Permissions p
	ON a.AccountId = p.AccountId
WHERE
 	a.Active = 1 and P.Active = 0;

 
SELECT TOP 10 *
FROM V_ActiveAccountsWithOutAnyPermission;

-------------------------------------------------------------------------------------------------View
-- This view takes in a particular user and a particular account and specifies all the permissions for that user for that account

CREATE VIEW V_UserAccountPermissions 
AS
SELECT 
	   A.UserId, A.AccountId, P.PermissionType, P.Description, 
	   (CASE WHEN P.Active = 0 THEN 'Inactive' ELSE 'Active' END) AS Permission_status
FROM Accounts A
INNER JOIN Permissions P 
ON P.AccountId=A.AccountId;

SELECT * FROM V_UserAccountPermissions WHERE UserId = 3 AND AccountId = 3;



-------------------------------------------------------------------------------------------------View
-- This view provides a given users contact details such as Team name, Department name, Deskphone, Email when given a user's firstname
 
CREATE VIEW V_UserTeamDetails
AS
SELECT U.FName, U.LName, T.TeamName, D.DepartmentName, U.DeskPhone, U.Email
FROM Users U JOIN Team T ON U.TeamId=T.TeamId
JOIN Department D ON D.DepartmentId=T.DepartmentId;


SELECT * FROM V_UserTeamDetails WHERE FName = 'vijaya';


-------------------------------------------------------------------------------------------------View
-- This view gives the number of accounts each user has
DROP VIEW dbo.V_NumAccountsPerUser;

CREATE VIEW V_NumAccountsPerUser
AS
SELECT A.UserId, Count(B.AccountId) as NumberOfAccounts
FROM dbo.Users A 
LEFT JOIN dbo.Accounts B 
ON A.UserId=B.UserId
GROUP BY A.UserId;

SELECT * FROM V_NumAccountsPerUser;

-------------------------------------------------------------------------------------------------View
-- This view gives the number of male and female employees for each role
DROP VIEW dbo.V_GenderRatioByRole;

CREATE VIEW V_GenderRatioByRole
AS
WITH temp AS 
	(SELECT C.RoleId as RoleId, C.Name as RoleName, A.UserId as UserId, A.Gender as Gender
	 FROM dbo.Users A 
	 JOIN dbo.UserRoleMapping B 
	 ON A.UserId = B.UserId
	 JOIN dbo.Roles C
	 ON B.RoleId = C.RoleId
	) 
SELECT
	RoleName,
	count(UserId) as Employees,
	count( case when Gender ='M'
                   then 1 end ) as Male, 
    count( case when Gender ='F'
                   then 1 end ) as Female
FROM
	temp
GROUP BY RoleName;

SELECT * FROM V_GenderRatioByRole;
-----
