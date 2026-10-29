UPDATE dbo.LabAccounts
SET Balance = Balance - 800
WHERE Id = 1
  AND Balance >= 800;

SELECT @@ROWCOUNT AS AffectedRows;

SELECT Balance AS FinalBalance
FROM dbo.LabAccounts
WHERE Id = 1;