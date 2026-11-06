# Penanganan Error

Aplikasi menangani tiga jenis kesalahan: validasi, jaringan atau API, dan database.
Setiap jenis diuji dengan memicunya secara sengaja.

| No | Skenario | Cara memicu | Hasil di aplikasi | Penyebab | Penanganan |
|---|---|---|---|---|---|
| 1 | Jaringan putus (menulis) | DevTools Network Offline | SnackBar: tidak ada koneksi internet; form tetap terbuka | `ClientException` dari HTTP | `friendlyError()` mengubah pesan |
| 2 | Jaringan putus (memuat) | Host Supabase salah | ErrorView dengan tombol Coba lagi | Host tidak ditemukan | State `error` di provider |
| 3 | Tabel salah | Nama tabel diganti | "Tabel database tidak ditemukan" | Kode PGRST205 | `apiExceptionFromPostgrest()` |
| 4 | JSON tidak cocok (baca) | Key `fromJson` diganti | "Format data dari server tidak sesuai" | `TypeError` pada cast null | `friendlyError()` |
| 5 | Kolom salah (tulis) | Key `toJson` diganti | "Kolom database tidak ditemukan" | Kode PGRST204 | `apiExceptionFromPostgrest()` |
| 6 | RLS menolak | Policy dihapus | Insert: pesan RLS. Update/delete: "ditolak oleh aturan akses". Select: daftar kosong | Kode 42501, atau nol baris terdampak | Pemeriksaan hasil kosong; empty state |
| 7 | Constraint database | Akun tidak valid dikirim | "Data ditolak database" | Kode 23514 | Validasi backend sebagai lapisan terakhir |
| 8 | Batas waktu | Timeout 1 ms | "Server terlalu lama merespons" | `TimeoutException` | `.timeout()` di data source; peringatan khusus untuk penulisan |
| 9 | Gagal saat dibuka | Exception disengaja | Layar penjelasan dengan Coba lagi | `Supabase.initialize` gagal | `StartupErrorApp` |
| 10 | REST API gagal | URL Frankfurter salah | "Layanan kurs mengembalikan kesalahan (HTTP 404)" | Status bukan 200 | Status diperiksa sebelum `jsonDecode` |
| 11 | Validasi form | Kolom kosong atau nominal 0 | Pesan merah di bawah kolom | Input tidak valid | `validateTitle`, `validateAmount` |