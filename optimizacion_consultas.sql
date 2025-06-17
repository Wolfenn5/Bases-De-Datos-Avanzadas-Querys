-- Parsing: postgresql analiza la sintaxis de la consulta

-- Hay que evitar traer columnas necesarias para optimizar consultas como SELECT * FROM usuarios;
-- Es mejor SELECT id,nombre,email FROM usuarios; solo las necesarias
-- o utilizar limits SELECT id,nombre,email FROM usuarios ORDER BY fecha_creacion DESC LIMIT 10; y traer pocos renglones nadamas

-- orden de condiciones en WHERE como: WHERE: SELECT * FROM usuarios WHERE estado = 'activo' AND edad>30 AND pais='Mexico'; para filtrar de forma secuencial, las condiciones mas selectivas ayudan a descartar filas anteriores
-- Al momento de filtrar, lo mejor es poner primero las mas restrictivas y luego las menos restrictivas




-- Crear la tabla A
DROP TABLE IF EXISTS tabla_a;
CREATE TABLE tabla_a (
    ID INTEGER PRIMARY KEY,
    Product TEXT
);

-- Insertar datos en la tabla A
INSERT INTO tabla_a (ID, Product) VALUES
(1, 'Chair'),
(2, 'Table'),
(3, 'Laptop'),
(4, 'Phone'),
(5, 'Flash Drive');

-- Crear la tabla B
DROP TABLE IF EXISTS tabla_b;
CREATE TABLE tabla_b (
    ID INTEGER PRIMARY KEY,
    Price TEXT
);

-- Insertar datos en la tabla B
INSERT INTO tabla_b (ID, Price) VALUES
(1, '$80'),
(2, '$120'),
(4, '$799'),
(6, '$99');


-- Tabla de usuarios
DROP TABLE IF EXISTS usuarios CASCADE;
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    estado TEXT NOT NULL, -- activo / inactivo
    edad INTEGER,
    pais TEXT
);

-- Tabla de emails (relación 1:N con usuarios)
DROP TABLE IF EXISTS emails;
CREATE TABLE emails (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id),
    email TEXT NOT NULL
);

-- Tabla de órdenes (relación 1:N con usuarios)
DROP TABLE IF EXISTS ordenes;
CREATE TABLE ordenes (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id),
    fecha TIMESTAMP NOT NULL,
    total NUMERIC(10,2),
    cliente_id INTEGER
);


CREATE OR REPLACE PROCEDURE generar_datos(total_usuarios INT DEFAULT 200)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT := 1;
    nombres TEXT[] := ARRAY['Ana', 'Carlos', 'Juan', 'Lucía', 'Pedro', 'Sofía', 'Miguel', 'Valeria', 'Javier', 'Andrea', 'Diego', 'Camila', 'Fernando', 'Laura', 'Ricardo', 'María', 'José', 'Patricia', 'Raúl', 'Samantha'];
    apellidos TEXT[] := ARRAY['López', 'Pérez', 'Torres', 'Morales', 'Gómez', 'Hernández', 'Ángel', 'Ruiz', 'Sánchez', 'Castillo', 'Fernández', 'Ortiz', 'Díaz', 'Martínez', 'Jiménez', 'Ramírez', 'Cruz'];
    estados TEXT[] := ARRAY['activo', 'inactivo'];
    paises TEXT[] := ARRAY['México', 'Colombia', 'Chile', 'Argentina', 'Perú'];
    uid INT;
    n_ordenes INT;
    n_emails INT;
    j INT;
    correo TEXT;
BEGIN
    -- Limpiar tablas
    DELETE FROM ordenes;
    DELETE FROM emails;
    DELETE FROM usuarios;

    FOR i IN 1..total_usuarios LOOP
        -- Insertar usuario
        INSERT INTO usuarios(nombre, estado, edad, pais)
        VALUES (
            nombres[1 + floor(random() * array_length(nombres, 1))::int] || ' ' ||
            apellidos[1 + floor(random() * array_length(apellidos, 1))::int],
            estados[1 + floor(random() * 2)::int],
            18 + floor(random() * 50)::int,
            paises[1 + floor(random() * array_length(paises, 1))::int]
        )
        RETURNING id INTO uid;

        -- Insertar 1 a 2 correos
        n_emails := 1 + floor(random() * 2)::int;
        FOR j IN 1..n_emails LOOP
            correo := lower(substr(md5(random()::text), 1, 10)) || '@example.com';
            INSERT INTO emails(usuario_id, email)
            VALUES (uid, correo);
        END LOOP;

        -- Insertar 0 a 3 órdenes
        n_ordenes := floor(random() * 4)::int;
        FOR j IN 1..n_ordenes LOOP
            INSERT INTO ordenes(usuario_id, fecha, total, cliente_id)
            VALUES (
                uid,
                now() - (floor(random() * 365) || ' days')::interval,
                round((random() * 1000)::numeric, 2),
                1000 + floor(random() * 100)::int
            );
        END LOOP;
    END LOOP;
END;
$$;

CALL generar_datos(500);
SELECT COUNT(*) FROM usuarios;
SELECT COUNT(*) FROM emails;
SELECT COUNT(*) FROM ordenes;


