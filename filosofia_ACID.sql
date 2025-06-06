-- Tabla de cuentas bancarias
DROP TABLE IF EXISTS cuentas;
CREATE TABLE cuentas (
    id SERIAL PRIMARY KEY,
    titular TEXT NOT NULL,
    saldo NUMERIC(10, 2) NOT NULL CHECK (saldo >= 0)
);


-- Tabla de movimientos (registro de transacciones)
DROP TABLE IF EXISTS movimientos;
CREATE TABLE movimientos (
    id SERIAL PRIMARY KEY,
    cuenta_id INT NOT NULL REFERENCES cuentas(id),
    monto NUMERIC(10, 2) NOT NULL,
    fecha TIMESTAMP DEFAULT NOW()
);

-- Insertar cuentas
INSERT INTO cuentas (titular, saldo) VALUES
('Ana Pérez', 1000.00),
('Luis Gómez', 1500.00),
('María Torres', 500.00);

-- Insertar algunos movimientos válidos
INSERT INTO movimientos (cuenta_id, monto) VALUES
(1, -100.00),
(2, 100.00),
(3, -50.00);


SELECT * FROM cuentas ORDER BY id ASC;
SELECT * FROM movimientos;


-- Filosofia ACID "Atomicidad , consistencia, aislamiento, durabilidad"
-- Atomicidad: las transacciones son todo o nada
-- Consistencia: solo se guardan datos validos
-- Aislamiento: las transacciones no se afectan entre si
-- Durabilidad: los datos escritos no se perderan



-- Iniciar una transaccion (Ejemplo de Atomicidad)
BEGIN TRANSACTION;
    INSERT INTO movimientos (cuenta_id,monto) VALUES (1,-900); -- el usuario con id 1 hizo un movimiento de -900 
    -- pero hay que aztualizar el saldo en la tabla cuenta
    UPDATE cuentas SET saldo=saldo-1000 WHERE id=1; --que en realidad no deberia ser valido por el NOT NULL CHECK (saldo >= 0)

    ROLLBACK; -- es para deshacer los cambios si hubo algun error, si esta dentro de una transaccion, todas las instrucciones se van a deshacer esos cambios
COMMIT; -- se hace un commit indicando que ya se acabo la transaccion y "commite" los cambios


-- Ejemplo de aislamiento
BEGIN TRANSACTION;
    INSERT INTO movimientos (cuenta_id,monto) VALUES (2,-50);
    UPDATE cuentas SET saldo=saldo-50 WHERE id=2;
    ROLLBACK;
COMMIT;


