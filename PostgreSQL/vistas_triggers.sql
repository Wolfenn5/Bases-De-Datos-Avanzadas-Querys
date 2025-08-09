-- 1. ELIMINAR TABLAS SI EXISTEN
DROP TABLE IF EXISTS peliculas_actores, actores, peliculas CASCADE;

-- 2. CREAR TABLAS

-- Tabla de películas (sin año)
CREATE TABLE peliculas (
    id SERIAL PRIMARY KEY,
    titulo TEXT NOT NULL,
    pais_origen TEXT NOT NULL
);

-- Tabla de actores
CREATE TABLE actores (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

-- Tabla intermedia muchos a muchos
CREATE TABLE peliculas_actores (
    pelicula_id INT REFERENCES peliculas(id) ON DELETE CASCADE,
    actor_id INT REFERENCES actores(id) ON DELETE CASCADE,
    PRIMARY KEY (pelicula_id, actor_id)
);

-- 3. INSERTAR DATOS DE EJEMPLO

-- Películas
INSERT INTO peliculas (titulo, pais_origen) VALUES
('Inception', 'Estados Unidos'),
('Jurassic Park', 'Estados Unidos'),
('Amélie', 'Francia'),
('Roma', 'México'),
('Pulp Fiction', 'Estados Unidos'),
('El laberinto del fauno', 'México');

-- Actores
INSERT INTO actores (nombre) VALUES
('Leonardo DiCaprio'),
('Ellen Page'),
('Joseph Gordon-Levitt'),
('Laura Dern'),
('Sam Neill'),
('Audrey Tautou'),
('Yalitza Aparicio'),
('John Travolta'),
('Samuel L. Jackson'),
('Ivana Baquero');

-- Relación películas-actores
INSERT INTO peliculas_actores (pelicula_id, actor_id) VALUES
-- Inception
(1, 1), (1, 2), (1, 3),
-- Jurassic Park
(2, 4), (2, 5),
-- Amélie
(3, 6),
-- Roma
(4, 7),
-- Pulp Fiction
(5, 8), (5, 9),
-- El laberinto del fauno
(6, 10);



SELECT * FROM peliculas;




-- Crear una vista de ejemplo
CREATE OR REPLACE VIEW peliculas_us AS 
    SELECT * FROM peliculas WHERE pais_origen='Estados Unidos';
-- Consultar la vista (es como si fuera una tabla virtual mas, esta no utiliza memoria)
SELECT * FROM peliculas_us;



-- Diferencia con COMMON TABLE EXPRESSIONS
-- es que los CTE COMMON TABLE EXPRESSIONS solo se pueden usar durante la consulta y luego deja de existir
-- Pero los alias de las vistas si se quedan guardadas
-- La vista es un alias que da una tabla virtual que resulta de la consulta
    WITH peliculas_cte AS (
        SELECT * FROM peliculas WHERE pais_origen='Estados Unidos'
    )
SELECT * FROM peliculas_cte;




-- Hacer un INSERT en la vista
INSERT INTO peliculas_us(titulo,pais_origen) VALUES('The Batman', 'Estados Unidos');
-- Solo se pueden hacer inserciones en la vista si la consulta que se uso para armar la vista no tiene JOINS y no contiene funciones de agregado (COUNT, AVG, SUM) en el resultado de las columnas
SELECT * FROM peliculas_us; -- volver a consultar la vista
SELECT * FROM peliculas; -- volver a consultar la tabla



-- Crear una vista que usa joins 
CREATE OR REPLACE VIEW catalogo_peliculas AS
SELECT pelicula_id,actor_id,titulo,nombre FROM peliculas INNER JOIN peliculas_actores
ON peliculas.id=peliculas_actores.pelicula_id
INNER JOIN actores ON actores.id=peliculas_actores.actor_id;

-- consultar esa vista creada de catalogo peliculas
SELECT * FROM catalogo_peliculas;



--si se quiere hacer un insert en esa tabla creada, no se va a poder porque en si no existe y ademas utiliza JOIN'S
INSERT INTO catalogo_peliculas(titulo,nombre)
    VALUES('The Truman Show','Jim Carrey');



-- Asi que una alternativa seria usar triggers
CREATE OR REPLACE FUNCTION insert_Catalogo_peliculas()
RETURNS TRIGGER
AS $$
    DECLARE
    nuevo_pelicula_id INT;
    nuevo_Actor_id INT;
    BEGIN
        INSERT INTO peliculas(titulo,pais_origen) VALUES (NEW.titulo,'Estados Unidos') RETURNING id INTO nuevo_pelicula_id; --el returning es: devuelve todo lo que insertaste (puede ser lo que sea por ejemplo solo el id o todo con RETURNING *)
        INSERT INTO actores(nombre) VALUES (NEW.nombre) RETURNING id INTO nuevo_Actor_id;
        INSERT INTO peliculas_actores(pelicula_id,actor_id)
            VALUES (nuevo_pelicula_id,nuevo_Actor_id);
        RETURN NULL; -- los triggers asociados a vistas no estan obligados a regresar nada
    END;
$$ LANGUAGE plpgsql;




CREATE TRIGGER disparador_vista 
    INSTEAD OF INSERT -- momento en el que se activara el trigger. Como este trigger es para una vista se utiliza INSTEAD OF INSERT
    ON catalogo_peliculas
    -- momento INSTEAD OF para vistas
    FOR EACH ROW EXECUTE FUNCTION insert_Catalogo_peliculas();


-- Se vuelve a correr el insert que antes no funciono
INSERT INTO catalogo_peliculas(titulo,nombre)
    VALUES('The Truman Show','Jim Carrey');


-- se consulta la vista
SELECT * FROM catalogo_peliculas;


-- se consulta la tabla peliculas
SELECT * FROM peliculas;


-- se consulta la tabla actores
SELECT * FROM actores;