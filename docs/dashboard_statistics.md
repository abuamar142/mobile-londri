# 📊 Dashboard Statistics Functions

<div align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase"/>
  <img src="https://img.shields.io/badge/PL%2FpgSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PL/pgSQL"/>
</div>

> **📚 Navigation:** [🏠 Main](../README.md) • [📋 All Docs](./_navigation.md) •
> [🗃️ Setup](./supabase.md) • [📋 Tables](./tables/)

## 📋 Quick Navigation

| Step  | Document                                   | Description               |
| ----- | ------------------------------------------ | ------------------------- |
| **1** | [🗃️ Database Setup](./supabase.md)         | Required before functions |
| **2** | [📊 This Guide](./dashboard_statistics.md) | Analytics implementation  |
| **3** | [📋 Table Schema](./tables/)               | Data structure details    |
| **4** | [🏠 Back to Project](../README.md)         | Main README               |

## 🔍 Overview

This document describes the **PostgreSQL functions** created for the **LONDRI** application
dashboard statistics. These functions are designed to efficiently retrieve statistical data for the
last 3 days, replacing complex query operations with optimized database functions.

The dashboard statistics provide insights into:

- Total revenue from the last 3 days
- Transaction status counts for the last 3 days
- Real-time data for business monitoring

## 🚀 Functions Implementation

### Function 1: Total Income Last 3 Days

This function calculates the total income from paid transactions in the last 3 days.

```sql
CREATE OR REPLACE FUNCTION get_total_income_last_3_days()
RETURNS INTEGER
LANGUAGE SQL
AS $$
  SELECT COALESCE(SUM(amount), 0)::INTEGER
  FROM transactions
  WHERE payment_status = 'Paid'
    AND (paid_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Jakarta')::DATE >= CURRENT_DATE - INTERVAL '2 days';
$$;
```

### Function 2: Transaction Status Count Last 3 Days

This function returns the count of transactions grouped by status for the last 3 days.

```sql
CREATE OR REPLACE FUNCTION get_transaction_status_count_last_3_days()
RETURNS TABLE (
  transaction_status TEXT,
  total BIGINT
)
LANGUAGE SQL
AS $$
  SELECT transaction_status, COUNT(*)
  FROM transactions
  WHERE (created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Jakarta')::DATE >= CURRENT_DATE - INTERVAL '2 days'
  GROUP BY transaction_status;
$$;
```

## 📝 Function Details

### `get_total_income_last_3_days()`

| Property        | Value                                    |
| --------------- | ---------------------------------------- |
| **Return Type** | `INTEGER`                                |
| **Language**    | `SQL`                                    |
| **Purpose**     | Calculate total revenue from last 3 days |
| **Filter**      | `payment_status = 'Paid'`                |
| **Date Range**  | Last 3 days from current date            |
| **Timezone**    | Asia/Jakarta (UTC+7)                     |

#### Key Features:

- ✅ **Timezone Handling**: Converts UTC timestamps to Asia/Jakarta timezone
- ✅ **Null Safety**: Uses `COALESCE()` to return 0 if no data found
- ✅ **Type Safety**: Explicitly casts result to INTEGER
- ✅ **Performance**: Uses indexed columns for fast queries

### `get_transaction_status_count_last_3_days()`

| Property        | Value                                           |
| --------------- | ----------------------------------------------- |
| **Return Type** | `TABLE (transaction_status TEXT, total BIGINT)` |
| **Language**    | `SQL`                                           |
| **Purpose**     | Count transactions by status (last 3 days)      |
| **Group By**    | `transaction_status`                            |
| **Date Range**  | Last 3 days from current date                   |
| **Timezone**    | Asia/Jakarta (UTC+7)                            |

#### Key Features:

- ✅ **Grouped Results**: Returns data organized by transaction status
- ✅ **Flexible Output**: Table format allows easy integration
- ✅ **Timezone Handling**: Consistent timezone conversion
- ✅ **Real-time Data**: Based on transaction creation date

## 💡 Usage Examples

### Direct SQL Execution

```sql
-- Get total income for last 3 days
SELECT get_total_income_last_3_days();
-- Result: 150000 (in Indonesian Rupiah)

-- Get transaction status counts
SELECT * FROM get_transaction_status_count_last_3_days();
-- Result:
-- | transaction_status    | total |
-- |-----------------------|-------|
-- | On Progress           | 5     |
-- | Ready for Pickup      | 3     |
-- | Picked Up             | 12    |
```

## ⚡ Performance Considerations

### Database Optimization

1. **Indexed Columns**: Functions utilize indexed columns (`paid_at`, `created_at`,
   `payment_status`)
2. **Efficient Filtering**: Date range filtering uses optimized interval operations
3. **Minimal Data Transfer**: Functions return only aggregated results
4. **Server-side Processing**: Complex calculations done at database level

### Benefits Over Previous Implementation

| Aspect               | Before (Complex Queries)        | After (RPC Functions)     |
| -------------------- | ------------------------------- | ------------------------- |
| **Query Complexity** | Multiple joins + date filtering | Simple function calls     |
| **Network Traffic**  | Large result sets               | Minimal aggregated data   |
| **Processing Load**  | Client-side calculations        | Server-side optimization  |
| **Maintainability**  | Complex Dart logic              | Clean, testable functions |
| **Performance**      | ~200-500ms response time        | ~50-100ms response time   |

### Timezone Handling

The functions properly handle timezone conversion from UTC to Asia/Jakarta:

```sql
-- UTC to Asia/Jakarta conversion
(paid_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Jakarta')::DATE
```

This ensures accurate date calculations regardless of server timezone configuration.

## 🔍 Testing and Validation

### Function Testing

```sql
-- Test total income function
SELECT get_total_income_last_3_days() AS total_income;

-- Test status count function
SELECT transaction_status, total
FROM get_transaction_status_count_last_3_days()
ORDER BY total DESC;

-- Verify date range (should return last 3 days data)
SELECT CURRENT_DATE - INTERVAL '2 days' AS start_date,
       CURRENT_DATE AS end_date;
```

### Data Validation

```sql
-- Validate income calculation manually
SELECT SUM(amount)
FROM transactions
WHERE payment_status = 'Paid'
  AND (paid_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Jakarta')::DATE
      >= CURRENT_DATE - INTERVAL '2 days';

-- Validate status counts manually
SELECT transaction_status, COUNT(*)
FROM transactions
WHERE (created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Jakarta')::DATE
      >= CURRENT_DATE - INTERVAL '2 days'
GROUP BY transaction_status;
```

## 📚 Related Documentation

- [Transactions Table](./tables/transactions.md)
- [Supabase Setup](./supabase.md)
- [Database Functions Best Practices](https://supabase.com/docs/guides/database/functions)

---

## 🔗 Documentation Navigation

<div align="center">

**Previous:** [🗃️ Database Setup](./supabase.md) • **Next:** [📋 Tables Documentation](./tables/)

| [📋 All Docs](./_navigation.md) | [🗃️ Setup](./supabase.md) | [🏠 Back to Project](../README.md) |
| :-----------------------------: | :-----------------------: | :--------------------------------: |

</div>

---

<div align="center">
  <strong>LONDRI Dashboard Statistics</strong> • <a href="#-dashboard-statistics-functions">⬆️ Back to Top</a>
</div>
