BEGIN TRANSACTION;

UPDATE dbo.LabAccounts
SET Balance = Balance - 200
WHERE Id = 2;

WAITFOR DELAY '00:00:05';

UPDATE dbo.LabAccounts
SET Balance = Balance + 200
WHERE Id = 1;

COMMIT;
------
BEGIN TRANSACTION;

UPDATE dbo.LabAccounts
SET Balance = Balance + 200
WHERE Id = 1;

WAITFOR DELAY '00:00:05';

UPDATE dbo.LabAccounts
SET Balance = Balance - 200
WHERE Id = 2;

COMMIT;