-- ---------------------- EXPLAIN ----------------------
-- EXPLAIN hace una estimacion de cuanto va a tardar la consulta (explica) pero no ejecuta la consulta
EXPLAIN SELECT * FROM usuarios;
-- Da seq scan que es la estrategia interna para leer la tabla
-- da un costo
-- la estimacion de renglones que da
-- width da el total de bytes que necesita para representar la informacion


-- ---------------------- EXPLAIN ANALYZE ----------------------
-- EXPLAIN hace una estimacion de cuanto va a tardar la consulta (explica y analiza) es decir da el tiempo real que puede tardar la consulta, esta si ejecuta la consulta
EXPLAIN ANALYZE SELECT * FROM usuarios;-- Da seq scan que es la estrategia interna para leer la tabla
-- da un costo
-- la estimacion de renglones que da
-- width da el total de bytes que necesita para representar la informacion
-- da el tiempo real que se tardo PERO primero muestra el tiempo de inicializacion que postgres hace internamente, luego muestra el tiempo real
-- muestra cuantos bucles anidados hace para la consulta (subconsultas para la query principal)



-- ---------------------- ANALYZE ----------------------
-- ANALYZE es recomendable utilizarlo antes de EXPLAIN
--Mantiene las estadisticas del planificador actualizadas es decir
-- actualiza tablas internas de la base con informacion estadistica para hacer mejores estimaciones
ANALYZE usuarios; -- solo para la tabla usuarios
ANALYZE; -- esto actualiza las estadisticas para todas las tablas
-- Hay que tener cuidado con esto si la BD tiene miles de millones de informacion y miles de tablas ya que las estadisticas son pesadas


EXPLAIN ANALYZE SELECT * FROM usuarios;


-- Hacer una consulta por pais
SELECT pais FROM usuarios WHERE pais = 'México';
EXPLAIN SELECT pais FROM usuarios WHERE pais = 'México';



-- ---------------------- CREATE INDEX ----------------------
-- Si se tiene una columna que se consulte muy seguido se puede crear un indice para optimizar el tiempo de la consulta
-- Al usar y crear un indice lo que se hace en realidad es crear un arbol binario con busqueda binaria
-- Eso a su vez tiene un costo a pagar, se duplican los datos y por ende se usa mas espacio
-- Un indice generalmente tiene  O(log n) y con tablas sencillas puede ser O(n)
-- Conviene usarlos cuando se tienen muchos valores diferentes en una columna
CREATE INDEX indice_usuarios_pais ON usuarios(pais); -- el nombre del indice ON tabla (columna de la tabla)
ANALYZE usuarios; -- se usa para actualizar las estadisticsa porque se creo el indice
EXPLAIN SELECT pais FROM usuarios WHERE pais = 'México';

CREATE INDEX indice_usuarios_pais ON usuarios(pais,edad); -- se crea un indice pero para 2 columnas



-- cUANDO SE UTILIZA PRIMARY KEY, internamente se crea un indice, como id que se dijo que era primary key en la tabla usuarios
EXPLAIN SELECT pais FROM usuarios WHERE id = 2; -- con este como se accede a PRIMARY KEY, va a dar un index scan en vez de seq scan
EXPLAIN SELECT id FROM usuarios WHERE id = 2; -- de esta forma use index only scan es cuando regresa solo el id, usa mas el valor directo del arbol binario en vez del valor de la tabla interna



-- ---------------------- LEFT  OUTER JOIN ----------------------
-- ---------------------- RIGHT OUTER JOIN ----------------------
-- ---------------------- FULL  OUTER JOIN ----------------------
-- ---------------------- INNER OUTER JOIN ----------------------
-- Une las tablas por ejemplo A y B, pero une todas las coincidencias de las columnas de la tabla de la izquierda con la tabla de la derecha
-- CON LEFT ó RIGHT JOIN, al unir las tablas Si hay columnas que no coincidan va a devolver NULL
-- CON FULL JOIN va a unir todos los renglones que coinciden tanto la tabla A como la B
-- La diferencia con INNER JOIN solo va a unir los renglones que coinciden de las dos tablas
SELECT * FROM tabla_a AS a 
         LEFT JOIN tabla_b AS b
         ON a.id = b.id; -- aparte de hacer el join se usan alias

-- tambien se puede usar explain en este tipo de consultas
EXPLAIN SELECT * FROM tabla_a AS a 
                 LEFT JOIN tabla_b AS b
         ON a.id = b.id; 

EXPLAIN SELECT * FROM tabla_a AS a 
                 RIGHT JOIN tabla_b AS b
                 ON a.id = b.id; 

EXPLAIN SELECT * FROM tabla_a AS a 
                 FULL JOIN tabla_b AS b
                 ON a.id = b.id; 

EXPLAIN SELECT * FROM tabla_a AS a 
                 INNER JOIN tabla_b AS b
                 ON a.id = b.id; 
-- Es preferible utilizar INNER JOIN cuando sea posible ya que es lo mas ideal



-- ---------------------- COMMON TABLE EXPRESSION ----------------------
WITH milenials AS (
    SELECT * FROM usuarios WHERE edad <= 30
)
SELECT * FROM milenials WHERE pais='Chile';
-- se crea una tabla temporal con un alias y se hace una consulta sobre esta tabla temporal
-- asi se obtienen datos un poco mas rapido y se almacenan en un cache temporal