USE BackendPerformanceLab;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

/* ============================================================
   1. Baseline — CustomerId without an index
   Expected: Clustered Index Scan
   ============================================================ */

SELECT
    Id,
    CustomerId,
    Amount,
    Status,
    TransactionDate
FROM dbo.Payment
WHERE CustomerId = 4242;
GO


/* ============================================================
   2. CustomerId nonclustered index
   Expected: Index Seek + Key Lookup
   ============================================================ */

CREATE NONCLUSTERED INDEX IX_Payment_CustomerId
ON dbo.Payment(CustomerId);
GO

SELECT
    Id,
    CustomerId,
    Amount,
    Status,
    TransactionDate
FROM dbo.Payment
WHERE CustomerId = 4242;
GO


/* ============================================================
   3. Status index — low selectivity
   950,000 / 1,000,000 rows match.
   ============================================================ */

CREATE NONCLUSTERED INDEX IX_Payment_Status
ON dbo.Payment(Status);
GO

SELECT
    Id,
    CustomerId,
    Amount,
    Status,
    TransactionDate
FROM dbo.Payment
WHERE Status = 1;
GO


/* ============================================================
   4. Status index — more selective predicate

   Even though only 20,000 rows match, SQL Server may still
   prefer a clustered scan when the query requires columns
   missing from the nonclustered index.
   ============================================================ */

SELECT
    Id,
    CustomerId,
    Amount,
    Status,
    TransactionDate
FROM dbo.Payment
WHERE Status = 3;
GO


/* ============================================================
   5. Covering query

   Id is the clustered key and is available as the row locator
   in the nonclustered Status index.
   ============================================================ */

SELECT
    Id,
    Status
FROM dbo.Payment
WHERE Status = 3;
GO


/* ============================================================
   6. TransactionDate index
   ============================================================ */

CREATE NONCLUSTERED INDEX IX_Payment_TransactionDate
ON dbo.Payment(TransactionDate);
GO


/* ============================================================
   7. Conversion predicate

   SQL Server can transform this particular conversion into
   an index seek, but the generated range may read more rows
   than the query ultimately returns.
   ============================================================ */

SELECT
    Id,
    TransactionDate
FROM dbo.Payment
WHERE CONVERT(date, TransactionDate) = '2025-01-02';
GO


/* ============================================================
   8. Explicit range predicate

   Compare Actual Rows, Rows Read and logical reads with the
   previous query.
   ============================================================ */

SELECT
    Id,
    TransactionDate
FROM dbo.Payment
WHERE TransactionDate >= '2025-01-02'
  AND TransactionDate <  '2025-01-03';
GO

SELECT *
FROM dbo.Payment
WHERE CustomerId = 999999;

SELECT
    name,
    is_auto_update_stats_on
FROM sys.databases
WHERE name = 'BackendPerformanceLab';

DBCC SHOW_STATISTICS
(
    'dbo.Payment',
    'IX_Payment_CustomerId'
);

SELECT *
FROM dbo.Payment
WHERE CustomerId = 999999
OPTION (RECOMPILE);

UPDATE STATISTICS dbo.Payment IX_Payment_CustomerId
WITH FULLSCAN;

DELETE FROM dbo.Payment
WHERE CustomerId = 999999;

UPDATE STATISTICS dbo.Payment
WITH FULLSCAN;

ALTER DATABASE BackendPerformanceLab
SET AUTO_UPDATE_STATISTICS ON;

SELECT
    name,
    is_auto_update_stats_on
FROM sys.databases
WHERE name = 'BackendPerformanceLab';