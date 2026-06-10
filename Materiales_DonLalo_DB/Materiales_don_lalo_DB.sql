-- SCRIPT SQL PARA CREACIÓN DE BASE DE DATOS 'MATERIALES_DON_LALO'

-- 1. CONFIGURACIÓN - BASE DE DATOS
---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS materiales_don_lalo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE materiales_don_lalo;

-- Desactiva temporalmente revisión de claves foráneas para poder eliminar y crear tablas en cualquier orden
SET FOREIGN_KEY_CHECKS = 0;

-- 2. ELIMINACIÓN DE TABLAS
---------------------------------------------------------------------
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Info_Sale;
DROP TABLE IF EXISTS Info_Purchase;
DROP TABLE IF EXISTS Movement;
DROP TABLE IF EXISTS Sale;
DROP TABLE IF EXISTS Purchase;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Supplier;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS User;

-- 3. CREACIÓN DE TABLAS BASE (sin FK)
---------------------------------------------------------------------

-- TABLA: Usuarios (personal de Don Lalo)
CREATE TABLE User (
    ID_user INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    rol VARCHAR(50),
    hire_date DATE,
    phone VARCHAR(20),
    mail VARCHAR(100) UNIQUE,
    password VARCHAR(50) NOT NULL
);

-- TABLA: Direcciones (Domicilios de clientes)
CREATE TABLE Address (
    ID_address INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(100) NOT NULL,
    number VARCHAR(10),
    neighbourhood VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10)
);

-- TABLA: Categorias (Clasificación de productos)
CREATE TABLE Category (
    ID_category INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- TABLA: Proveedores (Empresas o personas a quienes se les compra material)
CREATE TABLE Supplier (
    ID_supplier INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    country VARCHAR(50),
    phone VARCHAR(20),
    mail VARCHAR(100) UNIQUE
);

-- 4. CREACIÓN DE TABLAS INTERMEDIAS (Con FK)
---------------------------------------------------------------------

-- TABLA: Clientes (Compradores en Don Lalo)
CREATE TABLE Customer (
    ID_customer INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    mail VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    password VARCHAR(50),
    
    -- FK a Direcciones: Dirección principal del cliente
    ID_address INT,
    FOREIGN KEY (ID_address) REFERENCES Address(ID_address)
);

-- TABLA: Productos (Inventario de los materiales)
CREATE TABLE Product (
    ID_product INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    unit_measure VARCHAR(25),
    
    -- FK a Categorias: Clasificación del producto
    ID_category INT NOT NULL,
    FOREIGN KEY (ID_category) REFERENCES Category(ID_category)
);

-- 5. CREACIÓN DE TABLAS DE TRANSACCIÓN (Encabezado)
---------------------------------------------------------------------

-- TABLA: Ventas (Registro de transacciones de venta)
CREATE TABLE Sale (
    ID_sale INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    status VARCHAR(50),
    total DECIMAL(10, 2) NOT NULL,
    
    -- FK a Clientes: Quién compró
    ID_customer INT NOT NULL,
    -- A CONSIDERAR: User que realizó la venta
    ID_user INT, 
    
    FOREIGN KEY (ID_customer) REFERENCES Customer(ID_customer),
    FOREIGN KEY (ID_user) REFERENCES User(ID_user)
);

-- TABLA: Compras (Registro de compra de materiales a proveedores)
CREATE TABLE Purchase (
    ID_purchase INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    status VARCHAR(50),
    total DECIMAL(10, 2) NOT NULL,
    
    -- FK a Proveedores: A quién se compró
    ID_supplier INT NOT NULL,
    -- A CONSIDERAR: User que realizó la compra
    ID_user INT, 

    FOREIGN KEY (ID_supplier) REFERENCES Supplier(ID_supplier),
    FOREIGN KEY (ID_user) REFERENCES User(ID_user)
);

-- TABLA: Pagos (Registro de pagos en Ventas)
CREATE TABLE Payment (
    ID_payment INT AUTO_INCREMENT PRIMARY KEY,
    amount DECIMAL(10, 2) NOT NULL,
    mail VARCHAR(100), -- Correo de confirmación
    date_payment DATETIME DEFAULT CURRENT_TIMESTAMP,
    -- Si hubiera factura, aquí se pide RFC
    
    -- FK a Ventas: El pago se asocia a una venta específica
    ID_Sale INT NOT NULL,
    FOREIGN KEY (ID_sale) REFERENCES Sale(ID_sale)
);

-- 6. CREACIÓN DE TABLAS DE DETALLE (Relaciones Muchos-a-Muchos)
---------------------------------------------------------------------

-- TABLA: Detalle_Venta (Ítems en una venta)
CREATE TABLE Info_Sale (
    amount INT NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    
    
    -- FK a Ventas: A qué venta pertenece
    ID_sale INT NOT NULL,
    -- FK a Productos: Qué producto se vendió
    ID_product INT NOT NULL,
    
    FOREIGN KEY (ID_sale) REFERENCES Sale(ID_sale),
    FOREIGN KEY (ID_product) REFERENCES Product(ID_product),
    
    -- DEFINICIÓN DE LA LLAVE PRIMARIA COMPUESTA
    PRIMARY KEY (ID_sale, ID_product)
);

-- TABLA: Detalle_Compra (Ítems en una compra)
CREATE TABLE Info_Purchase (
    amount INT NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    
    -- FK a Compras: A qué compra pertenece
    ID_purchase INT NOT NULL,
    -- FK a Productos: Qué producto se compró
    ID_product INT NOT NULL,
    
    FOREIGN KEY (ID_purchase) REFERENCES Purchase(ID_purchase),
    FOREIGN KEY (ID_product) REFERENCES Product(ID_product),
    -- DEFINICIÓN DE LA LLAVE PRIMARIA COMPUESTA
    PRIMARY KEY (ID_purchase, ID_product)
);

-- TABLA: Movimientos (Trazabilidad de entradas y salidas de inventario)
CREATE TABLE Movement (
    ID_movement INT AUTO_INCREMENT PRIMARY KEY,
    tipe VARCHAR(50) NOT NULL, -- E.g., 'Entrada', 'Salida', 'Ajuste'
    reason VARCHAR(255),
    amount INT NOT NULL,
    date DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- FK a Productos: El producto afectado
    ID_product INT NOT NULL,
    
    -- FKs OPCIONALES: Vinculan el movimiento a la transacción que lo originó
    ID_sale INT NULL,
    ID_purchase INT NULL,
    
    FOREIGN KEY (ID_product) REFERENCES Product(ID_product),
    FOREIGN KEY (ID_sale) REFERENCES Sale(ID_sale),
    FOREIGN KEY (ID_purchase) REFERENCES Purchase(ID_purchase)
);

-- 7. CONFIGURACIÓN FINAL
---------------------------------------------------------------------
-- Volver a activar la revisión de claves foráneas
SET FOREIGN_KEY_CHECKS = 1;