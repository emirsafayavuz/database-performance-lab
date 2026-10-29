# SQL Server Concurrency & Transactions Lab

## Objective

Explore how SQL Server handles concurrent updates, blocking, deadlocks, and atomic balance modifications.

## Experiments

### 1. Blocking

Two sessions attempted to update the same account while the first transaction held a lock.

**Observation:** The second session waited until the first transaction completed. The conditional update affected 0 rows, leaving a final balance of 200.00.

### 2. Deadlock

Two transactions updated accounts in opposite order (1 → 2 and 2 → 1).

**Observation:** SQL Server detected a deadlock and selected Session B (SPID 91) as the victim, returning error 1205. Execution time was approximately 6.566 seconds.

**Mitigation:** Both transactions were changed to access accounts in the same order. The deadlock was replaced by ordinary blocking, observed at approximately 8 seconds.

### 3. Atomic Conditional Update

Two concurrent requests attempted to withdraw 800.00 from an account with a balance of 1,000.00.

**Observation:** The second update affected 0 rows. The final balance remained 200.00.

## Key Takeaways

- Blocking and deadlocks are different concurrency behaviors.
- Consistent resource access ordering can reduce deadlock risk.
- Atomic conditional updates can enforce balance constraints without a separate read-then-write sequence.
- Affected row counts must be checked by application code.
- Local SQL transactions do not guarantee consistency with external payment systems.