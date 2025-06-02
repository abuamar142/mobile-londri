# 👥 Customers Table

<div align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
</div>

> **📚 Navigation:** [🏠 Main](../../README.md) • [📋 All Docs](../_navigation.md) •
> [🗃️ Setup](../supabase.md) • [📊 Dashboard](../dashboard_statistics.md)

## 📋 Table Documentation Navigation

| Table            | This Page      | Other Tables                                                                                 |
| ---------------- | -------------- | -------------------------------------------------------------------------------------------- |
| 👥 **Customers** | **✅ Current** | [👤 Users](./users.md) • [🛍️ Transactions](./transactions.md) • [🏷️ Services](./services.md) |

## 🔍 Overview

This document details the structure of the `customers` table in the **Supabase PostgreSQL** database
for the **LONDRI** application. This table stores information about customers who use the laundry
service.

## 📊 Table Structure

The following SQL creates the customers table with all required fields and constraints:

```sql
-- Drop table if it already exists
DROP TABLE IF EXISTS public.customers CASCADE;

-- Create app gender enum
CREATE TYPE public.app_gender AS ENUM ('male', 'female', 'other');

-- Create customers table
CREATE TABLE public.customers (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(15),
  gender public.app_gender NOT NULL DEFAULT 'other',
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ NULL
);

-- Create index for faster search
CREATE INDEX idx_customers_name ON public.customers USING btree (name);
```

## Auto update updated_at where updated data

```sql
-- Create function to set updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to set updated_at after update
CREATE TRIGGER after_update_customers
AFTER UPDATE ON public.customers
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
```

## Add RLS

```sql
-- Enable Row Level Security
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authorized select access" ON public.customers
  FOR SELECT TO authenticated
  USING ((SELECT authorize('customers.select')));

CREATE POLICY "Allow authorized insert access" ON public.customers
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT authorize('customers.insert')));

CREATE POLICY "Allow authorized update access" ON public.customers
  FOR UPDATE TO authenticated
  USING ((SELECT authorize('customers.update')));

CREATE POLICY "Allow authorized delete access" ON public.customers
  FOR DELETE TO authenticated
  USING ((SELECT authorize('customers.delete')));
```

## Add permissions for super admin

```sql
-- Add permissions for super admin
INSERT INTO public.role_permissions (role, permission) VALUES
  ('super_admin', 'customers.select'),
  ('super_admin', 'customers.insert'),
  ('super_admin', 'customers.update'),
  ('super_admin', 'customers.delete'),
  ('admin', 'customers.select'),
  ('admin', 'customers.insert'),
  ('admin', 'customers.update');
```

---

## 🔗 Table Documentation Navigation

<div align="center">

**Previous:** [🛍️ Transactions](./transactions.md) • **Current:** 👥 Customers • **Next:**
[🏷️ Services](./services.md)

| [📋 All Docs](../_navigation.md) | [🗃️ Setup](../supabase.md) | [📊 Dashboard](../dashboard_statistics.md) | [🏠 Project](../../README.md) |
| :------------------------------: | :------------------------: | :----------------------------------------: | :---------------------------: |

</div>

---

<div align="center">
  <strong>LONDRI Database Schema</strong> • <a href="#-customers-table">⬆️ Back to Top</a>
</div>
