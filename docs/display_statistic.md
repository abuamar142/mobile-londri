# 📊 Dashboard Statistics SQL Functions (Legacy)

<div align="center">
  <img src="https://img.shields.io/badge/Status-Legacy%2FDeprecated-orange?style=for-the-badge" alt="Legacy"/>
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
</div>

> **📚 Navigation:** [🏠 Main](../README.md) • [📋 All Docs](./_navigation.md) •
> [📊 **Use This Instead**](./dashboard_statistics.md)

## ⚠️ Deprecation Notice

**This file contains raw SQL functions only.**

### 🎯 **For Complete Documentation, Use:**

**[📊 Dashboard Statistics Documentation](./dashboard_statistics.md)**

**Includes:**

- ✅ Implementation details
- ✅ Usage examples
- ✅ Flutter integration
- ✅ Performance optimization
- ✅ Testing procedures

### Function 1: Total Income Last 3 Days

```sql
create or replace function get_total_income_last_3_days()
returns integer
language sql
as $$
  select coalesce(sum(amount), 0)::integer
  from transactions
  where payment_status = 'Paid'
    and (paid_at at time zone 'UTC' at time zone 'Asia/Jakarta')::date >= current_date - interval '2 days';
$$;
```

### Function 2: Transaction Status Count Last 3 Days

```sql
create or replace function get_transaction_status_count_last_3_days()
returns table (
  transaction_status text,
  total bigint
)
language sql
as $$
  select transaction_status, count(*)
  from transactions
  where (created_at at time zone 'UTC' at time zone 'Asia/Jakarta')::date >= current_date - interval '2 days'
  group by transaction_status;
$$;
```

---

## 🔗 Documentation Navigation

<div align="center">

**⚠️ This is Legacy Documentation**

**Use Instead:** [📊 **Dashboard Statistics**](./dashboard_statistics.md) - Complete implementation
guide

| [📋 All Docs](./_navigation.md) | [🗃️ Setup](./supabase.md) | [📊 **Recommended**](./dashboard_statistics.md) | [🏠 Project](../README.md) |
| :-----------------------------: | :-----------------------: | :---------------------------------------------: | :------------------------: |

</div>

---

<div align="center">
  <strong>LONDRI Documentation</strong> • <a href="#-dashboard-statistics-sql-functions-legacy">⬆️ Back to Top</a>
</div>
