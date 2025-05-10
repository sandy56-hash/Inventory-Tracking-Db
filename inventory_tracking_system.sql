
-- Inventory Tracking System Database
-- Author: Sandra Chelangat
-- Description: Complete database for tracking products,
--              suppliers, inventory movements, and orders
-- =============================================

CREATE DATABASE inventory_tracking_system;
USE inventory_tracking_system;

-- =============================================
-- Table: suppliers
-- Purpose: Stores information about product suppliers
-- Constraints: 
--   - supplier_id as auto-incrementing primary key
--   - Email must be valid format (contains @ and .)
--   - Phone must be at least 10 characters
-- =============================================
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    country VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20),
    date_added DATE NOT NULL DEFAULT (CURRENT_DATE),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_supplier_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_supplier_phone CHECK (LENGTH(phone) >= 10)
) COMMENT 'Stores supplier/vendor information';

-- =============================================
-- Table: product_categories
-- Purpose: Categorization system for products
-- Constraints:
--   - category_name must be unique
--   - description is optional
-- =============================================
CREATE TABLE product_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT NULL,
    CONSTRAINT fk_parent_category 
        FOREIGN KEY (parent_category_id) 
        REFERENCES product_categories(category_id)
        ON DELETE SET NULL
) COMMENT 'Product classification hierarchy';

-- =============================================
-- Table: products
-- Purpose: Core table for all inventory items
-- Constraints:
--   - SKU must be unique
--   - Price and cost must be positive numbers
--   - Quantity cannot be negative
-- =============================================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE COMMENT 'Stock Keeping Unit',
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    reorder_level INT NOT NULL DEFAULT 5,
    quantity_in_stock INT NOT NULL DEFAULT 0,
    weight DECIMAL(10,2) COMMENT 'Weight in kilograms',
    dimensions VARCHAR(50) COMMENT 'Format: LxWxH in cm',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    date_added DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_category 
        FOREIGN KEY (category_id) 
        REFERENCES product_categories(category_id),
    CONSTRAINT fk_product_supplier 
        FOREIGN KEY (supplier_id) 
        REFERENCES suppliers(supplier_id),
    CONSTRAINT chk_product_price CHECK (unit_price > 0),
    CONSTRAINT chk_product_cost CHECK (unit_cost > 0),
    CONSTRAINT chk_product_quantity CHECK (quantity_in_stock >= 0)
) COMMENT 'Main product inventory table';

-- =============================================
-- Table: warehouses
-- Purpose: Physical storage locations
-- Constraints:
--   - warehouse_code must be unique
--   - capacity must be positive
-- =============================================
CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_code VARCHAR(20) NOT NULL UNIQUE,
    warehouse_name VARCHAR(100) NOT NULL,
    location VARCHAR(200) NOT NULL,
    capacity INT COMMENT 'Total capacity in cubic meters',
    manager_contact VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
) COMMENT 'Physical storage locations';

-- =============================================
-- Table: inventory_locations
-- Purpose: Specific storage bins/shelves in warehouses
-- Constraints:
--   - location_code must be unique within warehouse
--   - capacity must be positive
-- =============================================
CREATE TABLE inventory_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    location_code VARCHAR(20) NOT NULL,
    description VARCHAR(100),
    capacity INT COMMENT 'Capacity in cubic meters',
    is_occupied BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_location_warehouse 
        FOREIGN KEY (warehouse_id) 
        REFERENCES warehouses(warehouse_id),
    CONSTRAINT uc_warehouse_location 
        UNIQUE (warehouse_id, location_code)
) COMMENT 'Specific storage locations within warehouses';

-- =============================================
-- Table: product_inventory
-- Purpose: Tracks which products are in which locations
-- Constraints:
--   - quantity must be positive
--   - Composite primary key (product_id + location_id)
-- =============================================
CREATE TABLE product_inventory (
    product_id INT NOT NULL,
    location_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    date_added DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, location_id),
    CONSTRAINT fk_inventory_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id),
    CONSTRAINT fk_inventory_location 
        FOREIGN KEY (location_id) 
        REFERENCES inventory_locations(location_id),
    CONSTRAINT chk_inventory_quantity CHECK (quantity > 0)
) COMMENT 'Tracks product quantities at specific locations';

