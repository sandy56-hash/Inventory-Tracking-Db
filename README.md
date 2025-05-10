**Inventory Tracking System - MySQL Database**
**📌 Project Title**
**Inventory Tracking System**

**📝 Description**
## This project is a complete MySQL database for managing inventory, suppliers, products, warehouses, and sales/purchase orders. It provides:
✅ Product Management – Track SKUs, categories, suppliers, stock levels
✅ Warehouse & Location Tracking – Manage multiple storage locations
✅ Purchase & Sales Orders – Record supplier orders and customer sales
✅ Inventory Movements – Log stock adjustments, transfers, and audits
✅ User & Role Management – Control system access

## Designed for small to medium businesses, this database ensures accurate stock tracking and reporting.

**⚙️ Setup & Installation**
**Prerequisites**
✔ MySQL Server (8.0+) installed
✔ MySQL Workbench (recommended) or command-line access

## 1. Create the Database
Run the following in MySQL:

CREATE DATABASE inventory_tracking_system;
USE inventory_tracking_system;

## 2. Import the SQL Schema
## Option A: Using MySQL Workbench

Open MySQL Workbench and connect to your server.

Click File > Open SQL Script and select the inventory_tracking_system.sql file.

Click the lightning bolt (⚡) icon to execute.

## Option B: Command Line
mysql -u [username] -p inventory_tracking_system < inventory_tracking_system.sql

## 3. Verify Setup
Check if tables were created successfully:

SHOW TABLES;
## 4. (Optional) Insert Sample Data
Run sample INSERT statements to populate the database with test records.

**🚀 How to Use**
## Once imported, you can:
## 🔹 Add Products & Suppliers

INSERT INTO suppliers (supplier_name, email, phone) 
VALUES ('TechParts Inc', 'contact@techparts.com', '1234567890');

INSERT INTO products (sku, product_name, supplier_id, unit_price) 
VALUES ('LPT-100', 'Laptop', 1, 899.99);
## 🔹 Track Inventory Movements

INSERT INTO inventory_movements (product_id, quantity, movement_type) 
VALUES (1, 10, 'Purchase');

## 🔹 Generate Reports

-- Low stock alert
SELECT product_name, quantity_in_stock 
FROM products 
WHERE quantity_in_stock < reorder_level;
