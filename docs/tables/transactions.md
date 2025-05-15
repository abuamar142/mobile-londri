# Transactions Table Setup

Dokumen ini menjelaskan detail struktur tabel `transactions` pada database **Supabase PostgreSQL** untuk aplikasi **LONDRI**, termasuk fungsi dan trigger untuk menghasilkan ID transaksi otomatis.

---

## Tujuan

Tabel `transactions` digunakan untuk mencatat semua transaksi laundry, termasuk staf yang menangani, pelanggan, layanan, dan statusnya.

Selain itu, setiap transaksi akan memiliki ID unik dengan format:

```
TRX-YYMMDD-XXX
```

* `YYMMDD`: Tanggal transaksi
* `XXX`: Nomor urut transaksi pada hari tersebut

**Contoh**: `TRX-240515-001`

---

## Struktur Tabel

Jalankan SQL berikut di **Supabase SQL Editor**:

```sql
-- Hapus tabel jika sudah ada
DROP TABLE IF EXISTS public.transactions CASCADE;

-- Buat tabel transactions
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

  -- Relasi dengan tabel customers
  CONSTRAINT transactions_customer_id_fkey FOREIGN KEY (customer_id)
    REFERENCES customers (id) ON UPDATE CASCADE ON DELETE SET NULL,

  -- Relasi dengan tabel services
  CONSTRAINT transactions_service_id_fkey FOREIGN KEY (service_id)
    REFERENCES services (id) ON UPDATE CASCADE ON DELETE SET NULL,

  -- Relasi dengan tabel profiles
  CONSTRAINT transactions_staff_id_fkey FOREIGN KEY (staff_id)
    REFERENCES profiles (id) ON UPDATE CASCADE ON DELETE SET NULL
);
```

---

## Auto-Generated Transaction ID

Untuk memastikan ID transaksi bersifat unik dan berurutan berdasarkan tanggal, kita akan membuat **fungsi dan trigger**.

### 1. Fungsi: `generate_transaction_id`

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

### 2. Fungsi Trigger: `set_transaction_id`

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

```sql
CREATE TRIGGER before_insert_transaction
BEFORE INSERT ON transactions
FOR EACH ROW
WHEN (NEW.id IS NULL)
EXECUTE FUNCTION set_transaction_id();
```

---

## Cara Kerja

* Ketika data baru ditambahkan ke tabel `transactions` tanpa ID, trigger akan otomatis menghasilkan ID baru menggunakan tanggal hari ini dan nomor urut transaksi.
* ID ini disusun agar mudah dibaca dan dilacak berdasarkan waktu dan jumlah transaksi harian.

---

## Persyaratan

* Pastikan enum `app_transaction_status` sudah dibuat.
* Tabel `customers`, `services`, dan `profiles` harus tersedia terlebih dahulu.
* Timezone default menggunakan `'Asia/Jakarta'`.
* Kolom `created_at` harus memiliki default `now()` agar logika `generate_transaction_id()` berjalan dengan benar.

---
## Navigasi

[← Kembali ke Supabase Setup](../supabase.md)