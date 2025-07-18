--código realizado:
DROP TABLE IF EXISTS productos;

-- estes es un comentario
CREATE TABLE productos(
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),
  precio FLOAT
);

INSERT INTO productos(nombre,precio) VALUES('TV',5000.50);
INSERT INTO productos(nombre,precio) VALUES('xbox',10000.50);
INSERT INTO productos(nombre,precio) VALUES('laptop',10000.50);

SELECT * FROM productos;

SELECT precio FROM productos WHERE nombre='TV';

SELECT nombre FROM productos WHERE precio=5000.50;


DROP FUNCTION obtener_nombre_por_precio(double precision);
CREATE OR REPLACE FUNCTION obtener_nombre_por_precio(precio_buscar FLOAT)
--RETURNS SETOF VARCHAR(100) --SETOF para regresar un conjunto de cadenas
RETURNS TABLE(
	nombre_producto VARCHAR(100),
	precio_producto FLOAT
)
AS $$
 --CUERPO DE LA FUNCION
 --DECLARE
    --nombre_encontrado VARCHAR(100);
 BEGIN
    RETURN QUERY SELECT nombre, precio FROM productos WHERE precio=precio_buscar;
    --RETURN nombre_encontrado;
 END
$$ LANGUAGE plpgsql;

SELECT obtener_nombre_por_precio(5000.50);

SELECT obtener_nombre_por_precio(10000.50);



-- EJERCICIO

-- HACER UNA FUNCION QUE REGRESE EL PRECIO DADO UN NOMBRE DE PRODUCTO
CREATE OR REPLACE FUNCTION obten_precio_por_nombre(nombre_buscar VARCHAR(100))
RETURNS FLOAT
AS $$
DECLARE
   precio_encontrado FLOAT;
BEGIN
  SELECT precio INTO precio_encontrado FROM productos WHERE nombre=nombre_buscar;
  RETURN precio_encontrado;
END
$$ LANGUAGE plpgsql;

SELECT obten_precio_por_nombre('TV');






