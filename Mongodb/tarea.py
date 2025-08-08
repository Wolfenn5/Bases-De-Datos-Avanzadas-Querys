from pymongo import MongoClient
from pprint import pprint
import json

"""
Version de comunidad en macos sillicon:

brew tap mongodb/brew
brew install mongodb-community
"""




"""
En mongo para ver y eliminar la bd directamente sin meterse en el script:


mongosh
show dbs
use universidad
db.dropDatabase()
"""

# Nota: Activar antes el entorno de conda 

# la funcion pprint de python es pretty print, solo es para imprimir "mas bonito" las colecciones (json) y no se vea todo en una sola linea
# y se utiliza en los obetos iterables PERO de python, asi se evita el json.dumps, indent etc

# ----------------- 1.-CONFIGURACION DE CONEXION EN LOCAL --------------------------
# Conectarse a mongo de forma local
client= MongoClient('mongodb://localhost:27017/') # puerto por defecto (como el de mysql)
db= client['tareaBD']


# Eliminar las colecciones desde el script y no irse a otra terminal con mongosh
db.estudiantes.drop()
db.cursos.drop()




# ----------------- 2.-CARGAR LOS ARCHIVOS --------------------------
with open('estudiantes_tarea.txt', 'r', encoding='utf-8') as file:
    estudiantes_data= json.load(file) # en json 
    db.estudiantes.insert_many(estudiantes_data)


with open('cursos_tarea.txt', 'r', encoding='utf-8') as file:
    cursos_data= json.load(file) # en json 
    db.cursos.insert_many(cursos_data)





# ----------------- 3.-CONSULTAS DE ESTUDIANTES--------------------------
print("-------------------------- Consultas estudiantes --------------------------")

# 3.1. Estudiantes mayores de 21 años
print("\n 3.1. Estudiantes mayores de 21 años:\n")
mayores_21= db.estudiantes.find({"edad": {"$gt": 21}})
for estudiante in mayores_21:
    pprint(estudiante)


# 3.2. Estudiantes de ingenieria
print("\n\n\n 3.2. Estudiantes de Ingenieria:\n")
ingenieria= db.estudiantes.find({"carrera": "Ingeniería"})
for estudiante in ingenieria:
    pprint(estudiante)


# 3.3. Promedio de notas por estudiante en orden descendente
print("\n\n\n 3.3. Promedio de notas por estudiante (orden descendente):\n")
pipeline_promedio_estudiantes= [
    {
        "$project": 
        {
            "nombre": 1,
            "edad": 1,
            "carrera": 1,
            "promedio": {"$avg": "$notas"}
        }
    },


    {
        "$sort": {"promedio": -1} # EN SORT: -1 descendete y 1 para ascendente 
    }
]
promedios= db.estudiantes.aggregate(pipeline_promedio_estudiantes)
for estudiante in promedios:
    pprint(estudiante)



# 3.4. Contar estudiantes por carrera
print("\n\n\n 3.4. Cantidad de estudiantes por carrera:\n")
pipeline_estudiantes_por_carrera= [
    {
        "$group": # agrupar por:
        {
            "_id": "$carrera", # al id se le busca que concuerde con ALGO-Carrera (por eso $ para referenciarlo)
            "total": {"$sum": 1} # sumar 1 por cada documento del campo anterior ($carrera)
        }
    }
]
por_carrera= db.estudiantes.aggregate(pipeline_estudiantes_por_carrera)
for carrera in por_carrera:
    pprint(carrera)









# ----------------- 4.-CONSULTAS DE CURSOS --------------------------
# 4. Consultas sobre cursos
print("\n\n\n \n\n-------------------------- Consultas cursos --------------------------")
# 4.1. Todos los cursos disponibles
print("\n4.1. Todos los cursos disponibles:\n")
todos_cursos= db.cursos.find() # mostrar todo, sin filtro ni proyeccion
for curso in todos_cursos:
    pprint(curso)



# 4.2. Cursos con duracion > 35 horas
print("\n\n\n4.2. Cursos con duracion > 35 horas:\n")
cursos_duracion_mayor= db.cursos.find({"duracion": {"$gt": 35}})
for curso in cursos_duracion_mayor:
    pprint(curso)



# 5. -------------------------- Consulta combinada con $lookup ("JOIN") --------------------------
print("\n\n\n5. Consulta lookup estudiantes con cursos asociados:\n")
pipeline_lookup_cursos= [
    {
        # El local se define en el .agreggate, en este caso la coleccion local sera estudiantes
        "$lookup": 
        {
            "from": "cursos",
            # Para hacer el lookup "JOIN" como en las BD relacionales, en las 2 colecciones "tablas" lo que une a las 2 es cursos_id y _id 

            
            "localField": "cursos_ids", # el campo local a hacer "JOIN" con el foraneo que pueden coincidir.
            "foreignField": "_id", # el campo foraneo que concuerda con el local  a hacer "JOIN"
            "as": "cursos" # alias para el arreglo del resultado final
        }
    }
]
estudiantes_con_cursos= db.estudiantes.aggregate(pipeline_lookup_cursos)
for estudiante in estudiantes_con_cursos:
    pprint(estudiante)