-- 1. DATABASE CREATION
-- Create a new database for sales analytics and select it for use
CREATE DATABASE sales_analytics_db;
USE sales_analytics_db;

-- 2.TABLE CREATION & SCHEMA DESIGN
-- Table 1: Customers information
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    city VARCHAR(80),
    signup_date DATE
);


-- Table 2: Products inventory details
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL
);


-- Table 3: Orders placed by customers with foreign key constraint
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE,
    status VARCHAR(30),
    total_amount DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


-- Table 4:  Line items for each order referencing orders and products
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- Table 5 : Payments records linked to specific orders
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE,
    amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(30),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


-- 3. DATA INSERTION(CRUD: Create/Insert)

-- Inserting sample records into customers table
INSERT INTO customers (customer_id, name, email, city, signup_date) VALUES
(1, 'Aarti Morya', 'aarti@gmail.com', 'Delhi', '2026-01-10'),
(2, 'Rahul Sharma', 'rahul@gmail.com', 'Noida', '2026-02-15'),
(3, 'Priya Singh', 'priya@gmail.com', 'Gurugram', '2026-03-01'),
(4, 'Amit Kumar', 'amit@gmail.com', 'Delhi', '2026-03-20'),
(5, 'Neha Verma', 'neha@gmail.com', 'Mumbai', '2026-04-05'),
(6, 'Rohit Gupta', 'rohit@gmail.com', 'Bangalore', '2026-04-12'),
(7, 'Sneha Patel', 'sneha@gmail.com', 'Pune', '2026-05-01');


-- Inserting sample records into products table
INSERT INTO products (product_id, product_name, category, price, stock) VALUES
(101, 'Laptop', 'Electronics', 55000.00, 15),
(102, 'Smartphone', 'Electronics', 25000.00, 30),
(103, 'Headphones', 'Accessories', 2000.00, 100),
(104, 'Office Chair', 'Furniture', 7500.00, 20),
(105, 'Smart Watch', 'Electronics', 4000.00, 50),
(106, 'Running Shoes', 'Footwear', 3000.00, 40),
(107, 'Backpack', 'Accessories', 1500.00, 60);

-- Inserting sample records into orders table
INSERT INTO orders (order_id, customer_id, order_date, status, total_amount) VALUES
(1001, 1, '2026-04-05', 'COMPLETED', 57000.00),
(1002, 2, '2026-04-10', 'COMPLETED', 25000.00),
(1003, 1, '2026-05-02', 'COMPLETED', 7500.00),
(1004, 3, '2026-05-12', 'COMPLETED', 2000.00),
(1005, 4, '2026-06-01', 'COMPLETED', 4000.00),
(1006, 5, '2026-06-15', 'PENDING', 3000.00),
(1007, 6, '2026-06-20', 'COMPLETED', 1500.00);


-- Inserting sample records into orders_items table
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 101, 1, 55000.00),
(2, 1001, 103, 1, 2000.00),
(3, 1002, 102, 1, 25000.00),
(4, 1003, 104, 1, 7500.00),
(5, 1004, 103, 1, 2000.00),
(6, 1005, 105, 1, 4000.00),
(7, 1006, 106, 1, 3000.00),
(8, 1007, 107, 1, 1500.00);


-- Inserting sample records into payments table
INSERT INTO payments (payment_id, order_id, payment_date, amount, payment_status) VALUES
(501, 1001, '2026-04-05', 57000.00, 'SUCCESS'),
(502, 1002, '2026-04-10', 25000.00, 'SUCCESS'),
(503, 1003, '2026-05-02', 7500.00, 'SUCCESS'),
(504, 1004, '2026-05-12', 2000.00, 'SUCCESS'),
(505, 1005, '2026-06-01', 4000.00, 'SUCCESS'),
(506, 1006, '2026-06-15', 3000.00, 'PENDING'),
(507, 1007, '2026-06-20', 1500.00, 'SUCCESS');


-- 4.JOINS & BASIC ANALYTICS
-- INNER JOIN to fetch customer details along with their orders
SELECT 
    c.name, 
    o.order_id, 
    o.order_date, 
    o.total_amount, 
    o.status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;


-- 5. ADVANCED ANALYTICS & WINDOW FUNCTIONS
-- Rank customers based on their total spending using DENSE_RANK/RANK window function
SELECT 
    customer_id,
    SUM(total_amount) AS revenue,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank
FROM orders
WHERE status = 'COMPLETED'
GROUP BY customer_id;

 -- 6. VIEWS & AGGREGATIONS (Includes COUNT)
 -- Creating a reusable view for monthly sales summary using SUM and COUNT aggregations
CREATE VIEW monthly_sales_summary AS
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'COMPLETED'
GROUP BY 1, 2;



-- Query the created view
SELECT * FROM monthly_sales_summary;

-- Top Products Analysis using aggregate functions and sorting
SELECT p.product_name, 
SUM(oi.quantity) AS units_sold,
SUM(oi.quantity * oi.unit_price) AS revenue 
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id 
GROUP BY p.product_name
ORDER BY revenue DESC 
LIMIT 10;



-- 7. PERFORMANCE INDEXING & QUERY OPTIMIZATION
-- Creating indexes to improve query search performance on frequently filtered columns
CREATE INDEX idx_order_date ON orders(order_date);

-- DROP INDEX idx_order_date ON orders;

-- Analyze the execution plan of a query to see how MySQL executes the search efficiently
EXPLAIN SELECT * FROM orders WHERE status = 'COMPLETED';
