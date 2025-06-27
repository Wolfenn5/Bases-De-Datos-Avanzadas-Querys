-- Los roles no se crean dentro de la BD, se crean a nivel de cluster


-- Crear un usuario
CREATE ROLE usuario1 LOGIN PASSWORD '1234';

-- Crear un rol de grupo
CREATE ROLE administrador;
CREATE ROLE super_usuario;

-- Asignar el rol administrador al usuario1
GRANT administrador TO usuario1;

-- Asignar el rol de superusuario a administrador
GRANT super_usuario TO administrador;

-- La jerarquia va asi:
-- super_usuario -> administrador -> usuario1


-- Ver la tabla escondida de los usuarios en el cluster de pgadmin
SELECT * FROM pg_authid; -- muestra los roles y el password (en hash SHA-256)
SELECT * FROM pg_auth_members; -- muestra la relacion que hay entre cada rol y a que otro rol pertenece





-- EJERCICIO
-- Crear roles/grupos sin permisos de login (empleado y gerente). 
-- Los roles deben tener permisos para conectarse a la BD y al schema
-- Crear 2 usuarios con permisos de login:
--       Homero (con rol/grupo empleado) 
--       Burns  (con rol/grupo gerente) 


-- - El rol 'gerente' tendrá permisos completos para la tabla proyectos.
-- - El rol 'empleado' solo podrá consultar la tabla proyectos.


-- verificar que homero sólo pueda ver proyectos (no puede modificar datos)
-- verificar que burns si puede ver proyectos


CREATE TABLE proyectos (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT
);


INSERT INTO proyectos (nombre, descripcion) VALUES
    ('Proyecto A', 'Descripción del proyecto A'),
    ('Proyecto B', 'Descripción del proyecto B');




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
GRANT SELECT ON TABLE proyectos TO empleado;



-- Ejemplo REVOKE 
REVOKE SELECT ON TABLE proyectos FROM empleado; -- quita el permiso select a empleado en la tabla proyectos

