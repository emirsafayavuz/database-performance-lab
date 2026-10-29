SELECT @@SPID AS SessionId;

UPDATE dbo.LabAccounts
SET Balance = Balance - 500
WHERE Id = 1
  AND Balance >= 500;

SELECT @@ROWCOUNT AS AffectedRows;

SELECT Balance AS FinalBalance
FROM dbo.LabAccounts
WHERE Id = 1;