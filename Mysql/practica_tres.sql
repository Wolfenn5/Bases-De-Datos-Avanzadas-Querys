DROP TABLE IF EXISTS aves, mamiferos, animales CASCADE;

CREATE TABLE animales (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    especie TEXT,
    habitat TEXT,
    info JSONB
);

CREATE TABLE mamiferos (
    tiempo_gestacion INT
) INHERITS (animales);

CREATE TABLE aves (
    puede_volar BOOLEAN,
    envergadura_cm REAL
) INHERITS (animales);

-- Mamíferos
INSERT INTO mamiferos (nombre, especie, habitat, tiempo_gestacion, info) VALUES
('Dumbo', 'Elephas maximus', 'Sabana', 660,
 '{
    "dieta": ["hierba", "frutas", "corteza"],
    "social": true,
    "cuidados": {
        "frecuencia_revision_dental": "semestral",
        "ultima_revision": "2024-12-01"
    }
 }'),
('Baloo', 'Ursus arctos', 'Bosque', 220,
 '{
    "dieta": ["peces", "miel", "bayas"],
    "hibernacion": true,
    "peso_kg": 350,
    "cuidados": {
        "frecuencia_revision": "anual",
        "medicamentos": ["vitamina D"]
    }
 }');

-- Aves
INSERT INTO aves (nombre, especie, habitat, puede_volar, envergadura_cm, info) VALUES
('Tequila', 'Aquila chrysaetos', 'Montañas', true, 210.0,
 '{
    "dieta": ["roedores", "peces"],
    "nido": {
        "altura_metros": 15,
        "materiales": ["ramas", "hojas"]
    },
    "migratoria": false
 }'),
('Kiwi', 'Apteryx', 'Bosque templado', false, 30.0,
 '{
    "dieta": ["insectos", "lombrices"],
    "comportamiento": {
        "nocturno": true,
        "territorial": true
    }
 }');


SELECT * FROM animales;
SELECT * FROM mamiferos;
SELECT * FROM aves;




-- Consultar altura metros de aves
SELECT info ->'nido'->'altura_metros' AS altura_metros_aves FROM aves;  -- AS para poner el nombre de la columna y no salga como ?column?

-- Castear a numero para comparar
SELECT (info ->'nido'->'altura_metros')::INT+5 FROM aves;

-- Consultar algo que al final tenga la letra o
SELECT * FROM mamiferos WHERE nombre LIKE '%o'; -- % significa cualquier cosa, seria como un . en expresiones regulares

-- json array lenght es para cuando se sabe que en el json es un arreglo y se quiere saber la longitud
SELECT jsonb_array_length(info->'dieta') FROM mamiferos;








-- ========== PRUEBAS PARTE 1 =============

--1 Nombres y fechas de diciembre con ultima revision de dicmebre 
SELECT nombre, info->'cuidados'->>'ultima_revision' AS ultima_revision FROM mamiferos WHERE info->'cuidados'->>'ultima_revision' LIKE '%-12-%'; 


-- 2 Animales que tengan dieta de peces y roedores
SELECT nombre FROM animales WHERE info->'dieta' ?& array['peces', 'roedores']; -- ver que tanto peces como roedores esten en info-> dieta



-- 3 Aves con nidos de ramas y hojas
SELECT nombre FROM aves WHERE info->'nido'->'materiales' @> '["ramas", "hojas"]' AND jsonb_array_length(info->'nido'->'materiales') = 2; -- que solo tengan ramas y hojas 




-- 4 Mamiferos que tengan medicamentos
SELECT nombre, info->'cuidados'->'medicamentos' AS medicamentos_mamiferos FROM mamiferos WHERE info->'cuidados' ? 'medicamentos'; -- ?column? a medicamentos_mamiferos



-- 5 Aves del nido con mas de 10 metros
SELECT nombre FROM aves WHERE (info->'nido'->>'altura_metros')::INT>10; -- castear con ::INT para convertir el campo de info a un numero





-- ========== PRUEBAS PARTE 2 =============
-- 6 Eliminar campo hibernacion
--UPDATE mamiferos SET info=jsonb_set(info,'{}',(info->'hibernacion')-'hibernacion'); -- {} solito porue hibernacion no esta dentro de otro campo como en el ejemplo de =jsonb_set(atributos,'{blindaje}',(atributos->'blindaje')-'ram')

UPDATE mamiferos SET info = info - 'hibernacion'; -- en info se indica solo 'hibernacion' porque no hay otro subcampo para acceder a hibernacion

SELECT * FROM mamiferos; -- baloo ya no deberia tener

-- 7 Agregar estado saludable en info (jsonb) a todos los animales
UPDATE animales SET info = info || '{"estado": "saludable"}'; -- para otra tabla cambiar animales, aves, mamiferos

SELECT * FROM animales; -- todos los animales deben tener estado saludable
