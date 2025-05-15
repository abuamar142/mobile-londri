# Supabase Database Setup

Dokumen ini menjelaskan bagaimana pengaturan awal database untuk aplikasi **LONDRI**, menggunakan
**PostgreSQL** yang disediakan oleh [Supabase](https://supabase.com/). Supabase adalah platform
backend yang menyediakan database PostgreSQL, autentikasi, storage, dan real-time API bawaan.

## Teknologi yang Digunakan

- **PostgreSQL** (hosted by Supabase)
- **Supabase Auth** (untuk autentikasi user)
- **PL/pgSQL** (untuk fungsi dan trigger database)
- **Timezone**: `Asia/Jakarta`

## Langkah-Langkah Setup Database

Berikut adalah langkah-langkah umum untuk menyiapkan database agar aplikasi LONDRI dapat berjalan
dengan baik:

1. **Buat Tabel Transaksi**

   - Gunakan skrip SQL untuk membuat tabel `transactions` dan fungsi auto-generated ID.
   - **Lihat dokumentasi lengkap dan jalankan perintah SQL-nya di
     [transactions.md](./tables/transactions.md)**
