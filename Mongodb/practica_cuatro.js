db.pacientes.drop(); // equivalente a DELETE ALL



db.pacientes.insertMany([
  {
    nombre: "Max",
    especie: "perro",
    raza: "labrador",
    edad: 6,
    peso_kg: 28.5,
    estado: "estable",
    alergias: ["polen"],
    vacunado: true,
    visitas: [ISODate("2025-01-10T10:00:00Z"), ISODate("2025-04-20T09:30:00Z")],
    dueño: {
      nombre: "Laura Fernández",
      telefono: "555-1234",
      direccion: {
        calle: "Av. Siempre Viva 123",
        ciudad: "CDMX"
      }
    },
    historial: [
      {
        fecha: ISODate("2025-01-10T10:00:00Z"),
        diagnostico: "Otitis",
        tratamiento: "Gotas antibióticas"
      },
      {
        fecha: ISODate("2025-04-20T09:30:00Z"),
        diagnostico: "Vacunación anual",
        tratamiento: "Vacuna contra rabia"
      }
    ],
    cirugias: []
  },
  {
    nombre: "Luna",
    especie: "gato",
    raza: "persa",
    edad: 3,
    peso_kg: 4.3,
    estado: "crítico",
    alergias: [],
    vacunado: false,
    visitas: [ISODate("2025-03-15T11:00:00Z")],
    dueño: {
      nombre: "Pedro Martínez",
      telefono: "555-5678",
      direccion: {
        calle: "Calle Sol 45",
        ciudad: "Monterrey"
      }
    },
    historial: [
      {
        fecha: ISODate("2025-03-15T11:00:00Z"),
        diagnostico: "Fractura de fémur",
        tratamiento: "Yeso y reposo"
      }
    ],
    cirugias: [
      {
        tipo: "reparación ósea",
        fecha: ISODate("2025-03-16T08:00:00Z"),
        exitoso: true
      }
    ]
  },
  {
    nombre: "Toby",
    especie: "perro",
    raza: "pug",
    edad: 8,
    peso_kg: 10.2,
    estado: "estable",
    alergias: ["lácteos", "huevo"],
    vacunado: true,
    visitas: [],
    dueño: {
      nombre: "Sandra Gómez",
      telefono: "555-4321",
      direccion: {
        calle: "Av. Reforma 88",
        ciudad: "Guadalajara"
      }
    },
    historial: [],
    cirugias: []
  },
  {
    nombre: "Nina",
    especie: "gato",
    raza: "angora",
    edad: 2,
    peso_kg: 3.5,
    estado: "estable",
    vacunado: false,
    alergias: [],
    visitas: [],
    dueño: {
      nombre: "Luis Robles",
      telefono: "555-0000",
      direccion: {
        calle: "Insurgentes Sur 200",
        ciudad: "CDMX"
      }
    },
    historial: [],
    cirugias: []
  },
  {
    nombre: "Bobby",
    especie: "perro",
    raza: "chihuahua",
    edad: 5,
    peso_kg: 4.9,
    estado: "estable",
    vacunado: true,
    alergias: ["picadura de abeja"],
    visitas: [ISODate("2025-05-01T10:00:00Z")],
    dueño: {
      nombre: "Erika Soto",
      telefono: "555-8888",
      direccion: {
        calle: "Calle Luna 789",
        ciudad: "CDMX"
      }
    },
    historial: [
      {
        fecha: ISODate("2025-05-01T10:00:00Z"),
        diagnostico: "Picadura de insecto",
        tratamiento: "Antialérgico"
      }
    ],
    cirugias: []
  }
])




// Metodo push
db.pacientes.updateOne(
    {nombre:"Max"},
    {$push:{alergias:"nueces"}}
);

db.pacientes.find(
    {nombre:"Max"},
    {}
).pretty();



// cls funciona como un clear


// filtro
// proyeccion          _id:0



// ----------------- 1.-CONSULTAS--------------------------
// 1 Lista mascotas con alergias registradas.
db.pacientes.find(
    {alergias: {$ne:[]}},   // not equal "vacio"
    {_id:0}
).pretty();


// 2 Muestra nombres y ciudades de dueños en "CDMX".
db.pacientes.find(
  {"dueño.direccion.ciudad": "CDMX"},
  {nombre: 1, "dueño.direccion.ciudad": 1, _id: 0}
).pretty();



// 3 Encuentra pacientes con al menos una cirugía.
db.pacientes.find(
    {cirugias: {$ne:[]}},  
    {_id:0}
).pretty();


// 4 Mascotas con peso mayor a 5 kg.
db.pacientes.find(
    {peso_kg: {$gt:5}},
    {_id:0}
).pretty();



// 5 Perros mayores de 5 años.
db.pacientes.find(
    {especie: "perro", edad: {$gt:5}},
    {_id:0}
).pretty();



// 6 Mascotas sin historial médico.
db.pacientes.find(
    {historial: {$eq:[]}}, // igual a "vacio"
    {_id:0}
).pretty();



// 7 Mascotas con más de una entrada en el historial.
db.pacientes.find(
    {historial: {$ne:[]}}, // no igual a "vacio", haya mas de una
    {_id:0}
).pretty();



// 8 Tratamientos y diagnósticos de todo historial.
db.pacientes.find(
  {}, // en el filtro mostrar todo
  { _id: 0, nombre: 1, "historial.diagnostico":1, "historial.tratamiento":1} // en la proyeccion mostrar solo:
).pretty();

// 9 .....


// 10 Pacientes con cirugía tipo "esterilización".
db.pacientes.find(
    {"cirugias": "esterilización"},
    {_id:0}
).pretty();











// ----------------- 2.-ACTUALIZACIONES--------------------------
// Verificar cambios
db.pacientes.find(
    {nombre:"Max"}
).pretty();



// 1 Cambiar estado de "Luna" a "estable".
db.pacientes.updateMany(
  {nombre:"Luna"},                              // filtro
  {                                             // valores a reemplazar usando operador atomico set
    $set:{"estado":"estable"},                  // cambiar el campo estado a estable
  }
);




// 2 Eliminar campo estado de "Toby".
db.pacientes.updateMany(
  {nombre:"Toby"},                              // filtro
  {                                             // valores a reemplazar usando operador atomico set
    $unset:{"estado":""},                       // cambiar el campo estado a "nada"
  }
);



// 3 Agregar alergia "polvo" a "Nina".
db.pacientes.updateMany(
  {nombre:"Nina"},                              // filtro
  {                                             // valores a reemplazar usando operador atomico set
    $push:{alergias:"polvo"},                   // agregar "polvo" al campo alergia
  }
);




// 4 Agregar cirugía a "Max".
db.pacientes.updateMany(
  {nombre:"Max"},                               // filtro
  {                                             // valores a reemplazar usando operador atomico set
    $push:
    {cirugias:
        {                                       // agregar cirugia con los campos tipo,fecha y exitoso
             tipo: "muelas del juicio",
             fecha: new Date(),
             exitoso: true
        }
    }
}
);



// 5 Modificar teléfono del dueño de "Bobby".
db.pacientes.updateMany(
  {nombre:"Bobby"},                              // filtro
  {                                              // valores a reemplazar usando operador atomico set
    $set:{"dueño.telefono":"555-1234"},          // cambiar el campo telefono del dueño del perro bobby
  }
);