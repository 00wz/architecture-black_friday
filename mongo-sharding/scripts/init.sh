#!/bin/bash
set -e

# Инициализация config server replica set
echo ">>> Инициализация config server..."
docker exec configSrv mongosh --port 27017 --quiet --eval '
rs.initiate({
  _id: "config_server",
  configsvr: true,
  members: [
    { _id: 0, host: "configSrv:27017" }
  ]
});
'

echo ">>> Ожидание выбора primary в config_server..."
sleep 5

# Инициализация shard1 replica set
echo ">>> Инициализация shard1..."
docker exec shard1 mongosh --port 27018 --quiet --eval '
rs.initiate({
  _id: "shard1",
  members: [
    { _id: 0, host: "shard1:27018" }
  ]
});
'

echo ">>> Ожидание выбора primary в shard1..."
sleep 5

# Инициализация shard2 replica set
echo ">>> Инициализация shard2..."
docker exec shard2 mongosh --port 27019 --quiet --eval '
rs.initiate({
  _id: "shard2",
  members: [
    { _id: 0, host: "shard2:27019" }
  ]
});
'

echo ">>> Ожидание выбора primary в shard2..."
sleep 5

# Добавление шардов через роутер
echo ">>> Добавление шардов в кластер..."
docker exec mongos_router mongosh --port 27020 --quiet --eval '
sh.addShard("shard1/shard1:27018");
sh.addShard("shard2/shard2:27019");
'

# Включение шардинга и создание шардированной коллекции
echo ">>> Настройка шардинга для базы somedb..."
docker exec mongos_router mongosh --port 27020 --quiet --eval '
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name": "hashed" });
'

# Вставка тестовых данных
echo ">>> Вставка тестовых данных..."
docker exec mongos_router mongosh --port 27020 --quiet --eval '
use("somedb");
for (var i = 0; i < 1000; i++) {
  db.helloDoc.insertOne({ age: i, name: "ly" + i });
}
print("Документов в коллекции: " + db.helloDoc.countDocuments());
'

echo ">>> Инициализация завершена!"
