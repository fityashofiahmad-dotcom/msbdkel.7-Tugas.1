PSEUDOCODE STRATEGI RETRY (PYTHON-BASED):

import time
import random

MAX_RETRIES = 5
BASE_BACKOFF_MS = 100

def execute_transaction_with_retry(db_conn, transaction_logic):
    attempt = 0
    while True:
        try:
            db_conn.execute("BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;")
            
            # Jalankan logika query database
            result = transaction_logic(db_conn)
            
            db_conn.execute("COMMIT;")
            
            # Efek samping eksternal dijalankan SETELAH commit berhasil!
            send_external_email(result)
            return result

        except DatabaseError as e:
            db_conn.execute("ROLLBACK;")
            attempt += 1
            
            # Cek SQLSTATE 40001 (Serialization Failure) atau 40P01 (Deadlock)
            if e.sqlstate in ('40001', '40P01') and attempt <= MAX_RETRIES:
                # Calculate Exponential Backoff dengan Jitter
                sleep_time = (BASE_BACKOFF_MS * (2 ** (attempt - 1))) + random.uniform(0, 50)
                time.sleep(sleep_time / 1000.0)
                continue
            else:
                raise e

PENJELASAN EFEK SAMPING EKSTERNAL (SEPERTI KIRIM EMAIL):
Operasi eksternal bersifat non-rollbackable (tidak bisa ditarik kembali oleh database).
Jika email dikirim di dalam blok transaksi sebelum COMMIT, maka saat transaksi gagal 
karena SQLSTATE 40001/40P01 dan di-retry, email akan terkirim berulang kali (duplicate) 
meskipun transaksi database pada akhirnya gagal.
