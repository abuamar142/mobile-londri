# 🗃️ Supabase Database Setup

<div align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase"/>
</div>

> **📚 Navigation:** [🏠 Main](../README.md) • [📋 All Docs](./_navigation.md) •
> [📊 Dashboard](./dashboard_statistics.md) • [📋 Tables](./tables/)

## 📋 Quick Navigation

| Step  | Document                                  | Description                    |
| ----- | ----------------------------------------- | ------------------------------ |
| **1** | [🗃️ This Guide](./supabase.md)            | Database setup & configuration |
| **2** | [📊 Dashboard](./dashboard_statistics.md) | Analytics functions            |
| **3** | [📋 Tables](./tables/)                    | Schema documentation           |
| **4** | [🏠 Back to Project](../README.md)        | Main README                    |

## 🔍 Overview

This document describes the initial database setup for the **LONDRI** application using
**PostgreSQL** provided by [Supabase](https://supabase.com/). Supabase is a backend platform that
offers PostgreSQL databases, authentication, storage, and built-in real-time APIs.

## 💻 Technologies

- **PostgreSQL** (hosted by Supabase)
- **Supabase Auth** (user authentication)
- **PL/pgSQL** (database functions and triggers)

## 🚀 Setup Steps

Follow these steps to set up the database for the LONDRI application:

### 1. Environment Configuration

- Copy the `.env.example` file and rename it to `.env`
- Add the following variables:

```bash
SUPABASE_URL=https://your-supabase-url.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

- Replace the placeholder values with your credentials from
  [Supabase Dashboard](https://supabase.com/dashboard/project/_/settings/api/)

### 2. Role-Based Access Control Implementation

- Create user tables and configure permissions
- **[See complete documentation in Users Table](./tables/users.md)**

### 3. Transaction System Setup

- Configure the transactions table with auto-generated IDs
- **[See complete documentation in Transactions Table](./tables/transactions.md)**

### 4. Dashboard Statistics Functions Setup

- Create optimized PostgreSQL functions for dashboard statistics
- **[See complete documentation in Dashboard Statistics](./dashboard_statistics.md)**

## 📊 Table Documentation

| Table Name   | Description                              | Documentation Link                             |
| ------------ | ---------------------------------------- | ---------------------------------------------- |
| Users        | User accounts, roles, and permissions    | [Users Table](./tables/users.md)               |
| Transactions | Laundry transactions and status tracking | [Transactions Table](./tables/transactions.md) |
| Customers    | Customer information and contact details | [Customers Table](./tables/customers.md)       |
| Services     | Laundry services offered and pricing     | [Services Table](./tables/services.md)         |

## 🔧 Database Functions

| Function Category    | Description                       | Documentation Link                                |
| -------------------- | --------------------------------- | ------------------------------------------------- |
| Dashboard Statistics | Revenue and transaction analytics | [Dashboard Statistics](./dashboard_statistics.md) |

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Flutter Integration](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)

---

## 🔗 Documentation Navigation

<div align="center">

**Previous:** [🏠 Main README](../README.md) • **Next:**
[📊 Dashboard Statistics](./dashboard_statistics.md)

| [📋 All Docs](./_navigation.md) | [📋 Tables](./tables/) | [🏠 Back to Project](../README.md) |
| :-----------------------------: | :--------------------: | :--------------------------------: |

</div>

---

<div align="center">
  <strong>LONDRI Documentation</strong> • <a href="#-supabase-database-setup">⬆️ Back to Top</a>
</div>
</div>
