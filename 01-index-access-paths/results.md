# Lab 01 — Index Access Paths

## Goal

Understand how SQL Server chooses between scans and seeks, how nonclustered
indexes introduce lookup costs, how covering affects access paths, and why
the operator name alone is not enough to judge query performance.

## Environment

- SQL Server 2025 Developer
- Docker
- Apple Silicon / amd64 emulation
- Payment table: 1,000,000 rows

> Timing results are local lab measurements and should not be treated as
> production-representative. Execution plans, row counts, and logical reads
> are the primary evidence in this lab.

---

## 1. CustomerId — No Index

Query:

```sql
WHERE CustomerId = 4242
```

Result:

- Rows returned: 10
- Access path: Clustered Index Scan
- Rows to read: ~1,000,000
- Logical reads: 6,948
- Physical reads: 0
- CPU: 176 ms
- Elapsed: 32 ms

### Observation

Only 10 rows were required, but there was no access path ordered by
`CustomerId`. SQL Server therefore scanned the clustered index.

A selective predicate does not help much if SQL Server has no efficient
access path for that predicate.

---

## 2. CustomerId — Nonclustered Index

Index:

```sql
CREATE NONCLUSTERED INDEX IX_Payment_CustomerId
ON dbo.Payment(CustomerId);
```

Same query result:

- Rows returned: 10
- Plan: Index Seek → Nested Loops → Key Lookup
- Logical reads: 33
- Physical reads: 0
- CPU: 5 ms
- Elapsed: 5 ms

Index Seek:

- Rows read: 10
- Rows returned: 10
- Logical reads: 3

Key Lookup:

- Executions: 10
- Rows returned: 10
- Logical reads: 30

### Observation

The index reduced logical reads from 6,948 to 33 by providing a selective
access path.

However, the query requested columns that were not contained in the
nonclustered index. SQL Server therefore used the clustered key (`Id`) as
the row locator and performed one Key Lookup for each matching row.

A Key Lookup is not automatically a performance problem. Its cost depends
on how many times it is executed.

---

## 3. Status — Selectivity and Lookup Cost

Index:

```sql
CREATE NONCLUSTERED INDEX IX_Payment_Status
ON dbo.Payment(Status);
```

Data distribution:

| Status | Rows |
|---|---:|
| 1 | 950,000 |
| 2 | 30,000 |
| 3 | 20,000 |

### Status = 1

Wide query returned 950,000 rows.

SQL Server chose a Clustered Index Scan instead of using the Status index
followed by a very large number of Key Lookups.

### Status = 3

The same wide query returned 20,000 rows.

SQL Server still chose a Clustered Index Scan:

- Rows returned: 20,000
- Rows read: 1,000,000
- Logical reads: 6,948

The cardinality estimate was approximately correct, so this was not caused
by a bad row estimate.

### Observation

An existing index is not necessarily the cheapest access path.

There is no universal percentage at which SQL Server switches between a
seek + lookup plan and a scan. The decision depends on selectivity, table
width, required columns, lookup cost, index structure, and the optimizer's
cost model.

---

## 4. Covering Query

Query:

```sql
SELECT Id, Status
FROM dbo.Payment
WHERE Status = 3;
```

Result:

- Access path: Index Seek on `IX_Payment_Status`
- Rows returned: 20,000
- Rows read: 20,000
- Logical reads: 41
- Key Lookup: none

### Observation

Although `Id` was not explicitly defined in `IX_Payment_Status`, the
clustered key is available in the nonclustered index as the row locator.

The index therefore contained everything required by this query.

Changing only the SELECT list changed the cheapest access strategy:

```text
Wide SELECT  → Clustered Index Scan
Covered SELECT → Index Seek
```

Covering is query-specific. Adding INCLUDE columns can make an index cover
more queries, but increases storage, write, cache, and maintenance cost.

---

## 5. TransactionDate — SARGability

Index:

```sql
CREATE NONCLUSTERED INDEX IX_Payment_TransactionDate
ON dbo.Payment(TransactionDate);
```

### Conversion predicate

```sql
WHERE CONVERT(date, TransactionDate) = '2025-01-02'
```

Result:

- Access path: Index Seek
- Rows returned: 86,400
- Rows read: 172,799
- Logical reads: 433

SQL Server recognized this conversion and generated a seek range using
`GetRangeThroughConvert`, but the generated range was broader than the
final result. A residual predicate was still required.

### Explicit range predicate

```sql
WHERE TransactionDate >= '2025-01-02'
  AND TransactionDate <  '2025-01-03'
```

Result:

- Access path: Index Seek
- Rows returned: 86,400
- Rows read: 86,400
- Logical reads: 220

### Observation

Both queries used an Index Seek, but they did not perform the same amount
of work.

The explicit range allowed SQL Server to read exactly the required rows,
while the conversion-based predicate read roughly twice as many rows and
then filtered them.

Therefore:

> Index Seek does not automatically mean efficient access.

Inspect:

- Actual Rows
- Number of Rows Read
- Estimated vs Actual Rows
- Executions
- Seek Predicate
- Residual Predicate
- Logical reads

Functions on indexed columns should not be described with the simplistic
rule "function = no index usage." Some expressions can still be transformed
into seekable ranges. The actual execution plan must be verified.

---

## Key Takeaways

1. Seek is not automatically good; scan is not automatically bad.
2. Selectivity matters, but required SELECT columns matter too.
3. Nonclustered indexes may require Key Lookups for missing columns.
4. Covering can eliminate lookup cost.
5. An index existing does not mean the optimizer should use it.
6. Rows Read vs Rows Returned can reveal hidden work even inside a seek.
7. Logical reads are often more useful than a single local timing result.
8. Estimated operator cost percentages are not measured elapsed-time percentages.
9. Execution plans should be read as an operator tree, not as a collection of isolated icons.
10. Index design is a trade-off: read efficiency vs write, storage, cache, and maintenance cost.