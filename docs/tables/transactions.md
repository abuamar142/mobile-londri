# 🛍️ Transactions Table

<div align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Auto_ID-FFA500?style=for-the-badge&logoColor=white" alt="Auto ID"/>
</div>

> **📚 Navigation:** [🏠 Main](../../README.md) • [📋 All Docs](../_navigation.md) •
> [🗃️ Setup](../supabase.md) • [📊 Dashboard](../dashboard_statistics.md)

## 📋 Table Documentation Navigation

| Table               | This Page      | Other Tables                                                                           |
| ------------------- | -------------- | -------------------------------------------------------------------------------------- |
| 🛍️ **Transactions** | **✅ Current** | [👤 Users](./users.md) • [👥 Customers](./customers.md) • [🏷️ Services](./services.md) |

- Working Mechanism
- Row Level Security
- Prerequisites
- Usage Examples

## 🔍 Overview

This document details the structure of the `transactions` table in the **PostgreSQL** database for
the **LONDRI** application. It includes the implementation of functions and triggers that
automatically generate unique transaction IDs, as well as security policies.

## 🔢 Transaction ID Format

Each transaction is assigned a unique ID with the following format:

```
TRX-YYMMDD-XXX
```

Where:

- `TRX`: Fixed prefix identifying a transaction
- `YYMMDD`: Current date (year, month, day)
- `XXX`: Sequential number for transactions created on that date (padded with zeros)

**Example**: `TRX-240515-001`

## 📊 Table Structure

The following SQL creates the transactions table with all required fields and constraints:

```sql
-- ENUMS
CREATE TYPE app_transaction_status AS ENUM (
  'On Progress',
  'Ready for Pickup',
  'Picked Up',
  'Other'
);

CREATE TYPE app_payment_status AS ENUM (
  'Not Paid Yet',
  'Paid',
  'Other'
);

-- CREATE TABLE
CREATE TABLE public.transactions (
  id TEXT PRIMARY KEY,
  staff_id BIGINT NOT NULL,
  customer_id BIGINT NULL,
  service_id BIGINT NULL,
  weight DOUBLE PRECISION NOT NULL DEFAULT 0,
  amount INTEGER NOT NULL DEFAULT 0,
  description TEXT,
  transaction_status app_transaction_status NOT NULL DEFAULT 'On Progress',
  payment_status app_payment_status NOT NULL DEFAULT 'Not Paid Yet',
  start_date TIMESTAMPTZ NOT NULL DEFAULT now(),
  end_date TIMESTAMPTZ NULL,
  paid_at TIMESTAMPTZ NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,

  -- RELATIONS
  CONSTRAINT transactions_staff_id_fkey FOREIGN KEY (staff_id)
    REFERENCES public.users (id) ON UPDATE CASCADE ON DELETE SET NULL,

  CONSTRAINT transactions_customer_id_fkey FOREIGN KEY (customer_id)
    REFERENCES public.customers (id) ON UPDATE CASCADE ON DELETE SET NULL,

  CONSTRAINT transactions_service_id_fkey FOREIGN KEY (service_id)
    REFERENCES public.services (id) ON UPDATE CASCADE ON DELETE SET NULL
);

-- INDEXES
CREATE INDEX idx_transactions_status ON public.transactions (transaction_status);
CREATE INDEX idx_transactions_payment_status ON public.transactions (payment_status);
CREATE INDEX idx_transactions_staff_id ON public.transactions (staff_id);
CREATE INDEX idx_transactions_customer_id ON public.transactions (customer_id);
CREATE INDEX idx_transactions_service_id ON public.transactions (service_id);
```

## ⚙️ Auto-Generated Transaction ID

The system automatically generates unique transaction IDs using the following components:

### 1. Function: `generate_transaction_id`

This function creates a new transaction ID based on the current date and transaction count:

```sql
CREATE OR REPLACE FUNCTION generate_transaction_id()
RETURNS TEXT AS $$
DECLARE
    today TEXT := TO_CHAR(NOW(), 'YYMMDD');
    count_today INT;
    new_id TEXT;
BEGIN
    SELECT COUNT(*) + 1 INTO count_today
    FROM transactions
    WHERE TO_CHAR(created_at, 'YYMMDD') = today;

    new_id := 'TRX-' || today || '-' || LPAD(count_today::TEXT, 3, '0');
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;
```

### 2. Trigger Function: `set_transaction_id`

This function applies the generated ID to new transactions:

