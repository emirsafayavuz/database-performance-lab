# Database Performance Lab

Hands-on experiments for understanding SQL Server and EF Core performance
through execution plans, measurements, and reproducible workloads.

The goal of this repository is not to collect optimization tips, but to build
a systematic approach to diagnosing database performance problems.

## Focus Areas

- SQL Server execution plans
- Index access paths
- Logical reads and query cost
- Statistics and cardinality estimation
- Query selectivity and SARGability
- Join algorithms
- SQL Server concurrency and blocking
- EF Core query performance
- Measurement-driven optimization

## Method

Each experiment follows the same approach:

**Predict → Execute → Measure → Explain**

Performance decisions are based on evidence such as:

- Actual execution plans
- Estimated vs actual row counts
- Rows read vs rows returned
- Logical reads
- CPU and elapsed time
- Operator execution counts
- Query and index structure

Local timing results are treated as supporting evidence rather than absolute
benchmarks.

## Labs

### 01 — Index Access Paths

Experiments covering:

- Clustered Index Scan vs Index Seek
- Nonclustered indexes
- Key Lookups
- Selectivity
- Covering queries
- SARGability
- Rows Read vs Rows Returned

Key observation:

> An Index Seek is not automatically efficient, and an Index Scan is not
> automatically a problem. The amount of work performed matters more than
> the operator name.

See [`01-index-access-paths/results.md`](01-index-access-paths/results.md)
for measurements and analysis.

## Environment

- SQL Server 2025 Developer
- Docker
- Apple Silicon host
- SQL Server container running through amd64 emulation

Because the database engine runs under emulation, absolute timing results
should not be interpreted as production performance. Execution-plan behavior,
logical reads, cardinality, and relative access patterns are the primary
signals used in the experiments.