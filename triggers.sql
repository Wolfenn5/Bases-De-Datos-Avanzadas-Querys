-- TABLAS DE PRUEBA --

CREATE TABLE empleados (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),
  email VARCHAR(100),
  password VARCHAR(100),
  sueldo NUMERIC(10,2)
);

CREATE TABLE log_sueldos (
  id SERIAL PRIMARY KEY,
  empleado_id INT,
  sueldo_anterior NUMERIC(10,2),
  sueldo_nuevo NUMERIC(10,2),
  fecha TIMESTAMP DEFAULT NOW()
);

CREATE TABLE proyectos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100)
);

CREATE TABLE log_proyectos_eliminados (
  id SERIAL PRIMARY KEY,
  proyecto_id INT,
  nombre_proyecto VARCHAR(100),
  fecha_eliminacion TIMESTAMP DEFAULT NOW()
);





INSERT INTO empleados(nombre, email,password,sueldo) 
    VALUES ('Homero Simpson','homero@mail.com','1234',1000);


SELECT * FROM empleados;
SELECT * FROM log_sueldos;




-- Ejemplo de trigger
-- Son basicamente funciones que regresan el tipo de dato trigger
-- NEW tiene informacion del renglon despues de un UPDATE
-- OLD tiene informacion del renglon antes de un UPDATE


-- Funcion asociada a un trigger
CREATE OR REPLACE FUNCTION actualizar_log_sueldos()
RETURNS trigger -- esto indica que es un trigger
AS $$
    BEGIN
        -- Si el sueldo cambio entonces:
        IF OLD.sueldo IS DISTINCT FROM NEW.sueldo THEN
            INSERT INTO log_sueldos(empleado_id,sueldo_anterior,sueldo_nuevo) 
            VALUES (OLD.id,OLD.sueldo,NEW.sueldo);
        END IF;
        RETURN NEW; -- en los triggers si estan asociados a un UPDATE, es obligatorio regresar la variable NEW
    END
$$ LANGUAGE plpgsql;


-- Crear un trigger
CREATE TRIGGER disparador_tabla_empleados_sueldo 
    AFTER UPDATE ON empleados -- despues de que haya un UPDATE en la tabla empleados
 -- AFTER INSERT
 -- AFTER DELETE
 -- BEFORE UPDATE
 -- BEFORE DELETE
 -- AFTER UPDATE OR INSERT ON 
    FOR EACH ROW EXECUTE FUNCTION actualizar_log_sueldos(); -- para cada renglon se debe ejecutar esta funcion



UPDATE empleados SET sueldo = sueldo*1.1;

SELECT * FROM log_sueldos;



SELECT UPPER(nombre) FROM empleados; -- muestra en mayusculas


-- Ejercicio: crear un trigger que convierta el campo nombre a mayusculas antes de insertar un nuevo empleado
-- usar BEFORE INSERT y modificar NEW.nombre

CREATE OR REPLACE FUNCTION empleado_nombre_mayuscula()
RETURNS trigger -- esto indica que es un trigger
AS $$
    BEGIN
        NEW.nombre := UPPER(NEW.nombre); -- el := es como una asignacion en postgres
        RETURN NEW; -- en los triggers si estan asociados a un UPDATE, es obligatorio regresar la variable NEW
    END
$$ LANGUAGE plpgsql;


CREATE TRIGGER disparador_nombre_empleado_mayusculas
    BEFORE INSERT ON empleados -- despues de que haya un UPDATE en la tabla empleados
    FOR EACH ROW EXECUTE FUNCTION empleado_nombre_mayuscula(); -- para cada renglon se debe ejecutar esta funcion


INSERT INTO empleados(nombre, email,password,sueldo) 
    VALUES ('Bart Simpson','bart@mail.com','1234',2000);




-- Funcion para eliminar las tablas asociadas a empleado
CREATE OR REPLACE FUNCTION eliminar_tablas_empleado()
RETURNS trigger
AS $$
    BEGIN
        -- Como se quiere que se active esta funcion cuando se borre algo de la tabla de empleados
        -- no se tiene acceso a NEW porque no habra informacion nueva, entonces se debe ussar NEW
        DELETE FROM log_sueldos WHERE empleado_id = OLD.id;
        RETURN OLD;
    END
$$ LANGUAGE plpgsql;


CREATE TRIGGER disparador_empleado_eliminar_tablas
    BEFORE DELETE ON empleados
    FOR EACH ROW EXECUTE FUNCTION eliminar_tablas_empleado();


DELETE FROM empleados WHERE id=1;





-- Ejercicio: hacer un trigger que cuando se elimine un proyecto, se agregue un renglon en log_proyectos_eliminados

INSERT INTO proyectos(nombre) 
    VALUES ('prueba');

SELECT * FROM proyectos;



CREATE OR REPLACE FUNCTION actualizar_log_proyectos()
RETURNS trigger 
AS $$
    BEGIN
        INSERT INTO log_proyectos_eliminados(proyecto_id, nombre_proyecto)
            VALUES (OLD.id, OLD.nombre);
        RETURN OLD; 
    END
$$ LANGUAGE plpgsql;


-- Crear un trigger
CREATE TRIGGER disparador_tabla_log_proyectos 
    AFTER DELETE ON proyectos
    FOR EACH ROW EXECUTE FUNCTION actualizar_log_proyectos(); -- para cada renglon se debe ejecutar esta funcion


-- datos de prueba
INSERT INTO proyectos(nombre) VALUES
('Proyecto Alfa'),
('Proyecto Beta'),
('Proyecto Gamma');

-- eliminamos un proyecto
DELETE FROM proyectos WHERE nombre = 'Proyecto Beta';

-- mostramos el log
SELECT * FROM log_proyectos_eliminados;

