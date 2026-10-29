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
