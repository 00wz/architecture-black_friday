#!/bin/bash

echo ">>> Количество документов на shard1:"
docker exec shard1 mongosh --port 27018 --quiet --eval '
use("somedb");
print(db.helloDoc.countDocuments());
'

echo ">>> Количество документов на shard2:"
docker exec shard2 mongosh --port 27019 --quiet --eval '
use("somedb");
print(db.helloDoc.countDocuments());
'
