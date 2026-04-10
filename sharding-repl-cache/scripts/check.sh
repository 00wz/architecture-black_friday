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

echo ""
echo ">>> Демонстрация эффективности кэширования:"
API_URL="http://localhost:8080/helloDoc/users"

echo -n "  1-й вызов (без кэша): "
time1=$(curl -o /dev/null -s -w "%{time_total}" "$API_URL")
echo "${time1}s"

echo -n "  2-й вызов (из кэша):  "
time2=$(curl -o /dev/null -s -w "%{time_total}" "$API_URL")
echo "${time2}s"