```sql
CREATE OR REPLACE FUNCTION set_transaction_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.id := generate_transaction_id();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 3. Trigger: `before_insert_transaction`

This trigger executes the ID generation before a new transaction is inserted:

```sql
CREATE TRIGGER before_insert_transaction
BEFORE INSERT ON public.transactions
FOR EACH ROW
WHEN (NEW.id IS NULL)
EXECUTE FUNCTION set_transaction_id();
```

### 4. Trigger: `after_update_transactions`

This trigger automatically updates the `updated_at` timestamp when a record is modified:

```sql
CREATE TRIGGER after_update_transactions
AFTER UPDATE ON public.transactions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
```

## 💰 Automatic Payment Tracking

The system automatically manages the `paid_at` timestamp based on the `payment_status` field:

### 1. Function: `set_paid_at_based_on_payment_status`

This function automatically sets the `paid_at` timestamp when payment status changes:

```sql
CREATE OR REPLACE FUNCTION set_paid_at_based_on_payment_status()
RETURNS TRIGGER AS $$
BEGIN
  -- If payment_status is 'Paid', set paid_at to current timestamp
  -- Otherwise, set paid_at to NULL
  IF NEW.payment_status = 'Paid' THEN
    NEW.paid_at = now();
  ELSE
    NEW.paid_at = NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 2. Triggers for Payment Status Changes

These triggers ensure `paid_at` is automatically updated:

```sql
-- Trigger for INSERT operations
CREATE TRIGGER trigger_set_paid_at_on_insert
  BEFORE INSERT ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION set_paid_at_based_on_payment_status();

-- Trigger for UPDATE operations (only when payment_status changes)
CREATE TRIGGER trigger_set_paid_at_on_update
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW
  WHEN (OLD.payment_status IS DISTINCT FROM NEW.payment_status)
  EXECUTE FUNCTION set_paid_at_based_on_payment_status();
```

### 3. Payment Status Logic

- **When `payment_status` = 'Paid'**: `paid_at` is automatically set to `now()`
- **When `payment_status` = 'Not Paid Yet'** or **'Other'**: `paid_at` is set to `NULL`
- This works for both INSERT and UPDATE operations

## 🔄 Working Mechanism

1. When a new transaction is inserted without an ID, the trigger activates
2. The trigger calls the `set_transaction_id()` function
3. This function calls `generate_transaction_id()` to create a unique ID
4. The ID is formatted with today's date and an incremental counter
5. The new ID is assigned to the transaction before it's saved
6. When a record is updated, the `updated_at` field is automatically set to the current time

## 🔒 Row Level Security

The table implements row-level security (RLS) with the following policies:

```sql
-- Enable RLS
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Allow authorized select access" ON public.transactions
  FOR SELECT TO authenticated
  USING ((SELECT authorize('transactions.select')));

CREATE POLICY "Allow authorized insert access" ON public.transactions
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT authorize('transactions.insert')));

CREATE POLICY "Allow authorized update access" ON public.transactions
  FOR UPDATE TO authenticated
  USING ((SELECT authorize('transactions.update')));

CREATE POLICY "Allow authorized delete access" ON public.transactions
  FOR DELETE TO authenticated
  USING ((SELECT authorize('transactions.delete')));
```

### Role Permissions

```sql
-- ROLE PERMISSIONS
INSERT INTO public.role_permissions (role, permission) VALUES
  ('super_admin', 'transactions.select'),
  ('super_admin', 'transactions.insert'),
  ('super_admin', 'transactions.update'),
  ('super_admin', 'transactions.delete');

INSERT INTO public.role_permissions (role, permission) VALUES
  ('admin', 'transactions.select'),
  ('admin', 'transactions.insert'),
  ('admin', 'transactions.update'),
  ('admin', 'transactions.delete');

INSERT INTO public.role_permissions (role, permission) VALUES
  ('user', 'transactions.select'),
  ('user', 'customers.select'),
  ('user', 'services.select');
```

## ⚠️ Prerequisites

Before implementing this table, ensure:

- The enums `app_transaction_status` and `app_payment_status` have been created
- Referenced tables (`customers`, `services`, and `users`) already exist with BIGINT id columns
- The `set_updated_at()` function exists for the automatic timestamp update trigger
- The `authorize()` function exists for RLS policies
- The `role_permissions` table is properly set up for the permission system

## 💡 Usage Examples

### Inserting a New Transaction

```sql
-- Example 1: Basic insert (ID will be auto-generated)
INSERT INTO transactions (staff_id, customer_id, weight, amount, service_id)
VALUES (1, 2, 3.5, 35000, 3);

-- Example 2: Inserting with all fields (ID will still be auto-generated)
INSERT INTO transactions (
  staff_id, customer_id, weight, amount, service_id,
  description, transaction_status, payment_status
) VALUES (
  1, 2, 2.0, 25000, 3,
  'Express laundry with extra fabric softener',
  'On Progress', 'Not Paid Yet'
);
```

---

## 🔗 Table Documentation Navigation

<div align="center">

**Previous:** [👤 Users](./users.md) • **Current:** 🛍️ Transactions • **Next:**
[👥 Customers](./customers.md)

| [📋 All Docs](../_navigation.md) | [🗃️ Setup](../supabase.md) | [📊 Dashboard](../dashboard_statistics.md) | [🏠 Project](../../README.md) |
| :------------------------------: | :------------------------: | :----------------------------------------: | :---------------------------: |

</div>

---

<div align="center">
  <strong>LONDRI Database Schema</strong> • <a href="#-transactions-table">⬆️ Back to Top</a>
</div>
