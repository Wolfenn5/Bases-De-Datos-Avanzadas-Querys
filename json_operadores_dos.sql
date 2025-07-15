-- 1. Crear tabla con columna JSONB que contiene arreglos simples y arreglos de objetos
CREATE TABLE catalogo (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    info JSONB
);

-- 2. Insertar datos de ejemplo
INSERT INTO catalogo (nombre, info) VALUES
('Producto 1', '{"etiquetas": ["nuevo", "oferta", "populares"], "precios": [199, 179, 149], "variantes": [{"id": 1, "color": "rojo"}, {"id": 2, "color": "azul"}]}'),
('Producto 2', '{"etiquetas": ["popular", "descuento"], "precios": [299, 279], "variantes": [{"id": 3, "color": "negro"}]}'),
('Producto 3', '{"etiquetas": ["nuevo"], "precios": [99], "variantes": []}');


SELECT * FROM catalogo;

SELECT info->'precios'->0 from catalogo;

SELECT * FROM catalogo WHERE info->'variantes'@>'[{"color":"azul"}]';










-- Crear tabla limpia
DROP TABLE IF EXISTS catalogo;
CREATE TABLE catalogo (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    info JSONB
);

-- Insertar 100,000 productos con solo 100 que tengan fabricante Initech
INSERT INTO catalogo (nombre, info)
SELECT
    'Producto ' || i,
    CASE
        WHEN i <= 100 THEN
            jsonb_build_object(
                'fabricante', 'Initech',
                'etiquetas', jsonb_build_array('descuento', 'exclusivo'),
                'precios', jsonb_build_array(199, 249),
                'variantes', jsonb_build_array(
                    jsonb_build_object('id', i, 'color', 'rojo')
                )
            )
        ELSE
            jsonb_build_object(
                'fabricante', 'Otro',
                'etiquetas', jsonb_build_array('nuevo'),
                'precios', jsonb_build_array(149),
                'variantes', jsonb_build_array(
                    jsonb_build_object('id', i, 'color', 'azul')
                )
            )
    END
FROM generate_series(1, 100000) i;


-- Consulta con @> 
EXPLAIN ANALYZE
SELECT * FROM catalogo
WHERE info @> '{"fabricante": "Initech"}';

-- Crear índice GIN general
DROP INDEX IF EXISTS idx_info_gin_general;
CREATE INDEX idx_info_gin_general ON catalogo USING GIN (info);

-- Asegurarse de que haya datos
SELECT count(*) FROM catalogo;

-- Consulta con @> después del índice
EXPLAIN ANALYZE
SELECT * FROM catalogo
WHERE info @> '{"fabricante": "Initech"}';