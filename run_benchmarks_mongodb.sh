#!/bin/bash

cd /shared
docker compose -f docker-compose-mongodb.yml up -d
grep -v "mongo1\|mongo2\|mongo3" "/etc/hosts" > tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongo1) mongo1 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongo2) mongo2 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongo3) mongo3 >> tmp_hosts
sudo mv tmp_hosts /etc/hosts
cd ycsb-0.17.0
./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set > /results/loadMongo1.txt
./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set > /results/loadMongo2.txt
./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set > /results/loadMongo3.txt
cd ..
docker compose -f docker-compose-mongodb.yml down

echo ""
echo "======= RESULTS LOAD 1 ======="
cat /results/loadMongo1.txt
echo ""
echo "======= RESULTS LOAD 2 ======="
cat /results/loadMongo2.txt
echo ""
echo "======= RESULTS LOAD 3 ======="
cat /results/loadMongo3.txt