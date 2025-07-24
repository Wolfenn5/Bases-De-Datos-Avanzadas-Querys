use tienda;
db.ventas.drop();
db.ventas.insertMany([
  { producto: "Libro", precio: 150, cantidad: 2, vendedor: "Ana", fecha: ISODate("2025-01-10") },
  { producto: "Libro", precio: 200, cantidad: 1, vendedor: "Carlos", fecha: ISODate("2025-02-15") },
  { producto: "Mouse", precio: 300, cantidad: 3, vendedor: "Ana", fecha: ISODate("2025-02-10") },
  { producto: "Laptop", precio: 12000, cantidad: 1, vendedor: "Carlos", fecha: ISODate("2025-03-05") }
]);

db.ventas.find().pretty();

//Ejemplo de operaciones de agregación
print("Inicia agregación:")
db.ventas.aggregate([
  {
    $match:{ // match es una operacion de agregado de tipo filtro
      precio:{$gte:100}
    }
  },
  // fase de proyección ($project)
  {
    $project:{ // similar a la proyección del find
      _id:0,
      producto:1,
      precio:1,
      cantidad:1,
      // $ es el operador de referencia
      copia_cantidad:"$cantidad",
      total_venta: {
        $multiply:["$precio","$cantidad"]
      }
    }
  },
  // Fase addFields
  {
    $addFields:{
      sucursal:"Cuajimalpa"
    }
  },
  // Fase de group
  {
    // SELECT * FROM productos
    // GROUP BY producto
    $group:{
      // IMPORTANTE: _id no es lo mismo
      // que el _id que te regresa el find()
      // es solo un alias para indicar
      // que campos se van a usar para agrupar
      _id:"$producto",
      //sumamos cantidad de todos
      // los documentos similares por campo producto
      total_cantidad:{
        $sum:"$cantidad"
      },
      total_ventas:{
        $sum:"$total_venta"
      },
      promedio_ventas:{
        $avg:"$total_venta"
      },
      total_docs:{
        $sum:1
      }
    }
  },{ // Fase de ordenamiento
    $sort:{
      total_ventas:1, //1 = desc , -1 asc
      promedio_ventas:1
    }
  },{ // Fase de limit 
    $limit:2
  }
]).pretty();







// ----------------------EJERCICIO----------------------------


use plataformaCursos;

db.inscripciones.drop();
db.inscripciones.insertMany([
  {
    estudiante: "Luis",
    curso: "MongoDB Básico",
    categoria: "Bases de Datos",
    horas: 10,
    calificacion: 90,
    fecha_inscripcion: ISODate("2025-03-01")
  },
  {
    estudiante: "Ana",
    curso: "MongoDB Básico",
    categoria: "Bases de Datos",
    horas: 10,
    calificacion: 85,
    fecha_inscripcion: ISODate("2025-03-05")
  },
  {
    estudiante: "Pedro",
    curso: "HTML y CSS",
    categoria: "Desarrollo Web",
    horas: 8,
    calificacion: 78,
    fecha_inscripcion: ISODate("2025-02-20")
  },
  {
    estudiante: "Laura",
    curso: "JavaScript Intermedio",
    categoria: "Desarrollo Web",
    horas: 12,
    calificacion: 88,
    fecha_inscripcion: ISODate("2025-03-10")
  },
  {
    estudiante: "Carlos",
    curso: "Python Básico",
    categoria: "Programación",
    horas: 15,
    calificacion: 95,
    fecha_inscripcion: ISODate("2025-03-03")
  },
  {
    estudiante: "Sofía",
    curso: "Python Básico",
    categoria: "Programación",
    horas: 15,
    calificacion: 80,
    fecha_inscripcion: ISODate("2025-01-15")
  }
]);

// Ejercicio: 
// Calcular el promedio de calificación
// y total de horas inscritas por categoría 
// para el mes de marzo 2025.
db.inscripciones.aggregate([
  {
    $match:{
      fecha_inscripcion: {
        // DELIMITAMOS PARA EL MES DE MARZO
        $gte:ISODate("2025-03-01"),
        $lte:ISODate("2025-03-31"),
      }
    }
  },
  {
    $group:{
      // AGRUPAMOS POR CATEGORIA
      _id:"$categoria",
      // CALCULAMOS EL TOTAL DE HORAS CON $sum
      total_horas:{
        $sum:"$horas"
      },
      // CALCULAMOS EL PROMEDIO DE CALIFICACION CON $avg
      promedio_calificacion:{
        $avg:"$calificacion"
      }
    }
  }
]).pretty();