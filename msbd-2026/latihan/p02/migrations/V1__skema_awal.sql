CREATE TABLE venue (
    nama_venue varchar(120) PRIMARY KEY,
    kota varchar(120) NOT NULL,
    kapasitas_maksimal int NOT NULL
);

CREATE TABLE artist (
    nama_artist varchar(120) PRIMARY KEY,
    genre varchar(120) NOT NULL
);