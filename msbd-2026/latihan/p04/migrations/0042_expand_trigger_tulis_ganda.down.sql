-- Diminta: pasangan .down.sql untuk 0042.
-- Dipilih: drop trigger lalu fungsinya, urutan ini wajib karena trigger
--          bergantung pada fungsi.
-- Alternatif: DROP FUNCTION ... CASCADE untuk sekaligus menghapus trigger;
--          tidak dipilih agar niat setiap DROP eksplisit dan mudah dibaca
--          saat audit rollback.

SET search_path = lab4, public;

DROP TRIGGER IF EXISTS film_tulis_ganda_harga ON lab4.film;
DROP FUNCTION IF EXISTS lab4.tulis_ganda_harga();