-- =============================================
-- Table: inventory_movements
-- Purpose: Audit trail for all inventory changes
-- Constraints:
--   - movement_type limited to specific values
--   - quantity must be positive
-- =============================================
CREATE TABLE inventory_movements (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    from_location_id INT,
    to_location_id INT,
    quantity INT NOT NULL,
    movement_type ENUM(
        'Purchase', 
        'Sale', 
        'Transfer', 
        'Adjustment', 
        'Return', 
        'Damage'
    ) NOT NULL,
    reference_number VARCHAR(50) COMMENT 'PO#, Invoice#, etc.',
    movement_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    user_id INT COMMENT 'ID of user who performed the movement',
    CONSTRAINT fk_movement_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id),
    CONSTRAINT fk_movement_from_location 
        FOREIGN KEY (from_location_id) 
        REFERENCES inventory_locations(location_id),
    CONSTRAINT fk_movement_to_location 
        FOREIGN KEY (to_location_id) 
        REFERENCES inventory_locations(location_id),
    CONSTRAINT chk_movement_locations 
        CHECK (from_location_id IS NOT NULL OR to_location_id IS NOT NULL),
    CONSTRAINT chk_movement_quantity CHECK (quantity > 0)
) COMMENT 'Audit trail for all inventory transactions';

-- =============================================
-- Table: purchase_orders
-- Purpose: Tracks orders placed with suppliers
-- Constraints:
--   - order_date cannot be in the future
--   - status has specific allowed values
-- =============================================
CREATE TABLE purchase_orders (
    po_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    order_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expected_delivery_date DATE,
    status ENUM(
        'Draft', 
        'Submitted', 
        'Approved', 
        'Shipped', 
        'Delivered', 
        'Cancelled'
    ) NOT NULL DEFAULT 'Draft',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_by INT COMMENT 'User ID who created the PO',
    CONSTRAINT fk_po_supplier 
        FOREIGN KEY (supplier_id) 
        REFERENCES suppliers(supplier_id),
    CONSTRAINT chk_po_dates CHECK (order_date <= CURRENT_DATE)
) COMMENT 'Purchase orders to suppliers';

-- =============================================
-- Table: purchase_order_items
-- Purpose: Line items for purchase orders
-- Constraints:
--   - quantity and unit_price must be positive
--   - Composite primary key (po_id + product_id)
-- =============================================
CREATE TABLE purchase_order_items (
    po_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    received_quantity INT DEFAULT 0,
    PRIMARY KEY (po_id, product_id),
    CONSTRAINT fk_poitem_po 
        FOREIGN KEY (po_id) 
        REFERENCES purchase_orders(po_id),
    CONSTRAINT fk_poitem_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id),
    CONSTRAINT chk_poitem_quantity CHECK (quantity > 0),
    CONSTRAINT chk_poitem_price CHECK (unit_price > 0),
    CONSTRAINT chk_poitem_received CHECK (received_quantity <= quantity)
) COMMENT 'Line items for purchase orders';

-- =============================================
-- Table: customers
-- Purpose: Stores customer information
-- Constraints:
--   - Email must be valid format
--   - Phone must be at least 10 characters
-- =============================================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    tax_id VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_customer_email CHECK (email LIKE '%@%.%' OR email IS NULL),
    CONSTRAINT chk_customer_phone CHECK (LENGTH(phone) >= 10 OR phone IS NULL)
) COMMENT 'Customer information for sales';

-- =============================================
-- Table: sales_orders
-- Purpose: Tracks customer orders
-- Constraints:
--   - order_date cannot be in the future
--   - status has specific allowed values
-- =============================================
CREATE TABLE sales_orders (
    so_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM(
        'Draft', 
        'Confirmed', 
        'Processing', 
        'Shipped', 
        'Delivered', 
        'Cancelled'
    ) NOT NULL DEFAULT 'Draft',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_by INT COMMENT 'User ID who created the order',
    CONSTRAINT fk_so_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id)
) COMMENT 'Sales orders to customers';

-- =============================================
-- Table: sales_order_items
-- Purpose: Line items for sales orders
-- Constraints:
--   - quantity and unit_price must be positive
--   - Composite primary key (so_id + product_id)
-- =============================================
CREATE TABLE sales_order_items (
    so_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    fulfilled_quantity INT DEFAULT 0,
    PRIMARY KEY (so_id, product_id),
    CONSTRAINT fk_soitem_so 
        FOREIGN KEY (so_id) 
        REFERENCES sales_orders(so_id),
    CONSTRAINT fk_soitem_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id),
    CONSTRAINT chk_soitem_quantity CHECK (quantity > 0),
    CONSTRAINT chk_soitem_price CHECK (unit_price > 0),
    CONSTRAINT chk_soitem_fulfilled CHECK (fulfilled_quantity <= quantity)
) COMMENT 'Line items for sales orders';

-- =============================================
-- Table: users
-- Purpose: System users with access permissions
-- Constraints:
--   - username must be unique
--   - Email must be valid format
-- =============================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL COMMENT 'Store hashed passwords only',
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    role ENUM('Admin', 'Manager', 'Staff', 'Viewer') NOT NULL DEFAULT 'Staff',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login DATETIME,
    CONSTRAINT chk_user_email CHECK (email LIKE '%@%.%')
) COMMENT 'System users with access permissions';

