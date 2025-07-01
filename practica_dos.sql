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


SELECT * FROM log_sueldos;








CREATE OR REPLACE VIEW reporte_calificaciones AS
    SELECT estudiantes.nombre, inscripciones.semestre, m.nombre AS materia.calificacion, calificaciones.calificacion FROM estudiantes INNER JOIN inscripciones
    ON estudiantes.id=inscripciones.estudiante_id
    INNER JOIN materias ON materias.id=inscripciones.materia_id
    INNER JOIN calificaciones ON inscripciones.id=calificaciones.inscripcion_id;

-- consultar esa vista creada de catalogo peliculas
SELECT * FROM reporte_calificaciones;


















-- Crear un usuario (roles) de tipo LOGIN
CREATE ROLE administrador LOGIN PASSWORD '1234';

CREATE ROLE usuario_simple LOGIN PASSWORD '1234';



-- Crear roles de grupo
CREATE ROLE visualizador; -- es de grupo porque no tiene LOGIN
CREATE ROLE editor;

-- Asignar el grupo a los usuarios
GRANT visualizador TO administrador,usuario_simple;

GRANT editor TO administrador;


-- Asignar el privilegio de conectarse a un rol
GRANT CONNECT ON DATABASE BD_roles TO visualizador; --el nombre de la BD
GRANT USAGE ON SCHEMA public TO visualizador; -- el nombre del schema








-- Crear roles de grupo: empleado y gerente
CREATE ROLE empleado;
CREATE ROLE gerente;

-- Otorgar permisos de conexion a la BD a los roles
GRANT CONNECT ON DATABASE nombre_BD TO empleado,gerente; 
GRANT USAGE ON SCHEMA public TO empleado,gerente; -- al schema public, puede ser otro como app

-- Crear roles de LOGIN (usuario) 
CREATE ROLE Homero LOGIN PASSWORD '1234';
CREATE ROLE Burns LOGIN PASSWORD '1234';

-- Asignar roles de grupo a los usuarios
GRANT empleado TO Homero;
GRANT gerente TO Burns;

-- Otorgar permisos a los usuarios sobre la tabla proyectos
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE proyectos TO gerente; 

-- GRANT ALL asigna todos los permisos
GRANT ALL ON SEQUENCE proyectos_id_Seq TO gerente; -- pendiente, revisar esto
            -- Como la tabla tiene un contador para el id, hay que dar permisos para acceder tambien a ese contador
            -- usuarios_id_seq es el contador especial que hace eso
            GRANT USAGE ON SEQUENCE app.ususarios_id_seq TO administrador; 
            -- Solo se podra con la tabla ususarios
            -- si se crean mas tablas con un id SERIAL ya no va a poder acceder
            -- Asi que se tendria que hacer lo siguiente
            GRANT USAGE ON ALL SEQUENCES TO IN SCHEMA app TO administrador;
GRANT SELECT ON TABLE proyectos TO empleado;



-- Ejemplo REVOKE 
REVOKE SELECT ON TABLE proyectos FROM empleado; -- quita el permiso select a empleado en la tabla proyectos
