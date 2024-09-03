DROP TABLE IF EXISTS coffee_shop_sales;
CREATE TABLE coffee_shop_sales (
    transaction_id VARCHAR(50) PRIMARY KEY,
    transaction_date DATE NOT NULL,
    transaction_time TIME NOT NULL,
    transaction_qty INT NOT NULL,
    store_id VARCHAR(50) NOT NULL,
    store_location VARCHAR(100),
    product_id VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    product_category VARCHAR(50),
    product_type VARCHAR(50),
    product_detail TEXT
);