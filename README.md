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