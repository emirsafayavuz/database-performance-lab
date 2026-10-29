BEGIN TRANSACTION;

UPDATE dbo.LabAccounts
SET Balance = Balance - 100
WHERE Id = 1;

WAITFOR DELAY '00:00:05';

UPDATE dbo.LabAccounts
SET Balance = Balance + 100
WHERE Id = 2;

COMMIT;