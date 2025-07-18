// Mongo db en si lo que usa es javascript

// Ver las BD que se tienen
show dbs;

// Cambia a la base de datos 'springfield' (se crea si no existe)
use springfield;



// Los objetos que se insertan se le llaman "coleccion" entonces:
// personas                  son    -> coleccion
// objetos dentro de persona son    -> documentos



// ---------------------------- PARAMETROS DE FIND-----------------------------------
// El primer parametro es un filtro, un filtro seria algo como un WHERE
// El segundo parametro es la proyeccion, es para delimitar las columnas a mostrar algo tipo: esto si, esto no



// ---------------------------OPERACIONES DE FILTRADO BASICOS-------------------------------
//  gt:  Greater Than       >
//  lt:  less than          <
//  gte: Greater Or Equal  >=
//  lte: Less Than Equal   <=
//  eq:  Equal              =



// 1. Insertar múltiples documentos en la colección 'personajes'
// para varios se utiliza many, si se quiere solo uno entonces se pone 
// insertOne
// Inserta los siguientes personajes con su edad, ocupación y calificación promedio
db.personajes.insertMany([
  { nombre: "Homer Simpson", edad: 39, ocupacion: "Inspector de seguridad", promedio: 6.5 },
  { nombre: "Marge Simpson", edad: 36, ocupacion: "Ama de casa", promedio: 8.7 },
  { nombre: "Bart Simpson", edad: 10, ocupacion: "Estudiante", promedio: 5.2 },
  { nombre: "Lisa Simpson", edad: 8, ocupacion: "Estudiante", promedio: 9.8 },
  { nombre: "Ned Flanders", edad: 60, ocupacion: "Propietario de tienda", promedio: 9.1 },
  { nombre: "Milhouse Van Houten", edad: 10, ocupacion: "Estudiante", promedio: 7.3 }
])



// 2. Consulta todos los personajes
// Muestra todos los documentos de la colección 'personajes'
// find es el equivalente a SELECT de Mysql SELECT * FROM personas
db.personajes.find({},{});




db.personajes.find({},{nombre:1}); // aqui se muestra la columna nombre y el 1 indica que se quiere mostrar, si tiene un 0 se indica que no se quiere mostrar
db.personajes.find({},{nombre:1,_id:0}); // aqui se indica que no se quiere ver el campo _id



// 3. Buscar personajes con la ocupación "Estudiante"
// Muestra todos los personajes cuya ocupación sea exactamente "Estudiante"
// se usa el filtro, como si fuera un WHERE ocupacion= "Estudiante"
print("solucion 3:")
db.personajes.find({
  ocupacion:"Estudiante" // equivalente a   ocupacion: {$eq:"Estudiante"}
});



// 4. Buscar personajes con promedio mayor a 8
// Muestra todos los personajes con promedio superior a 8.0
// se usa el filtro como un WHERE promedio>8
print("solución 4:");
db.personajes.find({
  promedio:{$gt:8} // gt: Greater Than (mayor que) 
});




// 5. Actualizar el promedio de Bart Simpson a 6.5
// Actualiza el campo "promedio" del personaje Bart Simpson a 6.5
print("solucion 5:");
db.personajes.updateOne(
  { nombre: "Bart Simpson" },       // filtro
  { $set: { promedio: 6.5 } }       // actualizacion
);



// 6. Eliminar a Milhouse Van Houten de la colección
// Elimina el documento correspondiente a Milhouse Van Houten

print("solucion 6:");
db.personajes.deleteOne({
  nombre: "Milhouse Van Houten" // WHERE nombre = "Milhouse Van Houten"
});



// 7. Contar cuántos personajes hay actualmente
// Muestra cuántos documentos hay actualmente en la colección
print("solucion 7:");
db.personajes.countDocuments({}); // count como en Mysql pero recordando ue lo que esta dentro del objeto Json se llama documentos se usa count documents


