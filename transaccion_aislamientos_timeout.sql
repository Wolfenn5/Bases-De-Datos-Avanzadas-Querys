-- Atributos configurables de una transaccion

-- Timeout: tiempo maximo que puede durar una transaccion
-- Nivel de aislamiento: indica el nivel de bloqueo que tendra la tabla a causa de una transaccion
  -- dirty readsa (lecturas sucias)
  -- non repeatable reads (lecturas no repetibles)
  -- phantom reads (lecturas fantasmas)

-- Mientras mas restrictivo es el aislamiento en un sistema, mas impacto tiene el performance del sistema



DROP TABLE IF EXISTS cuentas;
CREATE TABLE cuentas (
  id SERIAL PRIMARY KEY,
  saldo INT
);

INSERT INTO cuentas (saldo) VALUES (100), (200);

SELECT * FROM cuentas;



-- Ejemplo de timeout
---->  SET statement timeout='3s' j
--s: segundos
ROLLBACK; -- por si hay que deshacer una transaccion

SET STATEMENT_TIMEOUT='2s'; -- establecer el tiempo que tardara una transaccion
-- SET STATEMENT_TIMEOUT='0s';  -- no es que tarde 0 segundos, mas bien hace que el tiempo sea indefinido y la transaccion tarde todo lo que quiera
-- Si la transaccion tarda mas de esos 2 segundos, la transacicon se marcara como invalida
BEGIN TRANSACTION; -- Si solo se pone BEGIN (fuera del contexto de funciones, se entendera como transaccion)
SELECT pg_sleep(3); -- simular una operacion que tarda 3 segundos
COMMIT;


-- Ejemplo lectura no repetible (mal, es decir no deberia de pasar)
-- Transaccion A
BEGIN TRANSACTION;
UPDATE cuentas SET saldo=300 WHERE id=1;
SELECT * FROM cuentas;
COMMIT;
-- Transaccion B (en otra ventana de query tool)
BEGIN TRANSACTION;
SELECT saldo FROM cuentas WHERE id=1;
COMMIT;
-- Si se hacen a la vez, la transacicon B al inicio leera un valor, se hace la transaccion A y al hacer el select de la transaccion B, leera otro valor completamente diferente. NO debe ser asi porque hay inconsitencia


-- Ejemplo lectura no repetible (buena, con nivel de aislamiento)
-- Transaccion A
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
UPDATE cuentas SET saldo=500 WHERE id=1;
SELECT * FROM cuentas;
COMMIT;
-- Transaccion B (en otra ventana de query tool)
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT saldo FROM cuentas WHERE id=1;
-- en este momento se hizo la transaccion A pero al hacer la query en la B sale 300
SELECT saldo FROM cuentas WHERE id=1; -- aunque ya se actualizo en la A a 500, en esta query sigue saliendo 300




-- Ejemplos de niveles de aislamiento
---> READ UNCOMMITED: sin aislamiento (no permitido en postgresql). En si este no deberia de usarse porque elimina el aislamiento en filosofia ACID


---> READ COMMITED: impide lecturas sucias
-- BEGIN TRANSACTION READ COMMITED; -- si solo se pone BEGIN TRANSACTION, por default es un READ COMMITTED
-- -- codigo
-- COMMIT;


---> REPEATABLE READ: impide lecturas sucias y lecturas no repetibles
-- BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- -- codigo
-- COMMIT;


---> SERIAZABLE: impide lecturas sucias, lecturas no repetibles y lecturas fantasmas. Este tipo de aislamiento, bloquea toda la tabla
-- BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- -- codigo
-- COMMIT;