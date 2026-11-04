# Dompetku

Aplikasi pencatat keuangan sederhana untuk mencatat pemasukan dan pengeluaran
harian, agar kondisi dompet mudah dipantau. Project UTS Pemrograman Mobile.

- **Nama:** Gabriel Pranata Sembiring
- **NIM:** 2415051086
- **Kelas:** PTI-5C

## Arsitektur

Screen / Widget -> Provider -> Repository -> Service (REST API, Supabase)

| Folder | Tanggung jawab |
|---|---|
| lib/models | Bentuk data |
| lib/services | Akses REST API dan Supabase |
| lib/repositories | Perantara provider dan service |
| lib/providers | State dan logika |
| lib/screens | Halaman penuh |
| lib/widgets | Komponen UI reusable |
| lib/theme | Tema terang dan gelap |
| lib/utils | Fungsi bantu |
| lib/config | Konstanta dan konfigurasi |

## Backend dan Database

Data transaksi disimpan di **Supabase (PostgreSQL)**. Definisi tabel dan data awal
ada di `supabase/schema.sql`.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint identity | Primary key |
| student_id | text | NIM pemilik data |
| title | text | Judul transaksi |
| amount | bigint | Nominal rupiah, harus lebih dari 0 |
| type | text | `income` atau `expense` |
| category | text | Kategori |
| account | text | `Tunai`, `Bank`, atau `E-wallet` |
| note | text | Catatan |
| trx_date | date | Tanggal transaksi |
| created_at | timestamptz | Diisi otomatis |

Row Level Security aktif dengan policy permisif **khusus praktikum lab**. Policy ini
bukan pola produksi, karena siapa pun yang memegang key publishable dapat mengubah data.
Aplikasi hanya memakai key publishable. Secret key / role key backend tidak digunakan.