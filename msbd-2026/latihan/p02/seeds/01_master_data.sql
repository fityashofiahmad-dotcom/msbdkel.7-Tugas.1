-- Seed data untuk entitas VENUE
INSERT INTO venue (nama_venue, kota, kapasitas_maksimal) VALUES
('Stadion Utama GBK', 'Jakarta', 77193),
('Jakarta International Stadium', 'Jakarta', 82000),
('Prambanan Jazz Venue', 'Yogyakarta', 10000)
ON CONFLICT (nama_venue)
DO UPDATE SET 
    kota = EXCLUDED.kota, 
    kapasitas_maksimal = EXCLUDED.kapasitas_maksimal;

-- Seed data untuk entitas ARTIST
INSERT INTO artist (nama_artist, genre) VALUES
('Coldplay', 'Pop Rock'),
('Dewa 19', 'Rock'),
('Tulus', 'Pop')
ON CONFLICT (nama_artist)
DO UPDATE SET 
    genre = EXCLUDED.genre;