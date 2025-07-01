-- Crear esquema principal
CREATE SCHEMA empresa;

-- Tabla de empleados
CREATE TABLE empresa.empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    departamento VARCHAR(50) NOT NULL,
    salario NUMERIC(10,2) NOT NULL
);

-- Tabla de ventas
CREATE TABLE empresa.ventas (
    id SERIAL PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    monto NUMERIC(10,2) NOT NULL,
    comision NUMERIC(10,2)  -- Columna sensible
);

-- Insertar datos de prueba
INSERT INTO empresa.empleados (nombre, departamento, salario) VALUES
('Juan Pérez', 'Ventas', 3000.00),
('María Gómez', 'Marketing', 3200.00),
('Carlos Ruiz', 'TI', 4000.00);

INSERT INTO empresa.ventas (cliente, monto, comision) VALUES
('Cliente A', 15000.00, 750.00),
('Cliente B', 25000.00, 1250.00),
('Cliente C', 10000.00, 500.00);




-- ========== DEFINICION DE ROLES, VISTAS Y PERMISOS =============
-- NOTA: se cambio a editor2, admin2,consultor2 por que se olvido dar permisos a rol de grupo
-- y al intentar eliminar los usuarios del cluster da error porque al eliminar
-- no deja porque el usuario depende de otras tablas
-- Could not drop the role. privilegios para base de datos practica2 4 objetos en base de datos practica2no se puede eliminar el rol «admin» porque otros objetos dependen de él

-- 1. Crea estos 3 roles:
--    - admin (jefe total)
--    - editor (puede editar cosas)
--    - consultor (solo mira)
CREATE ROLE admin2;
CREATE ROLE editor2;
CREATE ROLE consultor2;
-- Asignar el privilegio de conectarse a un rol
GRANT CONNECT ON DATABASE practica2 TO admin2,editor2,consultor2;
GRANT USAGE ON SCHEMA empresa TO admin2,editor2,consultor2; 

-- 2. Crea usuarios con contraseñas:
--    - usuario_admin / admin123
--    - usuario_editor / editor123
--    - usuario_consultor / consultor123
CREATE ROLE usuario_admin LOGIN PASSWORD '1234';
CREATE ROLE usuario_editor LOGIN PASSWORD '1234';
CREATE ROLE usuario_consultor LOGIN PASSWORD '1234';

-- Dar rol de grupo a los usuarios de login
GRANT admin2 TO usuario_admin;
GRANT editor2 TO usuario_editor;
GRANT consultor2 TO usuario_consultor;

-- 3. Bloquea el acceso público al esquema "empresa"
 REVOKE ALL ON SCHEMA empresa FROM PUBLIC;


-- 4. Crea una VISTA llamada "v_ventas_publicas" que muestre:
--    id, cliente, monto ( NO MUESTRA la columna "comision")
CREATE OR REPLACE VIEW empresa.v_ventas_publicas AS
    SELECT id, cliente, monto
    FROM empresa.ventas;

SELECT * FROM empresa.v_ventas_publicas;


-- 5. Asigna permisos:
--    Para ADMIN:
--      - Acceso TOTAL a todas las tablas
GRANT USAGE ON ALL SEQUENCES IN SCHEMA empresa TO admin2;
GRANT SELECT, INSERT, UPDATE, DELETE ON empresa.empleados to admin2;
GRANT SELECT, INSERT, UPDATE, DELETE ON empresa.ventas to admin2;


--
--    Para EDITOR:
--      - Ver/editar la tabla EMPLEADOS
GRANT SELECT, INSERT, UPDATE ON empresa.empleados TO editor2;
--      - Ver/editar solo la VISTA (no la tabla completa de ventas)
GRANT SELECT, INSERT, UPDATE ON empresa.v_ventas_publicas TO editor2;
--
--    Para CONSULTOR:
--      - Solo VER empleados y la vista
GRANT SELECT ON empresa.empleados TO consultor2;
GRANT SELECT ON empresa.v_ventas_publicas TO consultor2;








-- ========== PRUEBAS =============



/* Prueba ADMIN */
-- Conviértete en admin:
SET ROLE usuario_admin;

-- Verifica que puedes:
-- 1. Ver TODAS las ventas (con comisiones)
SELECT * FROM empresa.ventas;
-- 2. Cambiar el salario de Juan Pérez a 3500
UPDATE empresa.empleados SET salario=3500 WHERE nombre='Juan Perez';
-- Vuelve a ser tú:
RESET ROLE;




/* Prueba EDITOR */
-- Conviértete en editor:
SET ROLE usuario_editor;

-- Verifica que puedes:
-- 1. Ver empleados
SELECT * FROM empresa.empleados;
-- 2. Ver la VISTA de ventas (sin comisiones)
SELECT * FROM empresa.v_ventas_publicas;
-- 3. Cambiar el salario de María Gómez a 3400
UPDATE empresa.empleados SET salario=3400 WHERE nombre='María Gómez';

-- Pero NO puedes:
-- 4. Ver columna "comision" (¡error!)
SELECT comision FROM empresa.ventas;
-- 5. Eliminar empleados (¡error!)
DELETE FROM empresa.empleados WHERE nombre='Carlos Ruiz';
-- Vuelve a ser tú:
RESET ROLE;



/* Prueba CONSULTOR */
-- Conviértete en consultor:
SET ROLE usuario_consultor;

-- Verifica que puedes:
-- 1. Ver empleados
SELECT * FROM empresa.empleados;
-- 2. Ver la VISTA de ventas
SELECT * FROM empresa.v_ventas_publicas;

-- Pero NO puedes:
-- 3. Cambiar salarios (¡error!)
UPDATE empresa.empleados SET salario=9999 WHERE nombre='Juan Perez';

-- Vuelve a ser tú:
RESET ROLE;