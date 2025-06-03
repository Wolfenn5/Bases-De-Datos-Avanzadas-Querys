CREATE TABLE alumnos (
    id_alumno SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

CREATE TABLE materias (
    id_materia SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

CREATE TABLE calificaciones (
    id_calificacion SERIAL PRIMARY KEY,
    id_alumno INT REFERENCES alumnos(id_alumno),
    id_materia INT REFERENCES materias(id_materia),
    calificacion NUMERIC(5,2) NOT NULL,
    fecha DATE NOT NULL
);

-- Alumnos
INSERT INTO alumnos (nombre) VALUES
('Bart Simpson'),
('Lisa Simpson'),
('Milhouse Van Houten'),
('Nelson Muntz'),
('Ralph Wiggum');

-- Materias
INSERT INTO materias (nombre) VALUES
('Matemáticas'),
('Ciencias'),
('Historia');

-- Calificaciones
INSERT INTO calificaciones (id_alumno, id_materia, calificacion, fecha) VALUES
-- Bart
(1, 1, 5.0, '2025-01-15'),
(1, 2, 6.0, '2025-01-16'),
(1, 3, 4.0, '2025-01-17'),

-- Lisa
(2, 1, 10.0, '2025-01-15'),
(2, 2, 10.0, '2025-01-16'),
(2, 3, 9.5, '2025-01-17'),

-- Milhouse
(3, 1, 7.0, '2025-01-15'),
(3, 2, 8.0, '2025-01-16'),
(3, 3, 6.5, '2025-01-17'),

-- Nelson
(4, 1, 6.0, '2025-01-15'),
(4, 2, 5.0, '2025-01-16'),
(4, 3, 5.5, '2025-01-17'),

-- Ralph
(5, 1, 4.0, '2025-01-15'),
(5, 2, 3.5, '2025-01-16'),
(5, 3, 4.0, '2025-01-17');


-- Ver tablas
SELECT * FROM alumnos;
SELECT * FROM materias;
SELECT * FROM calificaciones;


-- JOIN de alumnos y calificaciones (JOIN/INNER JOIN) y da todo lo de bart simpson (id_alumno 1)
SELECT * FROM alumnos --alumnos.nombre en vez de * si solo se quiere ver el nombre en vez de todas las columnas
JOIN calificaciones 
ON alumnos.id_alumno=calificaciones.id_alumno
-- y de esa tabla "temporal" se une esta otra
JOIN materias 
ON calificaciones.id_materia=materias.id_materia; --WHERE alumnos.id_alumno=1;








-- Funcion promedio_alumno 
DROP FUNCTION promedio_alumno(text,text);
CREATE OR REPLACE FUNCTION promedio_alumno(
    nombre_buscar TEXT, 
    materia_buscar TEXT,
    OUT promedio_materia NUMERIC -- OUT indica que esta variable es la que se va a regresar
)
RETURNS NUMERIC
AS $$
    BEGIN
        SELECT AVG(calificaciones.calificacion) FROM alumnos 
        JOIN calificaciones 
        ON alumnos.id_alumno=calificaciones.id_alumno
        -- y de esa tabla "temporal" se une esta otra
        JOIN materias 
        ON calificaciones.id_materia=materias.id_materia -- se hace relacion con el id en vez del nombre solo para hacer uso del JOIN de ejemplo de clase
        WHERE alumnos.nombre= nombre_buscar AND materias.nombre= materia_buscar -- "donde" se indican los argumentos de la funcion
        INTO promedio_materia;
    END
$$ LANGUAGE plpgsql;

SELECT promedio_alumno('Bart Simpson','Matemáticas');




-- Funcion mejores_alumnos
CREATE OR REPLACE FUNCTION mejores_alumnos(materia_buscar TEXT)
RETURNS TABLE(
	nombres_alumnos TEXT,
	promedios_alumnos NUMERIC
)
AS $$
 --CUERPO DE LA FUNCION
 BEGIN
    RETURN QUERY 
    SELECT alumnos.nombre, AVG(calificaciones.calificacion)  AS promedio -- promedio para indicar que es lo que se va a ordenar (ORDER BY)
    FROM alumnos 
    JOIN calificaciones 
    ON alumnos.id_alumno=calificaciones.id_alumno
    -- y de esa tabla "temporal" se une esta otra
    JOIN materias 
    ON calificaciones.id_materia=materias.id_materia -- se hace relacion con el id en vez del nombre solo para hacer uso del JOIN de ejemplo de clase
    WHERE materias.nombre= materia_buscar -- "donde" buscar nombre materia
    GROUP BY alumnos.nombre
    ORDER BY promedio DESC;
 END
$$ LANGUAGE plpgsql;

SELECT * FROM mejores_alumnos('Matemáticas');




-- Funcion ajustar_calificaicon
CREATE OR REPLACE FUNCTION ajustar_calificacion(id_calificacion_buscar INT, calificacion_nueva NUMERIC)
RETURNS VOID 
AS $$
    BEGIN
        UPDATE calificaciones
        SET calificacion= calificacion_nueva
        WHERE id_calificacion= id_calificacion_buscar;
    END;
$$ LANGUAGE plpgsql;


SELECT ajustar_calificacion(1, 8.0);