-- LIMPIEZA (por si estás re-ejecutando)
DROP VIEW IF EXISTS reporte_academico_springfield;
DROP TABLE IF EXISTS auditoria_calificaciones;
DROP TABLE IF EXISTS calificaciones;
DROP TABLE IF EXISTS inscripciones;
DROP TABLE IF EXISTS materias;
DROP TABLE IF EXISTS estudiantes;
DROP FUNCTION IF EXISTS auditar_cambios_calificaciones;

-- TABLA: estudiantes
CREATE TABLE estudiantes (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    grado INTEGER NOT NULL
);

-- TABLA: materias
CREATE TABLE materias (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

-- TABLA: inscripciones (relaciona estudiantes con materias por semestre)
CREATE TABLE inscripciones (
    id SERIAL PRIMARY KEY,
    estudiante_id INTEGER REFERENCES estudiantes(id),
    materia_id INTEGER REFERENCES materias(id),
    semestre TEXT NOT NULL
);

-- TABLA: calificaciones
CREATE TABLE calificaciones (
    id SERIAL PRIMARY KEY,
    inscripcion_id INTEGER REFERENCES inscripciones(id),
    calificacion NUMERIC(3,1) CHECK (calificacion BETWEEN 0 AND 10)
);

-- TABLA: auditoría de cambios en calificaciones
CREATE TABLE auditoria_calificaciones (
    id SERIAL PRIMARY KEY,
    inscripcion_id INTEGER,
    calificacion_anterior NUMERIC(3,1),
    calificacion_nueva NUMERIC(3,1),
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- DATOS: estudiantes
INSERT INTO estudiantes (nombre, grado) VALUES
('Bart Simpson', 4),
('Lisa Simpson', 2),
('Milhouse Van Houten', 4);

-- DATOS: materias
INSERT INTO materias (nombre) VALUES
('Matemáticas'), ('Ciencias'), ('Ética');

-- DATOS: inscripciones (estudiante_id, materia_id, semestre)
INSERT INTO inscripciones (estudiante_id, materia_id, semestre) VALUES
(1, 1, '2025-1'), -- Bart - Matemáticas
(1, 3, '2025-1'), -- Bart - Ética
(2, 1, '2025-1'), -- Lisa - Matemáticas
(2, 2, '2025-1'), -- Lisa - Ciencias
(3, 1, '2025-1'); -- Milhouse - Matemáticas

-- DATOS: calificaciones
INSERT INTO calificaciones (inscripcion_id, calificacion) VALUES
(1, 6.5),  -- Bart - Matemáticas
(2, 7.0),  -- Bart - Ética
(3, 10.0), -- Lisa - Matemáticas
(4, 9.5),  -- Lisa - Ciencias
(5, 8.0);  -- Milhouse - Matemáticas




SELECT * FROM inscripciones;
SELECT * FROM estudiantes;
SELECT * FROM materias;
SELECT * FROM calificaciones;






--- EJERICIO 1: crear una vista que muestre por cada estudiante:
-- 1. Su nombre
-- 2. El semestre en el que curso una materia
-- 3. El nombre de la materia que cursó en dicho semestre
-- 4. La calificación obtenida en esa materia


CREATE OR REPLACE VIEW reporte_calificaciones AS
    SELECT estudiantes.nombre, inscripciones.semestre, m.nombre AS materia.calificacion, calificaciones.calificacion FROM estudiantes INNER JOIN inscripciones
    ON estudiantes.id=inscripciones.estudiante_id
    INNER JOIN materias ON materias.id=inscripciones.materia_id
    INNER JOIN calificaciones ON inscripciones.id=calificaciones.inscripcion_id;

-- consultar esa vista creada de catalogo peliculas
SELECT * FROM reporte_calificaciones;


--- EJERICIO 2: crear una vista que muestre por cada estudiante:
-- 1. Su nombre
-- 2. El promedio de calificaciones obtenidas en todas las materias que ha cursado al momento



