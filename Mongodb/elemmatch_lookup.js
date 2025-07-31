// Recordando que no es muy recomendable usar una tabla con cada id en estas BD no relacionales
// aunque se tenga informacion redundante, es mejor tener las colecciones saturadas de informacion
// los JOINS no son muy recomendables en las NO RELACIONALES



db.alumnos.drop();
db.alumnos.insertMany([
  {
    nombre: "Homero Simpson",
    idiomas: [
      { idioma: "inglés", nivel: "básico", fecha_certificacion: ISODate("2022-05-15T00:00:00Z") },
      { idioma: "español", nivel: "nativo", fecha_certificacion: ISODate("1970-01-01T00:00:00Z") }
    ]
  },
  {
    nombre: "Lisa Simpson",
    idiomas: [
      { idioma: "inglés", nivel: "avanzado", fecha_certificacion: ISODate("2024-01-10T00:00:00Z") },
      { idioma: "francés", nivel: "intermedio", fecha_certificacion: ISODate("2023-11-20T00:00:00Z") }
    ]
  },
  {
    nombre: "Bart Simpson",
    idiomas: [
      { idioma: "inglés", nivel: "intermedio", fecha_certificacion: ISODate("2023-06-01T00:00:00Z") },
      { idioma: "alemán", nivel: "básico", fecha_certificacion: ISODate("2023-04-15T00:00:00Z") }
    ]
  },
  {
    nombre: "Marge Simpson",
    idiomas: [
      { idioma: "italiano", nivel: "avanzado", fecha_certificacion: ISODate("2022-10-10T00:00:00Z") },
      { idioma: "inglés", nivel: "intermedio", fecha_certificacion: ISODate("1970-01-01T00:00:00Z") }
    ]
  }
]);




// ---------------------------- ELEMENT MATCH ----------------------------

// Este en si no es bueno porque no aplica una AND, busca en los objetos que coincida ingles y ademas avanzado sin importar si el primero se cumple o no
// si que imprimiria algo que sea ingles sin importar el nivel y aalgo que sea avanzado sin importar el idioma, solo que ooincidan
print("sin elemMatch:")
db.alumnos.find({
  "idiomas.idioma":"inglés",
  "idiomas.nivel":"avanzado",
}).pretty();



// Con element match
print("con elemMatch:")
db.alumnos.find(
{
  "idiomas": // buscar en el arreglo idiomas
  {
       $elemMatch: // que coincida ingles y ademas avanzado
       {
          "idioma":"inglés",
          "nivel":"avanzado"
       }
  }
}).pretty();




// Con match de agregacion tambien se puede hacer un element match
print("con agregado:");
db.alumnos.aggregate([{ // va con corchete y llaves porque es un arreglo de objetos
  $match:
  {
   "idiomas":
   {
       $elemMatch:
       {
          "idioma":"inglés",
          "nivel":"avanzado"
       }
    }
  }
}
]).pretty();









// ---------------------------- LOOKUP ----------------------------

// Este en si es una especie de JOIN que solo implemento mongodb como una especie de opcion
// en si no es muy recomendable usarlo, si se usa mucho es un indicativo que lo mejor seria usar una BD relacional

// Insertar personajes
db.personajes.drop();
db.personajes.insertMany([
  { _id: 1, nombre: "Homero Simpson", edad: 39, trabajos_ids: [101, 102, 105] },
  { _id: 2, nombre: "Lenny Leonard", edad: 40, trabajos_ids: [103] },
  { _id: 3, nombre: "Carl Carlson", edad: 41, trabajos_ids: [104] }
]);

// Insertar trabajos
db.trabajos.drop();
db.trabajos.insertMany([
  { _id: 101, trabajo: "Inspector de seguridad", empresa: "Planta Nuclear" },
  { _id: 102, trabajo: "Bartender", empresa: "Taberna de Moe" },
  { _id: 103, trabajo: "Ingeniero en Planta Nuclear", empresa: "Planta Nuclear" },
  { _id: 104, trabajo: "Supervisor en Planta Nuclear", empresa: "Planta Nuclear" },
  { _id: 105, trabajo: "Astronauta", empresa: "NASA" }
]);









print("resultado lookup:");
db.personajes.aggregate(
[

{
  $lookup:
  {
    from:"trabajos", // la otra colección (foránea) con la que vamos hacer el pegado "JOIN"
    localField:"trabajos_ids", // el campo de ESTA colección (personajes) indicada al inicio en .agreggate
    // que me relaciona esta colección con la OTRA colección (foránea)?  El id es el que une a las 2 colecciones
    foreignField:"_id",  // el campo de la colección foránea que se relaciona con esta colección
    as:"historial_trabajos" // alias para el arreglo del resultado final
  }
},



{
  $project: // proyecta (o no) las siguientes:
  {
    _id:0,
    nombre:1,
    historial_trabajos:1
    // Los siguientes si se quieren ver (o no) los datos del nuevo agregado
    // historial_trabajos._id:0
    // historial_trabajos.trabajo:1
    // historial_trabajos.empresa:0
  }
}

]).pretty();













// EJERCICIO LOOKUP

// Crear colección de personajes
db.personajes.drop();
db.personajes.insertMany([
  { _id: 1, nombre: "Lisa Simpson", hobbies_ids: [201, 202] },
  { _id: 2, nombre: "Bart Simpson", hobbies_ids: [203, 205] },
  { _id: 3, nombre: "Milhouse Van Houten", hobbies_ids: [203] }
]);

// Crear colección de hobbies
db.hobbies.drop();
db.hobbies.insertMany([
  { _id: 201, nombre: "Tocar el saxofón", tipo: "musical" },
  { _id: 202, nombre: "Leer", tipo: "intelectual" },
  { _id: 203, nombre: "Andar en patineta", tipo: "deportivo" },
  { _id: 205, nombre: "Cosplay de El Barto", tipo: "creativo" }
]);

// Ejercicio: mostrar cada personaje con su lista de hobbies
//             solo muestren el nombre y la lista de hobbites
//             y mostras sólo las personas que tengan un hobbie de tipo
//             musical



db.personajes.aggregate([{
  $lookup:
  {
    from:"hobbies",
    localField:"hobbies_ids",
    foreignField:"_id",
    as:"lista_hobbies"
  }  
},{
  $project:
  {
    _id:0,
    nombre:1,
    lista_hobbies:1
  }
},{
  $match:
  {
    "lista_hobbies.tipo":"musical"
  }
}
]).pretty();