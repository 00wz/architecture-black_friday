#!/bin/bash

echo ">>> Количество документов на shard1:"
docker exec shard1-0 mongosh --port 27018 --quiet --eval '
use("somedb");
print(db.helloDoc.countDocuments());
'

echo ">>> Количество документов на shard2:"
docker exec shard2-0 mongosh --port 27019 --quiet --eval '
use("somedb");
print(db.helloDoc.countDocuments());
'

echo ""
echo ">>> Состояние реплик shard1:"
docker exec shard1-0 mongosh --port 27018 --quiet --eval '
const status = rs.status();
const members = status.members;
print("Членов в реплика-сете: " + members.length);
members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
if (members.length !== 3) print("ВНИМАНИЕ: ожидается 3 реплики, найдено " + members.length);
'

echo ""
echo ">>> Состояние реплик shard2:"
docker exec shard2-0 mongosh --port 27019 --quiet --eval '
const status = rs.status();
const members = status.members;
print("Членов в реплика-сете: " + members.length);
members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
if (members.length !== 3) print("ВНИМАНИЕ: ожидается 3 реплики, найдено " + members.length);
'
