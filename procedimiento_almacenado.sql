DROP TABLE IF EXISTS cuentas;
CREATE TABLE cuentas (
  id SERIAL PRIMARY KEY,
  saldo INT
);

INSERT INTO cuentas (saldo) VALUES (100), (200);

SELECT * FROM cuentas;




CREATE OR REPLACE PROCEDURE actualizar_saldo(
    id_actualizar INT,
    saldo_actualizar FLOAT
)
AS $$
    BEGIN
        UPDATE cuentas SET saldo=saldo_actualizar WHERE id= id_actualizar;
    END
$$ LANGUAGE plpgsql;



-- Cuando es un procedimiento no se utiliza SELECT y en su lugar se usa CALL
CALL actualizar_saldo(1,1000);