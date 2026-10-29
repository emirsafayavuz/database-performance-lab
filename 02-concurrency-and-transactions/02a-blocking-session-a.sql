SELECT @@SPID AS SessionId;

BEGIN TRANSACTION;

UPDATE dbo.LabAccounts
SET Balance = Balance - 800
WHERE Id = 1
  AND Balance >= 800;

WAITFOR DELAY '00:00:30';

COMMIT;