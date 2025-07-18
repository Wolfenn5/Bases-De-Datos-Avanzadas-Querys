-- Crear una tabla en el schema app
CREATE TABLE app.usuarios(
    id SERIAL PRIMARY KEY,
    nombre TEXT
);


-- Crear una tabla en el schema app
CREATE TABLE app.usuarios2(
    id SERIAL PRIMARY KEY,
    nombre TEXT
);


-- Crear una tabla en el schema app
CREATE TABLE app.usuarios3(
    id SERIAL PRIMARY KEY,
    nombre TEXT
);


SELECT * FROM app.usuarios;


-- Crear tabla historial en el schema public
-- Generalmente al crear tablas postgres asume que se hace asi:
-- public.historial
CREATE TABLE historial(
    id SERIAL PRIMARY KEY,
    evento TEXT
);

SELECT * FROM historial;


-- Como los roles se crean a nivel de cluster, no es necesario especificar que esten en un schema determinado

-- Crear rol de usuario
CREATE ROLE bart LOGIN PASSWORD '1234';
CREATE ROLE skinner LOGIN PASSWORD '1234';

-- Crear rol de grupo
CREATE ROLE estudiante; -- solo podra ver tablas
CREATE ROLE administrador; -- puede modificar las tablas



-- Otorgar permisos para conectarse a la BD y usar el schema
GRANT CONNECT ON DATABASE demo_base TO administrador;
GRANT USAGE ON SCHEMA app TO administrador;



-- Otorgar permisos a administrador en la tabla usuarios del schema app
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE app.usuarios TO administrador;

-- Si se quiere para todas las tablas que existen al momento entonces seria
GRANT INSERT, DELETE, SELECT, UPDATE ON ALL TABLES IN SCHEMA app TO administrador; 
-- Si se crean mas tablas despues, no va a tener acceso despues
-- por ejemplo si se crea app.usuarios2 despues no tendra acceso
-- Asi que para que al crear tablas siempre vaya teniendo acceso por default se podria hacer lo siguiente
ALTER DEFAULT PRIVILEGES 
    IN SCHEMA app 
        GRANT INSERT, DELETE, SELECT, UPDATE ON TABLES TO administrador;
-- Asi al crear app.usuarios3 ya tendra acceso son tener que ejecutar otra vez la instruccion


-- Asignar rol de grupo a los usuarios
GRANT administrador to skinner;
GRANT estudiante to bart;



-- Como la tabla tiene un contador para el id, hay que dar permisos para acceder tambien a ese contador
-- usuarios_id_seq es el contador especial que hace eso
GRANT USAGE ON SEQUENCE app.ususarios_id_seq TO administrador; 
-- Solo se podra con la tabla ususarios
-- si se crean mas tablas con un id SERIAL ya no va a poder acceder
-- Asi que se tendria que hacer lo siguiente
GRANT USAGE ON ALL SEQUENCES TO IN SCHEMA app TO administrador;



-- Con otra pestaña y accediendo como skinner
SELECT * FROM app.usuarios;
INSERT INTO app. usuarios(nombre) VALUES ('willie');