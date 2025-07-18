use testdb


db.pedidos.drop(); // equivalente a DELETE ALL

// tablas -> Colecciones
// campos -> Documentos


db.pedidos.insertMany([
  {
    pedido_id: 1001,
    cliente: {
      cliente_id: "C001",
      nombre: "Ana López",
      correo: "ana@example.com",
      direccion: {
        calle: "Calle 1",
        ciudad: "Ciudad de México",
        codigo_postal: "01000"
      }
    },
    productos: [
      { producto_id: "P001", nombre: "Laptop", cantidad: 1, precio: 15000 },
      { producto_id: "P002", nombre: "Ratón", cantidad: 2, precio: 500 }
    ],
    fecha_pedido: ISODate("2025-07-10T10:00:00Z"),
    fecha_envio: ISODate("2025-07-12T14:30:00Z"),
    notas: "Entrega urgente"
  },
  {
    pedido_id: 1002,
    cliente: {
      cliente_id: "C002",
      nombre: "Luis Pérez",
      correo: "luis@example.com",
      direccion: {
        calle: "Avenida 2",
        ciudad: "Guadalajara",
        codigo_postal: "44100"
      }
    },
    productos: [
      { producto_id: "P003", nombre: "Teclado", cantidad: 1, precio: 800 },
      { producto_id: "P004", nombre: "Monitor", cantidad: 2, precio: 3000 }
    ],
    fecha_pedido: ISODate("2025-07-15T09:15:00Z"),    
    notas: ""
  },
  {
    pedido_id: 1003,
    cliente: {
      cliente_id: "C003",
      nombre: "María Ruiz",
      correo: "maria@example.com",
      direccion: {
        calle: "Carrera 3",
        ciudad: "Monterrey",
        codigo_postal: "64000"
      }
    },
    productos: [
      { producto_id: "P001", nombre: "Laptop", cantidad: 1, precio: 15000 }
    ],
    fecha_pedido: ISODate("2025-07-17T16:45:00Z"),    
    notas: "Cliente VIP"
  }
]);




db.pedidos.find();


// SELECT COUNT (*) FROM pedidos;
db.pedidos.countDocuments({}); 


// Contar usando filtros, fecha_pedido
// SELECT COUNT (*) FROM pedidos WHERE fecha_pedido > "2025-07-15T00:00:00Z";
print("Total documentos con fecha de envio mayor que el dia 15")
db.pedidos.countDocuments(
  {fecha_pedido:{$gte:ISODate("2025-07-15T00:00:00Z")}} // mayor a esta fecha en tiempo universal UTC
); 



// SELECT notas FROM pedidos WHERE id=1002;
// SELECT * FROM pedidos WHERE id=1002; // si se quiere esto se quita la proyeccion es decir  {pedido_id:1,notas:1,_id:0}
db.pedidos.find(
  {pedido_id:{$eq:1002}},        // filtro
  {pedido_id:1, notas:1,_id:0}   // proyeccion
);



// imprimir ciudad de la direccion
db.pedidos.find(
  {},
  {"cliente.nombre":1,"cliente.direccion.ciudad":1,_id:0}     // proyeccion, mostrar el campo cliente y nombre del JSON
).pretty(); // la consulta imprimela bonita (con sangria y formato)






// Hacer un update a UN SOLO documento
// UPDATE FROM pedidos SET correo='valor' WHERE pedido_id=1001;
db.pedidos.updateMany(
  {pedido_id:1001},                             // filtro
  {                                             // valores a reemplazar usando operador atomico set
    $set:{"cliente.correo":"ana@email.com"},    // cambiar el correo del cliente
    $unset:{"cliente.nombre":""}                // eliminar el nombre del cliente
  }
);
// Verificar que se haya hecho esa actualizacion
db.pedidos.find(
  {pedido_id:1001}
).pretty();



// Mostrar pedidos que NO tienen campo fecha_envio
print("Pedidos sin enviar:")
db.pedidos.find(
  {"fecha_envio":{$exists:false}}, // ver los pedidos que su campo fecha_envio NO existan (aun no se envian)
  {}
).pretty();