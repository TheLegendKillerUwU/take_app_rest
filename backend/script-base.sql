-- ============================================
--  HotelApp - Script de Base de Datos MySQL
--  Versión 2 — incluye habitaciones y reservas
-- ============================================

CREATE DATABASE IF NOT EXISTS hotel_app
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE hotel_app;

-- 1. Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
                                        id          BIGINT AUTO_INCREMENT PRIMARY KEY,
                                        nombre      VARCHAR(100)         NOT NULL,
    correo      VARCHAR(150)         NOT NULL UNIQUE,
    contrasena  VARCHAR(255)         NOT NULL,
    rol         ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
    activo      BOOLEAN              NOT NULL DEFAULT TRUE,
    creado_en   TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

CREATE INDEX idx_usuarios_correo ON usuarios (correo);

-- 2. Tabla de habitaciones
CREATE TABLE IF NOT EXISTS habitaciones (
                                            id          BIGINT AUTO_INCREMENT PRIMARY KEY,
                                            numero      VARCHAR(10)          NOT NULL UNIQUE,
    tipo        VARCHAR(50)          NOT NULL,
    descripcion TEXT,
    precio      DECIMAL(10,2)        NOT NULL,
    imagen_url  VARCHAR(255),        -- Ruta del archivo: /uploads/habitaciones/uuid.jpg
    disponible  BOOLEAN              DEFAULT TRUE,
    creado_en   TIMESTAMP            DEFAULT CURRENT_TIMESTAMP
    );

-- 3. Tabla de reservas
CREATE TABLE IF NOT EXISTS reservas (
                                        id             BIGINT AUTO_INCREMENT PRIMARY KEY,
                                        usuario_id     BIGINT       NOT NULL,
                                        habitacion_id  BIGINT       NOT NULL,
                                        fecha_entrada  DATE         NOT NULL,
                                        fecha_salida   DATE         NOT NULL,
                                        estado         ENUM('PENDIENTE','CONFIRMADA','CANCELADA') DEFAULT 'PENDIENTE',
    total          DECIMAL(10,2) NOT NULL,
    adultos        INT           NOT NULL DEFAULT 1,
    ninos          INT           NOT NULL DEFAULT 0,
    creado_en      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id)    REFERENCES usuarios(id),
    FOREIGN KEY (habitacion_id) REFERENCES habitaciones(id)
    );

-- ── Datos de prueba ────────────────────────────────────────────────────────

-- Usuario admin de prueba (contraseña: admin123 — hasheada con BCrypt)
-- IMPORTANTE: en producción crea el admin desde la app, no hardcodeado aquí
INSERT IGNORE INTO usuarios (nombre, correo, contrasena, rol)
VALUES ('Administrador', 'admin@hotelapp.com',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHHG',
        'ADMIN');

-- Habitaciones de ejemplo
INSERT IGNORE INTO habitaciones (numero, tipo, descripcion, precio, disponible) VALUES
('101', 'Sencilla',       'Habitación individual con vista al jardín, cama matrimonial.',     800.00,  TRUE),
('102', 'Doble',          'Habitación doble con dos camas individuales y baño privado.',      1200.00, TRUE),
('201', 'Suite Ejecutiva','Suite con sala de estar, escritorio y vista panorámica.',          3100.00, TRUE),
('202', 'Suite Familiar', 'Suite amplia con dos recámaras, ideal para familias.',             3800.00, TRUE),
('301', 'Penthouse',      'Piso completo con terraza privada y jacuzzi.',                     6500.00, TRUE);