
-- SESSION A

BEGIN TRANSACTION;

UPDATE dbo.LabAccounts
SET Balance = Balance - 800
WHERE Id = 1
  AND Balance >= 800;

WAITFOR DELAY '00:00:15';

COMMIT;

SELECT Balance AS FinalBalance
FROM dbo.LabAccounts
WHERE Id = 1;


-- SESSION B
-- while Session A is waiting.

UPDATE dbo.LabAccounts
SET Balance = Balance - 500
WHERE Id = 1
  AND Balance >= 500;

SELECT @@ROWCOUNT AS AffectedRows;

SELECT Balance AS FinalBalance
FROM dbo.LabAccounts
WHERE Id = 1;

UPDATE dbo.LabAccounts
SET Balance = 1000
WHERE Id = 1;