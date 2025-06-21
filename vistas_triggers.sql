-- Crear una vista de ejemplo

CREATE OR REPLACE VIEW peliculas_us AS 
    SELECT * FROM peliculas WHERE pais_origen='Estados Unidos';

-- Consultar la vista (es como si fuera una tabla virtual mas, esta no utiliza memoria)
SELECT * FROM peliculas_us;

--Diferencia con COMMON TABLE EXPRESSIONS
    WITH peliculas_cte AS (
        SELECT * FROM peliculas WHERE pais_origen='Estados Unidos';
    )

SELECT * FROM peliculas_cte;

-- La diferencia es que los CTE COMMON TABLE EXPRESSIONS solo se pueden usar durante la consulta y luego deja de existir
-- Pero los alias de las vistas si se quedan guardadas
-- La vista es un alias que da una tabla virtual que resulta de la consulta

-- Hacer un INSERT en la vista
INSERT INTO peliculas_us(titulo,pais_origen) VALUES('The Batman', 'Estados Unidos');


-- Solo se pueden hacer inserciones en la vista si la consulta que se uso para armar la vista no tiene JOINS y no contiene funciones de agregado (COUNT, AVG, SUM) en el resultado de las columnas




-- Crear una vista que usa joins 
CREATE OR REPLACE VIEW catalogo_peliculas AS
SELECT pelicula_id.actor_id,titulo,nombre FROM peliculas INNER JOIN peliculas
ON peliculas.id=peliculas_actores.pelicula_id
INNER JOIN actores ON actores.id=peliculas_actores.actor_id;


SELECT * FROM catalogo_peliculas;

--si se quiere hacer un insert en esa tabla creada, no se va a poder porque en si no existe
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
        INSERT INTO peliculas(titulo) VALUES (NEW.titulo) RETURNING id INTO nuevo_pelicula_id; --el returning es: devuelve todo lo que insertaste (puede ser lo que sea por ejemplo solo el id o todo con RETURNING *)
        INSERT INTO actores(nombre) VALUES (NEW.nombre) RETURNING id INTO nuevo_Actor_id;
        INSERT INTO peliculas_actores(pelicula_id,actor_id)
            VALUES (nuevo_pelicula_id,nuevo_Actor_id);
        RETURN NULL -- los triggers asociados a vistas no estan obligados a regresar nada
    END
$$ LANGUAGE plpgsql;



CREATE TRIGGER disparador_vista 
    INSTEAD OF INSERT 
    ON catalogo_peliculas
    -- momento INSTEAD OF para vistas
    FOR EACH ROW EXECUTE FUNCTION insert_Catalogo_peliculas();

