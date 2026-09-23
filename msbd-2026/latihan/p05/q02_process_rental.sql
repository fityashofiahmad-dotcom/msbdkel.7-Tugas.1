CREATE SCHEMA IF NOT EXISTS lab5;
CREATE TYPE lab5.rental_status AS ENUM ('ACTIVE','RETURNED','CANCELLED');
CREATE DOMAIN lab5.positive_amount AS numeric(10,2) CHECK (VALUE > 0);

CREATE TABLE lab5.rental_tx (
  rental_id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id  integer NOT NULL,
  inventory_id integer NOT NULL,
  staff_id     integer NOT NULL,
  status       lab5.rental_status NOT NULL DEFAULT 'ACTIVE',
  tags         text[] NOT NULL DEFAULT '{}',
  metadata     jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE lab5.payment_tx (
  payment_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  rental_id  bigint NOT NULL REFERENCES lab5.rental_tx (rental_id),
  amount     lab5.positive_amount NOT NULL,
  paid_at    timestamptz NOT NULL DEFAULT now()
);
