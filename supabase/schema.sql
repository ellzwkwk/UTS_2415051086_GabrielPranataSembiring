-- 2415051086 - Gabriel Pranata Sembiring
-- Dompetku: tabel transactions (UTS Pemrograman Mobile)

create table public.transactions (
  id bigint generated always as identity primary key,
  student_id text not null,
  title text not null check (length(btrim(title)) > 0),
  amount bigint not null check (amount > 0),
  type text not null check (type in ('income', 'expense')),
  category text not null,
  account text not null check (account in ('Tunai', 'Bank', 'E-wallet')),
  note text not null default '',
  trx_date date not null default current_date,
  created_at timestamptz not null default now()
);

create index transactions_student_date_idx
  on public.transactions (student_id, trx_date desc);

-- Data awal (sama dengan data contoh di aplikasi)
insert into public.transactions
  (student_id, title, amount, type, category, account, note, trx_date)
values
  ('2415051086', 'Saldo awal', 350000, 'income', 'Saldo awal', 'Tunai', '', '2026-10-31'),
  ('2415051086', 'Saldo awal', 500000, 'income', 'Saldo awal', 'Bank', '', '2026-10-31'),
  ('2415051086', 'Saldo awal', 150000, 'income', 'Saldo awal', 'E-wallet', '', '2026-10-31'),
  ('2415051086', 'Uang saku', 2000000, 'income', 'Uang saku', 'Bank', '', '2026-11-01'),
  ('2415051086', 'Bayar kos', 800000, 'expense', 'Tempat tinggal', 'Bank', 'Kos bulan November', '2026-11-01'),
  ('2415051086', 'Makan siang warteg', 18000, 'expense', 'Makanan', 'Tunai', 'Warteg dekat kampus', '2026-11-02'),
  ('2415051086', 'Fotokopi modul', 12500, 'expense', 'Kuliah', 'Tunai', '', '2026-11-02'),
  ('2415051086', 'Honor asisten lab', 450000, 'income', 'Honor', 'E-wallet', '', '2026-11-02');

-- RLS: aktifkan, lalu beri policy permisif KHUSUS untuk praktikum lab.
alter table public.transactions enable row level security;

create policy "lab_select_transactions" on public.transactions
  for select to anon, authenticated using (true);

create policy "lab_insert_transactions" on public.transactions
  for insert to anon, authenticated with check (true);

create policy "lab_update_transactions" on public.transactions
  for update to anon, authenticated using (true) with check (true);

create policy "lab_delete_transactions" on public.transactions
  for delete to anon, authenticated using (true);