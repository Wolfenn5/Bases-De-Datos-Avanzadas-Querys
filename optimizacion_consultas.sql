-- Parsing: postgresql analiza la sintaxis de la consulta

-- Hay que evitar traer columnas necesarias para optimizar consultas como SELECT * FROM usuarios;
-- Es mejor SELECT id,nombre,email FROM usuarios; solo las necesarias
-- o utilizar limits SELECT id,nombre,email FROM usuarios ORDER BY fecha_creacion DESC LIMIT 10; y traer pocos renglones nadamas

-- orden de condiciones en WHERE como: WHERE: SELECT * FROM usuarios WHERE estado = 'activo' AND edad>30 AND pais='Mexico'; para filtrar de forma secuencial, las condiciones mas selectivas ayudan a descartar filas anteriores

