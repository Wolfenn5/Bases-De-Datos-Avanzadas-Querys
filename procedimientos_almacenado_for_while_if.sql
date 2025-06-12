-- La diferencia escencial entre un procedimiento y una funcion es que
-- los procedimientos almacenados pueden controlar transacciones
-- es decir, pueden hacer COMMIT o ROLLBACK
-- cuando se invoca un procedimiento se inicia una transaccion por default


DROP TABLE IF EXISTS tickets;

CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    vendido BOOLEAN,
    fecha_venta DATE
);

-- Insertar tickets con fechas específicas anteriores a la fecha actual
INSERT INTO tickets (vendido, fecha_venta) VALUES
(FALSE, NULL),
(TRUE, DATE '2024-12-01'),
(TRUE, DATE '2025-01-15'),
(FALSE, NULL);

-- Borrar tablas si existen
DROP TABLE IF EXISTS movimientos;
DROP TABLE IF EXISTS cuentas;

-- Crear tabla cuentas
CREATE TABLE cuentas (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    saldo NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (saldo >= 0)
);

-- Crear tabla movimientos
CREATE TABLE movimientos (
    id SERIAL PRIMARY KEY,
    id_cuenta INT NOT NULL REFERENCES cuentas(id),
    monto NUMERIC(12,2) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Insertar cuentas Ana y Luis con saldo inicial
INSERT INTO cuentas (id, nombre, saldo) VALUES
(1, 'Ana', 500.00),
(2, 'Luis', 300.00);




SELECT COUNT(*) FROM tickets;
SELECT * FROM tickets;
SELECT * FROM cuentas;
SELECT * FROM movimientos;






-- Ejemplo de un procecdimiento con un for
CREATE OR REPLACE PROCEDURE ejemplo_for (n INT)
AS $$
    BEGIN -- Aqui es como si huberia un BEGIN TRANSACTION invisible (por default)
        IF n<0 THEN -- Aqui se indica que n no debe ser negativo
            RAISE NOTICE 'n no puede ser negativo';
            RETURN;
        END IF;

        FOR i IN 1..n LOOP -- un for que se ejecuta n veces dado un argumento por el usuario
            RAISE NOTICE 'i=%', i; -- esto es un tipo de printf y siempre debe ir NOTICE
            -- Aqui ya puede ir lo que sea 
            --SELECT
            --UPDATE
            --INSERT
        END LOOP;
    END -- Aqui se hace un COMMIT invisible (por default)

$$ LANGUAGE plpgsql;

CALL ejemplo_for(5);








-- Ejercicio: hacer un procedimiento que genere tickets dado un entero
CREATE OR REPLACE PROCEDURE generar_tickets (n INT)
AS $$
    BEGIN
        IF n<0 THEN
            RAISE NOTICE 'n no puede ser negativo';
            RETURN;
        END IF;

        FOR i IN 1..n LOOP -- un for que se ejecuta n veces dado un argumento por el usuario
            INSERT INTO tickets(vendido) VALUES(FALSE);
            -- Usualmente se quiere controlar cuando hacer el commit
            -- En casos extremos cuando hay inserciones del orden de billones
            -- Ejemplo:
            IF n%100 = 0 THEN
                COMMIT; -- Aqui se puede invocar el commit para controlar en que momento se guardan los cambios
                -- Por ejemplo si se insertaron 100 bloques, guarda los cambios
            END IF;
        END LOOP;
    END

$$ LANGUAGE plpgsql;

CALL generar_tickets(5);


SELECT COUNT(*) FROM tickets;
SELECT * FROM tickets;




-- Ejemplo de segundo tipo de for

CREATE OR REPLACE PROCEDURE ejemplo_for_dos ()
AS $$
    DECLARE
        renglon RECORD; --variable para almacenar temporalmente un renglon
        -- RECORD es un tipo de dato que representa un renglon
    BEGIN
        FOR renglon IN SELECT * FROM tickets LOOP-- se piden todas las columnas y se guarda en esa variable
            RAISE NOTICE 'id=%, vendido=%',renglon.id, renglon.vendido; -- se imprime el id 
        END LOOP;
    END
$$ LANGUAGE plpgsql;

CALL ejemplo_for_dos();




-- Ejemplo del while
CREATE OR REPLACE PROCEDURE ejemplo_while ()
AS $$
    BEGIN
        WHILE i<=n LOOP
            RAISE NOTICE 'i=%',i;
            i:=i+1; -- esto se usa para decir que cuente de 1 en 1, de 2 en 2, de 3 en 3 etc
        END LOOP;
    END
$$ LANGUAGE plpgsql;



-- Ejercicio hacer un procedimiento que reciba un id_cuenta y monto_movimiento y genere un insert en la tabla movimiento y actualice el saldo de dicha cuenta

CREATE OR REPLACE PROCEDURE registrar_movimiento(
    id_cuenta_movimiento INT,
    monto_movimiento FLOAT
)
AS $$
    DECLARE
        saldo_actual FLOAT;
    BEGIN
        SELECT saldo INTO saldo_actual FROM cuentas WHERE id= id_cuenta_movimiento; -- se consulta el saldo actual
        INSERT INTO movimientos(id_cuenta,monto) VALUES (id_cuenta_movimiento, monto_movimiento); -- se genera la insercion con la informacion que se esta pasando
        UPDATE cuentas SET saldo = saldo_actual + monto_movimiento WHERE id= id_cuenta_movimiento; -- se actualiza el saldo de la cuenta
    END
$$ LANGUAGE plpgsql;

CALL registrar_movimiento(1,100);