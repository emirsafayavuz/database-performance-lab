# SQL Server Concurrency & Transactions

## Environment

- Database: Microsoft SQL Server
- Execution: Two independent SQL sessions
- Test data: Accounts initialized with a balance of 1,000.00
- Focus: Blocking, deadlocks, atomic updates, and transaction isolation

## 1. Blocking

**Scenario:** Two sessions attempted to withdraw money from the same account.

Session A withdrew 800.00 while holding an open transaction. Session B attempted to withdraw 500.00 using a conditional update.

**Observed results:**
- Session B was blocked until Session A committed.
- Session B's update affected 0 rows.
- Final account balance: **200.00**

**Conclusion:** SQL Server serialized the conflicting updates through locking. After Session A committed, Session B could not satisfy the balance condition.

## 2. Deadlock

**Scenario:** Two transactions updated the same accounts in opposite order.

- Session A: Account 1 → Account 2
- Session B: Account 2 → Account 1

**Observed results:**
- SQL Server detected a deadlock.
- Session B was selected as the deadlock victim.
- Error: **1205**
- Victim SPID: **91**
- Execution time: approximately **6.566 seconds**

**Mitigation test:**

Both sessions were changed to access accounts in the same order.

**Observed results:**
- No deadlock occurred in the repeated test.
- One transaction waited for the other.
- Observed execution time: approximately **8 seconds**

**Conclusion:** Consistent resource access ordering removes this particular circular-wait pattern. It reduces deadlock risk but does not eliminate all possible deadlocks.

## 3. Atomic Conditional Update

**Scenario:** Two concurrent sessions attempted to withdraw 800.00 from an account containing 1,000.00.

The update included a balance condition:

```sql
UPDATE dbo.LabAccounts
SET Balance = Balance - 800
WHERE Id = 1
  AND Balance >= 800;
```

**Observed results:**
- Session A performed the first withdrawal.
- Session B affected **0 rows**.
- Final balance: **200.00**

**Conclusion:** Checking and modifying the balance in a single conditional UPDATE prevented both withdrawals from succeeding.

The application must check the affected row count and handle a rejected withdrawal explicitly.

## 4. READ COMMITTED — Non-repeatable Read

**Scenario:** Session A read an account balance twice within the same transaction. Session B updated the balance between those reads.

**Observed results:**

| Read | Balance |
|---|---:|
| First read | 1,000.00 |
| Second read | 600.00 |

**Conclusion:** READ COMMITTED prevents dirty reads but allows a transaction to observe different committed values across separate statements.

## 5. REPEATABLE READ

**Scenario:** The previous experiment was repeated using REPEATABLE READ.

**Observed behavior:**
- The initial test returned 600.00 for both reads because the account had not been reset to its original balance.
- That initial result alone was not sufficient to demonstrate blocking.

**Expected locking behavior:** Under SQL Server's locking-based REPEATABLE READ, shared locks on read rows are retained until the transaction completes. A concurrent UPDATE of those rows must wait.

**Conclusion:** REPEATABLE READ prevents non-repeatable reads of existing rows, with potentially increased blocking.

## 6. Phantom Reads — REPEATABLE READ vs. SERIALIZABLE

**Scenario:** Session A counted transfers for `CustomerId = 1` twice. Session B attempted to insert another matching transfer between the reads.

**REPEATABLE READ:**
- A matching INSERT can occur between the two SELECT statements.
- The count can change from 2 to 3.

**SERIALIZABLE:**
- SQL Server can protect the matching index key range.
- A concurrent INSERT into the protected range must wait until Session A completes.
- The count remains stable during Session A's transaction.

**Conclusion:** REPEATABLE READ protects previously read rows from concurrent modification, while SERIALIZABLE additionally prevents phantom rows from changing the result of a protected predicate.

The exact locking footprint depends on the execution plan and available indexes.

## Key Learnings

1. Blocking is normal concurrency control; a deadlock is a circular dependency that requires resolution.
2. Deadlocks can be reduced by accessing shared resources in a consistent order.
3. Conditional UPDATE statements are useful for enforcing balance constraints atomically.
4. READ COMMITTED does not guarantee repeatable reads.
5. Stronger isolation can improve consistency guarantees but increase blocking and contention.
6. Index design influences the locking footprint of SERIALIZABLE queries.
7. Database transaction guarantees do not automatically extend to external payment services.

## Limitations

- These were controlled, two-session SQL experiments rather than production load tests.
- No throughput, lock-wait distribution, or high-concurrency benchmarks were collected.
- The experiments do not demonstrate end-to-end payment idempotency or distributed transaction reliability.