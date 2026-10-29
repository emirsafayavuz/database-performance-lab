IF OBJECT_ID('dbo.LabAccounts', 'U') IS NOT NULL
    DROP TABLE dbo.LabAccounts;
GO

CREATE TABLE dbo.LabAccounts
(
    Id INT NOT NULL PRIMARY KEY,
    Balance DECIMAL(18,2) NOT NULL
        CHECK (Balance >= 0)
);
GO

INSERT INTO dbo.LabAccounts (Id, Balance)
VALUES (1, 1000.00),
       (2, 1000.00);
GO

SELECT * FROM dbo.LabAccounts;


-- Phantom Read
IF OBJECT_ID('dbo.LabTransfers', 'U') IS NOT NULL
    DROP TABLE dbo.LabTransfers;
GO

CREATE TABLE dbo.LabTransfers
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL
);

CREATE INDEX IX_LabTransfers_CustomerId
ON dbo.LabTransfers(CustomerId);

INSERT INTO dbo.LabTransfers (CustomerId, Amount)
VALUES (1, 100), (1, 200);