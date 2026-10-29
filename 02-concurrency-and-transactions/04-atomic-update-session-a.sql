BEGIN TRANSACTION;

UPDATE dbo.LabAccounts
SET Balance = Balance - 800
WHERE Id = 1
  AND Balance >= 800;

SELECT @@ROWCOUNT AS AffectedRows;

WAITFOR DELAY '00:00:10';

COMMIT;