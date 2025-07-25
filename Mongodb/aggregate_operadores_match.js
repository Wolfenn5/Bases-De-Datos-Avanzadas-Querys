use tienda;
db.ventas.drop();
db.ventas.insertMany([
  { producto: "Libro", precio: 150, cantidad: 2, vendedor: "Ana", fecha: ISODate("2025-01-10") },
  { producto: "Libro", precio: 200, cantidad: 1, vendedor: "Carlos", fecha: ISODate("2025-02-15") },
  { producto: "Mouse", precio: 300, cantidad: 3, vendedor: "Ana", fecha: ISODate("2025-02-10") },
  { producto: "Laptop", precio: 12000, cantidad: 1, vendedor: "Carlos", fecha: ISODate("2025-03-05") }
]);

db.ventas.find().pretty();


// ---------------- Operadores SOLAMENTE en la FASE DE PROYECCION ----------------
// tambien llamados expresiones y transformaciones

// --> {accion_sumar_restar_etc: {$operador: ["$valor1", "$valor2"]}}


// $add          suma                         --> {$total: {$add: ["$precio", "$impuesto"]}   }
// $substract    resta                        --> {$diferencia: {$substract: ["$precio", "$impuesto"]}   }
// $multiply     multiplica                   --> {$total: {$multiply: ["$precio", "$impuesto"]}   }
// $divide       dividir                      --> {$promedio: {$divide: ["$precio", "$impuesto"]}   }
// $mod          modulo                       --> {$residuo: {$mod: ["$precio", 2]}   }
// $concat       concatena strings            --> {$nombre_completo: {$concat: ["$nombre", " ", "$apellido"]}  }
// $toUpper      convierte a mayusculas       --> {$nombre_mayuscula: {$toUpper: "$nombre"}   }
// $toLower      convierte a minusculas       --> {$nombre_minuscula: {$toLower: "$nombre"}   }





// ---------------- Operadores SOLAMENTE en GROUP ----------------
// tambien llamados operadores de acumulacion


// $sum             suma valores o cuenta documentos
// $avg             promedio de valores
// $min             valor minimo
// $max             valor maximo
// $push            inserta valores en un array (incluye duplicados)
// $addToSet        inserta valores unicos en un array
// $first           primer valor del grupo (segun orden de entrada)
// $last            ultimo valor del grupo
// $stdDevPop       desviacion estandar poblacional
// $stdDevSamp      desviacion estadnar muestral



//Ejemplo de operaciones de agregación
// Va primero la db y luego la coleccion en donde se quiere hacer la agregacion
// match es una operacion de agregado de tipo filtro, es decir va el filtro y luego la proyeccion




print("Inicia agregación:")
db.ventas.aggregate(
[


  // Fase del filtro
// -------------------- MATCH --------------------
// Es solo para mostrar ciertos documentos
  {
    $match: // "que haga match respecto a"
    { 
      precio:{$gte:100} // mayor o igual que 100
    }
  },



  // Fase de proyección 
// -------------------- PROJECT --------------------
// Sirve para mostrar solo ciertos campos de los documentos
// En esta parte se pueden agregar campos pero no real, como un SELECT AS (se muestra una coleccion temporal)
  {
    $project:
    { // similar a la proyección del find
      _id:0,
      producto:1,
      precio:1,
      cantidad:1,
      // $ es el operador de referencia para copiar el valor de la cantidad en el documento
      // si no se pone lo va a interpretar como una cadena
      copia_cantidad:"$cantidad",
      total_venta: {$multiply:["$precio","$cantidad"]} // podria ser incluso "hola" y va a mostrar un documento "virtual" algo como una vista en mysql, NO ES QUE SE AGREGUE EN EL DOCUMENTO REAL
    }
  },



  // Fase addfields
// -------------------- ADDFIELDS --------------------
// Sirve para agregar nuevos campos al documento, hace mas facil indicar que campos extras mostrar, sin necesidad de indicar uno por uno como se hace con project
  {
    $addFields:{sucursal:"Cuajimalpa"}
  },




  // Fase group
// -------------------- GROUP --------------------
// Sirve para hacer operaciones de agrupamiento
  {
    // SELECT * FROM productos GROUP BY producto
    $group:
    {
      // IMPORTANTE: _id no es lo mismo que el _id que te regresa el find()
      // es solo un alias para indicar
      // que campos se van a usar para agrupar
      _id:["$producto"], // con $ para indicar que es el dato y no una cadena

      // sumamos cantidad de todos los documentos similares por campo producto
      total_cantidad:{$sum:"$cantidad"},
      total_ventas:{$sum:"$total_venta"},
      promedio_ventas:{$avg:"$total_venta"},
      total_docs:{$sum:1} // el 1 se va a ir sumando por cada campo proudcto que tenga el mismo valor (libro, laptop)
    }
  },



  // Fase de ordenamiento
// -------------------- ORDER --------------------
// Sirve para ordenar la coleccion
  {
    $sort:
    {
      total_ventas:1, //1 = desc , -1 asc
      promedio_ventas:1
    }
  },



  // Fase de limit
// -------------------- LIMIT --------------------
// Sirve para dar un limite del total de resultados a mostrar
  { 
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
    $match:
    {
      fecha_inscripcion: 
      {
        // DELIMITAMOS PARA EL MES DE MARZO
        $gte:ISODate("2025-03-01"),
        $lte:ISODate("2025-03-31"),
      }
    }
  },


  {
    $group:
    {
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