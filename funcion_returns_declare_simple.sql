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

SELECT SUM(monto_venta) FROM ventas WHERE id_vendedor=1;

SELECT nombre_vendedor, SUM(monto_venta) 
FROM ventas 
WHERE id_vendedor IN(1,2)
GROUP BY id_vendedor, nombre_vendedor
HAVING SUM(monto_venta) > 650;



-- Ejercicio hacer una funcion que muestre la suma de las ventas de ese vendedor

-- Funcion
CREATE OR REPLACE FUNCTION suma_ventas_por_vendedor(id_vendedor_a_buscar INT)
RETURNS DECIMAL
AS $$
 --CUERPO DE LA FUNCION
 DECLARE
    total_ventas DECIMAL;
 BEGIN
    SELECT SUM(monto_venta) INTO total_ventas 
	FROM ventas 
	WHERE id_vendedor=id_vendedor_a_buscar;
    RETURN total_ventas;
 END
$$ LANGUAGE plpgsql;

SELECT suma_ventas_por_vendedor(1);

