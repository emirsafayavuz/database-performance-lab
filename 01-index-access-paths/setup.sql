USE master;
GO

IF DB_ID('BackendPerformanceLab') IS NOT NULL
BEGIN
    ALTER DATABASE BackendPerformanceLab
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE BackendPerformanceLab;
END
GO

CREATE DATABASE BackendPerformanceLab;
GO

USE BackendPerformanceLab;
GO

SELECT DB_NAME();

CREATE TABLE dbo.Payment
(
    Id              BIGINT IDENTITY(1,1) NOT NULL,
    CustomerId      INT NOT NULL,
    Amount          DECIMAL(18,2) NOT NULL,
    Status          TINYINT NOT NULL,
    TransactionDate DATETIME2(0) NOT NULL,
    Description     VARCHAR(100) NULL,

    CONSTRAINT PK_Payment
        PRIMARY KEY CLUSTERED (Id)
);
GO

;WITH N AS
(
    SELECT TOP (1000000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Payment
(
    CustomerId,
    Amount,
    Status,
    TransactionDate,
    Description
)
SELECT
    ((n - 1) % 100000) + 1,
    CAST(((n * 17) % 100000) / 100.0 + 1 AS DECIMAL(18,2)),
    CASE
        WHEN n % 100 < 95 THEN 1
        WHEN n % 100 < 98 THEN 2
        ELSE 3
    END,
    DATEADD(
        SECOND,
        n % 31536000,
        CAST('2025-01-01' AS DATETIME2)
    ),
    CONCAT('Payment-', n)
FROM N;
GO

SELECT COUNT(*) AS PaymentCount
FROM dbo.Payment;

SELECT
    Status,
    COUNT(*) AS PaymentCount
FROM dbo.Payment
GROUP BY Status
ORDER BY Status;

CREATE NONCLUSTERED INDEX IX_Payment_CustomerId
ON dbo.Payment(CustomerId);

CREATE NONCLUSTERED INDEX IX_Payment_Status
ON dbo.Payment(Status);

CREATE NONCLUSTERED INDEX IX_Payment_TransactionDate
ON dbo.Payment(TransactionDate);