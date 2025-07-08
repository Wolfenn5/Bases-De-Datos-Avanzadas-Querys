CREATE TABLE info_usuario(
    ID SERIAL PRIMARY KEY,
    NOMBRE VARCHAR,
    datos JSONB -- puede ser JSON o JSONB
);

-- JSON   guardar objetos JSON como texto
-- JSONB  guardar objetos JSON como binarios

INSERT INTO info_usuario (nombre,datos)
    VALUES ('Homero Simpson',
    '{
        "Direccion": { 
            "calle" : "Avenida. Siempre Viva",
            "Numero": 40,
            "es_domicilio_principal": true
        },

        "Telefono" : "12345",
        "Trabajo" : "Tecnico Nuclear"
    }'
    );



SELECT * FROM info_usuario;

SELECT datos->'Trabajo' from info_usuario; -- mostrar solo el campo trabajo del JSON
SELECT datos->'Trabajo' AS TRABAJO from info_usuario; -- el alias sirve para dar nombre a la columna y no salga ¿column?


-- Mostrar el trabajo y numero de casa
SELECT datos->'Trabajo' AS trabajo, datos->'Direccion'->'Numero' AS numero_casa from info_usuario; 



-- Hacer un update en el JSON, el numero de la casa
    -- jsonb set recibe 3 parametros
    -- 1. objeto a modificar
    -- 2. ruta al atrbibuto a actualizar
    -- 3. nuevo valor del atributo
UPDATE info_usuario SET datos=jsonb_set(datos,'{Direccion,Numero}','50');
UPDATE info_usuario SET datos=jsonb_set(datos,'{Direccion,Numero}',"50"); -- de esta forma el 50 se cambia a una cadena en vez de un numero