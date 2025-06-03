DROP TABLE IF EXISTS ventas;

CREATE TABLE ventas (
    id_venta SERIAL PRIMARY KEY,
    id_vendedor INT,
    nombre_vendedor VARCHAR(100),
    monto_venta DECIMAL(10, 2),
    fecha DATE
);

INSERT INTO ventas (id_vendedor, nombre_vendedor, monto_venta, fecha) VALUES
(1, 'Carlos López', 150.50, '2024-01-10'),
(1, 'Carlos López', 200.00, '2024-02-15'),
(1, 'Carlos López', 250.75, '2024-03-20'),
(2, 'Ana Martínez', 300.25, '2024-01-05'),
(2, 'Ana Martínez', 350.50, '2024-02-20'),
(3, 'Luis Pérez', 100.00, '2024-01-25'),
(3, 'Luis Pérez', 150.00, '2024-02-10'),
(3, 'Luis Pérez', 200.00, '2024-03-05'),
(4, 'María Gómez', 500.00, '2024-01-15'),
(4, 'María Gómez', 450.00, '2024-02-15');

SELECT * FROM ventas;

-- Los parametros que se envian a una funcion pueden ser IN, OUT, INOUT 

---- IN es el tipo por default de los parametros

---- OUT es una alternativa al keyword return (RETURN parametro)
CREATE OR REPLACE FUNCTION suma_out(
    parametro_a INT,
    parametro_b INT,
    OUT resultado INT -- OUT indica que esta variable es la que se va a regresar
)
RETURNS INT
AS $$
    BEGIN
        SELECT parametro_a + parametro_b INTO resultado;
    END
$$ LANGUAGE plpgsql;

SELECT suma_out(2,3);




---- INOUT (es como para ahorrarte variables cuando los argumentos se vuelven a utilizar)
CREATE OR REPLACE FUNCTION incrementar(
    INOUT parametro_a INT,
    IN incremento INT -- aunque se puede omitir el "IN" ya que ese siempre es por dafault
)
RETURNS INT
AS $$
    BEGIN
        SELECT parametro_a + incremento INTO parametro_a;  -- seria algo tipo a= a + incremento y como parametro_a es tipo INOUT se puede devolver el resultado ahi mismo
    END
$$ LANGUAGE plpgsql;

SELECT incrementar(1,9);


SELECT COUNT (*) FROM ventas WHERE id_vendedor=1;
SELECT AVG (monto_venta) FROM ventas WHERE id_vendedor=1;




-- EJERCICIO: hacer una funcion que use parametros IN, OUT y que al recibir el id de un vendedor regrese el promedio de sus ventas

CREATE or REPLACE FUNCTION promedio_ventas_por_id_vendedor(
    IN num_id_vendedor INT,
    OUT promedio FLOAT
)
RETURNS FLOAT
AS $$
    BEGIN
        SELECT AVG (monto_venta) FROM ventas WHERE id_vendedor= num_id_vendedor INTO promedio;
    END
$$ LANGUAGE plpgsql;

SELECT promedio_ventas_por_id_vendedor(1);