CREATE TABLE dim_product (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    dosage_form VARCHAR(50) NOT NULL,
    strength VARCHAR(50),
    manufacturer VARCHAR(150) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT uq_product_name_manufacturer
        UNIQUE (product_name, manufacturer)
)

CREATE TABLE dim_supplier (
    supplier_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL UNIQUE,
    lead_time_days INTEGER NOT NULL CHECK (lead_time_days >= 0),
    minimum_order_qty INTEGER NOT NULL CHECK (minimum_order_qty > 0),
    supplier_rating NUMERIC(3, 2)
        CHECK (supplier_rating >= 0 AND supplier_rating <= 5)
);

CREATE TABLE dim_region (
    region_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'India',
    CONSTRAINT uq_region
        UNIQUE (region_name, state, country)
);

CREATE TABLE dim_date (
    date_id INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter INTEGER NOT NULL,
    year INTEGER NOT NULL,
    week INTEGER NOT NULL,
    CONSTRAINT chk_month
        CHECK (month BETWEEN 1 AND 12),
    CONSTRAINT chk_quarter
        CHECK (quarter BETWEEN 1 AND 4),
    CONSTRAINT chk_day
        CHECK (day BETWEEN 1 AND 31),
    CONSTRAINT chk_week
        CHECK (week BETWEEN 1 AND 53)
);

CREATE TABLE dim_customer (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_type VARCHAR(50) NOT NULL,
    age_group VARCHAR(30),
    gender VARCHAR(20),
    region_id INTEGER NOT NULL,
    CONSTRAINT fk_customer_region
        FOREIGN KEY (region_id)
        REFERENCES dim_region(region_id)
);

CREATE TABLE fact_sales (
    sale_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    supplier_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    customer_id INTEGER,
    quantity_sold INTEGER NOT NULL
        CHECK (quantity_sold > 0),
    unit_price NUMERIC(10, 2) NOT NULL
        CHECK (unit_price >= 0),
    revenue NUMERIC(14, 2) NOT NULL
        CHECK (revenue >= 0),
    CONSTRAINT fk_sales_date
        FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id),
    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_id)
        REFERENCES dim_product(product_id),
    CONSTRAINT fk_sales_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES dim_supplier(supplier_id),
    CONSTRAINT fk_sales_region
        FOREIGN KEY (region_id)
        REFERENCES dim_region(region_id),
    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_id)
        REFERENCES dim_customer(customer_id)
);

CREATE TABLE fact_inventory (
    inventory_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    stock_quantity INTEGER NOT NULL
        CHECK (stock_quantity >= 0),
    reorder_level INTEGER NOT NULL
        CHECK (reorder_level >= 0),
    CONSTRAINT fk_inventory_date
        FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id),
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES dim_product(product_id)
);

CREATE INDEX idx_sales_date
    ON fact_sales(date_id);
CREATE INDEX idx_sales_product
    ON fact_sales(product_id);
CREATE INDEX idx_sales_region
    ON fact_sales(region_id);
CREATE INDEX idx_inventory_date
    ON fact_inventory(date_id);
CREATE INDEX idx_inventory_product
    ON fact_inventory(product_id);