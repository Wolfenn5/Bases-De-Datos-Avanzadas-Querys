-- Los usuarios son un rol con capacidad de login
-- Los grupos son un rol que agrupa otros roles

-- En postgres tanto usuarios como roles son lo mismo. Los roles tipo 'LOGIN' es un usuario
-- La jerarquia de permisos de los objetos de la BD por default se crean en schemas y public
-- Los roles no se guardan en la BD, se guardan a nivel de CLUSTER


--Los permisos se conocen como privilegios




CREATE TABLE usuarios (
    id INT PRIMARY KEY.
    nombre TEXT
);
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




