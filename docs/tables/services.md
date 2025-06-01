# 🧺 Services Table

<div align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
</div>

## 📋 Contents

- [Overview](#overview)
- [Table Structure](#table-structure)
- [Usage Examples](#usage-examples)

## 🔍 Overview

This document details the structure of the `services` table in the **Supabase PostgreSQL** database
for the **LONDRI** application. This table stores information about the laundry services offered to
customers.

## 📊 Table Structure

The following SQL creates the services table with all required fields and constraints:

```sql
-- Drop table if it already exists
DROP TABLE IF EXISTS public.services CASCADE;

-- Create service unit type enum
CREATE TYPE public.service_unit AS ENUM ('kg', 'item', 'set', 'pair');

-- Create services table
CREATE TABLE public.services (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  unit public.service_unit NOT NULL DEFAULT 'kg',
  duration_hours INTEGER NOT NULL DEFAULT 24,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ NULL
);

-- Create index for faster search
CREATE INDEX idx_services_name ON public.services USING btree (name);
```

## Auto update updated_at when updated data

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
CREATE TRIGGER after_update_services
AFTER UPDATE ON public.services
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
```

## Add RLS

```sql
-- Enable Row Level Security
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authorized select access" ON public.services
  FOR SELECT TO authenticated
  USING ((SELECT authorize('services.select')));

CREATE POLICY "Allow authorized insert access" ON public.services
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT authorize('services.insert')));

CREATE POLICY "Allow authorized update access" ON public.services
  FOR UPDATE TO authenticated
  USING ((SELECT authorize('services.update')));

CREATE POLICY "Allow authorized delete access" ON public.services
  FOR DELETE TO authenticated
  USING ((SELECT authorize('services.delete')));
```

## Add permissions for super admin and admin

```sql
-- Add permissions for super admin and admin
INSERT INTO public.role_permissions (role, permission) VALUES
  ('super_admin', 'services.select'),
  ('super_admin', 'services.insert'),
  ('super_admin', 'services.update'),
  ('super_admin', 'services.delete'),
  ('admin', 'services.select'),
  ('admin', 'services.insert'),
  ('admin', 'services.update'),
  ('admin', 'services.delete'),
  ('staff', 'services.select');
```
