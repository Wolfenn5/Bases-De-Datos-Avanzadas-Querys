# Ejemplo de un collab para utilizar mongo con la pagina web y python


"""
Instalar mongo para python. En colab se pone el ! pero de forma local no
!pip install pymongo
"""


# Esto es un comentario de Python
"""
Esto es una cadena de
múltiples líneas
aquí otro renglón
"""
# importamos la librería mongo que previamente instalamos
from pymongo import MongoClient
# librerias para dar formato a json y bson
import json
import bson

def imprimir_bonito(documentos):
  # hacemos que se imprima bonito:
  print(json.dumps(json.loads(bson.json_util.dumps(documentos)),indent=2))


# URI = Uniformed Resource Identifier
uri = "TU URL DE CONEXIÓN AQUÍ"
cliente = MongoClient(uri)
db = cliente["simpsons"]

# lo que regresa pymongo es un objeto iterable
documentos = list(db.personajes.find())
for documento in documentos:
  print(documento)

imprimir_bonito(documentos)

documentos = db.personajes.aggregate([
    {
        "$lookup":{
            "from":"trabajos",
            "localField":"trabajos_ids",
            "foreignField":"_id",
            "as":"trabajos"
        }
    }
])
print("resultado agregación:")
imprimir_bonito(documentos)

# ejercicio:
# mostrar los personajajes cuya edad sea estricamente mayor o igual a 40
documentos = db.personajes.find({
    "edad":{
        "$gte":40
    }
})
print("personajes con edad mayor o igual a 40")
imprimir_bonito(documentos)

