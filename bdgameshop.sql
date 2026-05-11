-- =============================================================
--  Base de datos: bdgameshop
--  Sistema de gestión para tienda de videojuegos
--  Generado: 2026
-- =============================================================

CREATE DATABASE IF NOT EXISTS bdgameshop
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bdgameshop;

-- =============================================================
-- 1. CATEGORIA
-- =============================================================
CREATE TABLE categoria (
    id_categoria    INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(80)     NOT NULL,
    descripcion     TEXT,
    CONSTRAINT pk_categoria     PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nom UNIQUE (nombre)
);

-- =============================================================
-- 2. PROVEEDOR
-- =============================================================
CREATE TABLE proveedor (
    id_proveedor    INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(120)    NOT NULL,
    contacto        VARCHAR(100),
    email           VARCHAR(150),
    telefono        VARCHAR(20),
    pais            VARCHAR(60),
    CONSTRAINT pk_proveedor     PRIMARY KEY (id_proveedor),
    CONSTRAINT uq_proveedor_nom UNIQUE (nombre)
);

-- =============================================================
-- 3. EMPLEADO
-- =============================================================
CREATE TABLE empleado (
    id_empleado     INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)    NOT NULL,
    cargo           VARCHAR(80)     NOT NULL,
    email           VARCHAR(150)    NOT NULL,
    telefono        VARCHAR(20),
    fecha_ingreso   DATE            NOT NULL,
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_empleado      PRIMARY KEY (id_empleado),
    CONSTRAINT uq_empleado_mail UNIQUE (email)
);

-- =============================================================
-- 4. CLIENTE
-- =============================================================
CREATE TABLE cliente (
    id_cliente      INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)    NOT NULL,
    email           VARCHAR(150)    NOT NULL,
    telefono        VARCHAR(20),
    direccion       VARCHAR(255),
    fecha_registro  DATE            NOT NULL DEFAULT (CURRENT_DATE),
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_cliente       PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_mail  UNIQUE (email)
);

