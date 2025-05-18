# 🧾 Transactions Table

<div align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Auto_ID-FFA500?style=for-the-badge&logoColor=white" alt="Auto ID"/>
</div>

## 📋 Contents

- [Overview](#overview)
- [Transaction ID Format](#transaction-id-format)
- [Table Structure](#table-structure)
- [Auto-Generated Transaction ID](#auto-generated-transaction-id)
  - [Generation Function](#1-function-generate_transaction_id)
  - [Trigger Function](#2-trigger-function-set_transaction_id)
  - [Trigger Implementation](#3-trigger-before_insert_transaction)
- [Working Mechanism](#working-mechanism)
- [Prerequisites](#prerequisites)
- [Usage Examples](#usage-examples)

## 🔍 Overview

This document details the structure of the `transactions` table in the **Supabase PostgreSQL**
database for the **LONDRI** application. It includes the implementation of functions and triggers
that automatically generate unique transaction IDs.

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
-- Drop table if it already exists
DROP TABLE IF EXISTS public.transactions CASCADE;

-- Create transactions table
CREATE TABLE public.transactions (
  id TEXT PRIMARY KEY,
  staff_id UUID NOT NULL DEFAULT auth.uid(),
  customer_id UUID NULL,
  weight REAL NOT NULL DEFAULT 0,
  amount INTEGER NOT NULL DEFAULT 0,
  start_date TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'Asia/Jakarta'),
  end_date TIMESTAMPTZ NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'Asia/Jakarta'),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'Asia/Jakarta'),
  deleted_at TIMESTAMPTZ NULL,
  service_id UUID NULL,
  status public.app_transaction_status NOT NULL DEFAULT 'received'::app_transaction_status,

  -- Relations with other tables
  CONSTRAINT transactions_customer_id_fkey FOREIGN KEY (customer_id)
    REFERENCES customers (id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT transactions_service_id_fkey FOREIGN KEY (service_id)
    REFERENCES services (id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT transactions_staff_id_fkey FOREIGN KEY (staff_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE SET NULL
);
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
BEFORE INSERT ON transactions
FOR EACH ROW
WHEN (NEW.id IS NULL)
EXECUTE FUNCTION set_transaction_id();
```

## 🔄 Working Mechanism

1. When a new transaction is inserted without an ID, the trigger activates
2. The trigger calls the `set_transaction_id()` function
3. This function calls `generate_transaction_id()` to create a unique ID
4. The ID is formatted with today's date and an incremental counter
5. The new ID is assigned to the transaction before it's saved

## ⚠️ Prerequisites

Before implementing this table, ensure:

- The enum `app_transaction_status` has been created
- Referenced tables (`customers`, `services`, and `users`) already exist
- Default timezone is set to `'Asia/Jakarta'`
- The `created_at` column has a default value of `now()` for proper ID generation

## 💡 Usage Examples

### Inserting a New Transaction

```sql
-- Example 1: Basic insert (ID will be auto-generated)
INSERT INTO transactions (customer_id, weight, amount, service_id)
VALUES ('1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p', 3.5, 35000,
        'abcd1234-5678-90ab-cdef-ghijklmnopqr');

-- Example 2: Inserting with all fields (ID will still be auto-generated)
INSERT INTO transactions (
  staff_id, customer_id, weight, amount, service_id, status
) VALUES (
  'staff-uuid-here', 'customer-uuid-here', 2.0, 25000,
  'service-uuid-here', 'processing'
);
```

---

## 🔄 Related Documentation

- [Main Supabase Setup](../supabase.md)
- [Users Table](./users.md)

<div align="center">
  <a href="../supabase.md">⬅️ Back to Supabase Setup</a>
</div>
