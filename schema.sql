CREATE TABLE IF NOT EXISTS employees (
  id BIGSERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('manager','employee')),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS orders (
  id BIGSERIAL PRIMARY KEY, order_code TEXT NOT NULL UNIQUE, tracking_hash TEXT NOT NULL,
  student_name TEXT, print_options JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'received' CHECK (status IN ('received','processing','ready','completed','cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS order_files (
  id BIGSERIAL PRIMARY KEY, order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  original_name TEXT NOT NULL, object_path TEXT NOT NULL UNIQUE, content_type TEXT NOT NULL, byte_size BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS sales (
  id BIGSERIAL PRIMARY KEY, amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0), details TEXT NOT NULL DEFAULT '',
  employee_id BIGINT NOT NULL REFERENCES employees(id), created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS expenses (
  id BIGSERIAL PRIMARY KEY, amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0), details TEXT NOT NULL,
  employee_id BIGINT NOT NULL REFERENCES employees(id), created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS app_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
CREATE INDEX IF NOT EXISTS orders_status_created_idx ON orders(status, created_at DESC);
CREATE INDEX IF NOT EXISTS orders_tracking_hash_idx ON orders(tracking_hash);
CREATE INDEX IF NOT EXISTS sales_created_idx ON sales(created_at DESC);
CREATE INDEX IF NOT EXISTS expenses_created_idx ON expenses(created_at DESC);
