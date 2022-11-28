#!/bin/bash

cd /shared
docker compose -f docker-compose-redis.yml up -d
grep -v "redis" "/etc/hosts" > tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis0) redis0 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis1) redis1 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis2) redis2 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis3) redis3 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis4) redis4 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis5) redis5 >> tmp_hosts
sudo mv tmp_hosts /etc/hosts
cd ycsb-0.17.0
./bin/ycsb load redis -s -P workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > /results/loadRedis1.txt
./bin/ycsb load redis -s -P workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > /results/loadRedis2.txt
./bin/ycsb load redis -s -P workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > /results/loadRedis3.txt
cd ..
docker compose -f docker-compose-redis.yml down

echo ""
echo "======= RESULTS LOAD 1 ======="
cat /results/loadRedis1.txt
echo ""
echo "======= RESULTS LOAD 2 ======="
cat /results/loadRedis2.txt
echo ""
echo "======= RESULTS LOAD 3 ======="
cat /results/loadRedis3.txt