-- Crear tabla padre 'persona' con columnas comunes
CREATE TABLE persona (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    edad INT
);

-- Postgres, oracle, IBM, informix son bases de datos relacionales pero soportan una "nocion" de herencia de objetos
-- Como tablas padres e hijas



-- En esencia un empleado es una persona
CREATE TABLE empleado(
    sueldo FLOAT,
    especialidad VARCHAR
)INHERITS(persona); -- se heredan las columnas de la tabla persona 

SELECT * FROM persona;
SELECT * FROM empleado;

INSERT INTO persona(nombre,edad) 
	VALUES ('Homero Simpson',39);

INSERT INTO persona(nombre,edad) 
	VALUES ('Marge Simpson',39);

-- Si se hace asi, se podria pensar que solo se inserta en empleados
-- pero tambien de forma sutil se va a insertar en la tabla personas (la tabla de la ue se heredo)
-- Si no se ponen los campos de la tabla heredada, por ejemplo nombre y edad
-- en la tabla personas esos campos se van a llenar como NULL
INSERT INTO empleado(nombre,edad,sueldo,especialidad)
    VALUES ('Lenny',38,2000, 'Tecnico Nuclear');


-- El mecanismo de herencia solo permite heredar columnas
-- NO SE PUEDEN HEREDAR RESTRICCIONES (CONSTRAINTS, TRIGGERS)
-- EJEMPLO:
ALTER TABLE persona ADD CONSTRAINT persona_nombre_unico UNIQUE (nombre); -- con esta instruccion se dice que el campo nombre no debe tener valores repetidos
-- Cuando se usa PRIMARY KEY de forma discreta se hace asi, ademas que sea NOT NULL

-- Este query debe dar error por la restriccion de arriba pero solo para la tabla persona
INSERT INTO persona(nombre,edad) 
	VALUES ('Homero Simpson',39);


-- Entonces como las restricciones no se heredan, si se inserta en empleados si lo va a aceptar
INSERT INTO empleado(nombre,edad,sueldo,especialidad)
    VALUES ('Lenny',20,50, 'Supervisor Nuclear');


SELECT * FROM ONLY persona; -- solo muestra los de la tabla padre es decir solo los inserts de persona


-- Es importante que si en las tablas ya hay campos repetidos y se quiere agregar un constraint, no va a dejar porque ya hay valores repetidos
-- Habria que cambiar los valores a mano y despues hacer el contraint






-- ----- EJERCICIO ----------
-- 1. Crear la tabla padre 'vehiculo' con columnas comunes para todos los vehículos:
--    id (clave primaria autoincremental), marca, modelo y año.
CREATE TABLE vehiculo (
    id SERIAL PRIMARY KEY,
    marca VARCHAR(100),
    modelo VARCHAR(100),
    año INT
);


-- 2. Crear la tabla hija 'camion' que hereda de 'vehiculo' y añade columnas específicas:
--    capacidad_toneladas y numero_ejes.
CREATE TABLE camion(
    capacidad_toneladas FLOAT,
    numero_ejes INT
)INHERITS(vehiculo); -- se heredan las columnas de la tabla vehiculo


-- 3. Crear la tabla hija 'auto' que hereda de 'vehiculo' y añade columnas específicas:
--    tipo_carroceria y numero_puertas.
CREATE TABLE autos(
    tipo_carroceria VARCHAR(100),
    numero_puertas INT
)INHERITS(vehiculo); -- se heredan las columnas de la tabla vehiculo

-- 4. Insertar un registro en cada tabla (vehiculo,camion y auto)
INSERT INTO vehiculo(marca,modelo,año)
    VALUES ('Chevrolet','Aveo',2000);

INSERT INTO camion(marca,modelo,año,capacidad_toneladas,numero_ejes)
    VALUES ('Mercedes','3',2020,100,6);

INSERT INTO autos(tipo_carroceria,numero_puertas)
    VALUES ('Sedan',4); -- Este va a tener valores NULL en la tabla vehiculo y campos marca, modelo, año

-- 5. Consultar todos los renglones de cada tabla.
SELECT * FROM vehiculo;
SELECT * FROM camion;
SELECT * FROM autos;

SELECT * FROM ONLY vehiculo;