-- =============================================================
-- 5. PRODUCTO
-- =============================================================
CREATE TABLE producto (
    id_producto     INT             NOT NULL AUTO_INCREMENT,
    id_categoria    INT             NOT NULL,
    id_proveedor    INT             NOT NULL,
    titulo          VARCHAR(150)    NOT NULL,
    plataforma      VARCHAR(50)     NOT NULL,
    precio          DECIMAL(10,2)   NOT NULL CHECK (precio >= 0),
    precio_costo    DECIMAL(10,2)   NOT NULL CHECK (precio_costo >= 0),
    stock           INT             NOT NULL DEFAULT 0 CHECK (stock >= 0),
    descripcion     TEXT,
    clasificacion   VARCHAR(10),
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_producto          PRIMARY KEY (id_producto),
    CONSTRAINT fk_producto_cat      FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_producto_prov     FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =============================================================
-- 6. INVENTARIO  (bitácora de movimientos de stock)
-- =============================================================
CREATE TABLE inventario (
    id_inventario       INT             NOT NULL AUTO_INCREMENT,
    id_producto         INT             NOT NULL,
    id_empleado         INT             NOT NULL,
    tipo_movimiento     VARCHAR(20)     NOT NULL,
    cantidad            INT             NOT NULL,
    stock_resultante    INT             NOT NULL CHECK (stock_resultante >= 0),
    fecha               DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacion         TEXT,
    CONSTRAINT pk_inventario        PRIMARY KEY (id_inventario),
    CONSTRAINT chk_inv_tipo         CHECK (tipo_movimiento IN ('Entrada','Salida','Ajuste')),
    CONSTRAINT fk_inv_producto      FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_inv_empleado      FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =============================================================
-- 7. PEDIDO
-- =============================================================
CREATE TABLE pedido (
    id_pedido       INT             NOT NULL AUTO_INCREMENT,
    id_cliente      INT             NOT NULL,
    id_empleado     INT             NOT NULL,
    fecha           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          VARCHAR(30)     NOT NULL DEFAULT 'Pendiente',
    total           DECIMAL(10,2)   NOT NULL DEFAULT 0.00 CHECK (total >= 0),
    direccion_envio VARCHAR(255),
    notas           TEXT,
    CONSTRAINT pk_pedido            PRIMARY KEY (id_pedido),
    CONSTRAINT chk_pedido_estado    CHECK (estado IN ('Pendiente','Procesando','Enviado','Entregado','Cancelado')),
    CONSTRAINT fk_pedido_cliente    FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_empleado   FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =============================================================
-- 8. DETALLE_PEDIDO
-- =============================================================
CREATE TABLE detalle_pedido (
    id_detalle          INT             NOT NULL AUTO_INCREMENT,
    id_pedido           INT             NOT NULL,
    id_producto         INT             NOT NULL,
    cantidad            INT             NOT NULL CHECK (cantidad > 0),
    precio_unitario     DECIMAL(10,2)   NOT NULL CHECK (precio_unitario >= 0),
    subtotal            DECIMAL(10,2)   GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    CONSTRAINT pk_detalle           PRIMARY KEY (id_detalle),
    CONSTRAINT uq_detalle           UNIQUE (id_pedido, id_producto),
    CONSTRAINT fk_det_pedido        FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_det_producto      FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =============================================================
-- 9. PAGO
-- =============================================================
CREATE TABLE pago (
    id_pago         INT             NOT NULL AUTO_INCREMENT,
    id_pedido       INT             NOT NULL,
    metodo          VARCHAR(50)     NOT NULL,
    monto           DECIMAL(10,2)   NOT NULL CHECK (monto > 0),
    fecha           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    referencia      VARCHAR(100),
    estado          VARCHAR(30)     NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT pk_pago              PRIMARY KEY (id_pago),
    CONSTRAINT chk_pago_metodo      CHECK (metodo IN ('Efectivo','Tarjeta de crédito','Tarjeta de débito','Transferencia','Vale de regalo')),
    CONSTRAINT chk_pago_estado      CHECK (estado IN ('Pendiente','Aprobado','Rechazado','Reembolsado')),
    CONSTRAINT fk_pago_pedido       FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =============================================================
-- 10. DEVOLUCION
-- =============================================================
CREATE TABLE devolucion (
    id_devolucion   INT             NOT NULL AUTO_INCREMENT,
    id_pedido       INT             NOT NULL,
    id_producto     INT             NOT NULL,
    id_empleado     INT             NOT NULL,
    cantidad        INT             NOT NULL CHECK (cantidad > 0),
    motivo          VARCHAR(255)    NOT NULL,
    fecha           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          VARCHAR(30)     NOT NULL DEFAULT 'Solicitada',
    monto_reembolso DECIMAL(10,2)   NOT NULL CHECK (monto_reembolso >= 0),
    CONSTRAINT pk_devolucion        PRIMARY KEY (id_devolucion),
    CONSTRAINT chk_dev_estado       CHECK (estado IN ('Solicitada','Aprobada','Rechazada','Reembolsada')),
    CONSTRAINT fk_dev_pedido        FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_dev_producto      FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_dev_empleado      FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =============================================================
-- ÍNDICES adicionales para consultas frecuentes
-- =============================================================
CREATE INDEX idx_producto_plataforma    ON producto (plataforma);
CREATE INDEX idx_producto_activo        ON producto (activo);
CREATE INDEX idx_pedido_fecha           ON pedido (fecha);
CREATE INDEX idx_pedido_estado          ON pedido (estado);
CREATE INDEX idx_pago_estado            ON pago (estado);
CREATE INDEX idx_inventario_producto    ON inventario (id_producto, fecha);
CREATE INDEX idx_detalle_producto       ON detalle_pedido (id_producto);

-- =============================================================
-- DATOS DE EJEMPLO (seed)
-- =============================================================

INSERT INTO categoria (nombre, descripcion) VALUES
  ('Acción',      'Juegos de combate y aventura en tiempo real'),
  ('RPG',         'Juegos de rol con progresión de personaje'),
  ('Deportes',    'Simuladores de fútbol, baloncesto, carreras'),
  ('Estrategia',  'Juegos de planificación y gestión de recursos'),
  ('Aventura',    'Exploración, puzzles y narrativa'),
  ('Shooter',     'Juegos de disparos en primera o tercera persona');

INSERT INTO proveedor (nombre, contacto, email, telefono, pais) VALUES
  ('Nintendo de México',  'Ana Torres',   'ventas@nintendo.mx',   '55-1234-5678', 'México'),
  ('Sony PlayStation',    'Luis Méndez',  'b2b@playstation.com',  '55-9876-5432', 'México'),
  ('Microsoft Xbox',      'Karla Ríos',   'retail@xbox.com',      '55-5555-0101', 'México'),
  ('Distribuidora Pixel', 'Jorge Soto',   'pixel@dist.mx',        '614-333-2211', 'México');

INSERT INTO empleado (nombre, cargo, email, telefono, fecha_ingreso) VALUES
  ('Carlos Morales',  'Gerente',    'carlos@gameshop.mx',  '614-100-0001', '2020-03-15'),
  ('Diana Flores',    'Cajera',     'diana@gameshop.mx',   '614-100-0002', '2021-06-01'),
  ('Erick Salinas',   'Almacenista','erick@gameshop.mx',   '614-100-0003', '2022-01-10');

INSERT INTO cliente (nombre, email, telefono, direccion, fecha_registro) VALUES
  ('Mario García',    'mario.garcia@mail.com',    '614-201-0011', 'Av. Juárez 100, Juárez, Chih.',  '2024-01-15'),
  ('Sofía Ramírez',   'sofia.ram@mail.com',       '614-201-0022', 'Calle Lerdo 45, Juárez, Chih.',  '2024-03-08'),
  ('Pedro Lara',      'pedro.lara@mail.com',      '614-201-0033', 'Blvd. Díaz 220, Juárez, Chih.',  '2025-07-20');

INSERT INTO producto (id_categoria, id_proveedor, titulo, plataforma, precio, precio_costo, stock, descripcion, clasificacion) VALUES
  (1, 2, 'God of War Ragnarök',         'PS5',   1299.00,  850.00, 15, 'Aventura épica nórdica',           'M'),
  (2, 1, 'The Legend of Zelda: TotK',   'Switch',1199.00,  780.00, 20, 'Aventura de mundo abierto',        'E10+'),
  (3, 2, 'EA Sports FC 25',             'PS5',    999.00,  620.00, 30, 'Simulador de fútbol 2025',         'E'),
  (6, 3, 'Halo Infinite',               'Xbox',   799.00,  500.00, 18, 'FPS multijugador competitivo',     'T'),
  (4, 4, 'Civilization VII',            'PC',     899.00,  570.00, 12, 'Estrategia por turnos 4X',         'T'),
  (5, 1, 'Super Mario Bros. Wonder',    'Switch', 999.00,  650.00, 25, 'Plataformas 2D innovador',         'E');

INSERT INTO pedido (id_cliente, id_empleado, estado, total, direccion_envio) VALUES
  (1, 2, 'Entregado', 2298.00, 'Av. Juárez 100, Juárez, Chih.'),
  (2, 2, 'Enviado',   1199.00, 'Calle Lerdo 45, Juárez, Chih.'),
  (3, 2, 'Pendiente', 1798.00, 'Blvd. Díaz 220, Juárez, Chih.');

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
  (1, 1, 1, 1299.00),
  (1, 3, 1,  999.00),
  (2, 2, 1, 1199.00),
  (3, 4, 1,  799.00),
  (3, 6, 1,  999.00);

INSERT INTO pago (id_pedido, metodo, monto, estado, referencia) VALUES
  (1, 'Tarjeta de crédito', 2298.00, 'Aprobado',  'TXN-2025-001'),
  (2, 'Efectivo',           1199.00, 'Aprobado',  NULL),
  (3, 'Transferencia',      1798.00, 'Pendiente', 'REF-2025-099');

INSERT INTO inventario (id_producto, id_empleado, tipo_movimiento, cantidad, stock_resultante, observacion) VALUES
  (1, 3, 'Entrada',  20, 20, 'Compra inicial a Sony'),
  (2, 3, 'Entrada',  25, 25, 'Compra inicial a Nintendo'),
  (3, 3, 'Entrada',  35, 35, 'Compra inicial a Sony'),
  (4, 3, 'Entrada',  20, 20, 'Compra inicial a Microsoft'),
  (5, 3, 'Entrada',  15, 15, 'Compra inicial a Distribuidora Pixel'),
  (6, 3, 'Entrada',  28, 28, 'Compra inicial a Nintendo'),
  (1, 3, 'Salida',    5, 15, 'Ventas de la semana'),
  (3, 3, 'Salida',    5, 30, 'Ventas de la semana');

-- =============================================================
-- FIN DEL SCRIPT  bdgameshop.sql
-- =============================================================
