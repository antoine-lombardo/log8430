#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Variables
workload=$1
attempt=$2
load_file=$3
run_file=$4

if test -z "$load_file" 
then
      load_file=/results/redis_${workload}_${attempt}_load.txt
fi
if test -z "$run_file" 
then
      run_file=/results/redis_${workload}_${attempt}_run.txt
fi

echo ""
echo ""
echo "| =============================== |"
echo "|         REDIS BENCHMARK         | "
echo "|           WORKLOAD  $workload           |"
echo "|            ATTEMPT $attempt            |"
echo "| =============================== |"
echo ""

# Do some cleaning
echo "Cleaning Docker files..."
docker stop `docker ps -qa`              > /dev/null 2>&1
docker rm `docker ps -qa`                > /dev/null 2>&1
docker rmi -f `docker images -qa `       > /dev/null 2>&1
docker volume rm $(docker volume ls -q)  > /dev/null 2>&1
docker network rm `docker network ls -q` > /dev/null 2>&1
echo "-> Done."

# Start the containers
cd "$SCRIPT_DIR"
echo "Starting Docker Compose..."
docker compose -f docker-compose-redis.yml up -d > /dev/null 2>&1
echo "-> Done."

# Wait for the cluster to run
echo "Waiting for the cluster to be created..."
docker logs -f redis6 2>&1 | grep -m 1 'Cluster correctly created' > /dev/null 2>&1
sleep 5
echo "-> Done."

# Start the benchmark
echo "Loading the benchmark..."
cd ../ycsb-0.17.0
./bin/ycsb load redis -s -P workloads/workload$workload -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > $load_file 2>&1
echo "-> Done."
echo "Running the benchmark..."
./bin/ycsb run redis -s -P workloads/workload$workload -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > $run_file 2>&1
cd ..
echo "-> Done."

# Stop the containers
echo "Stopping the Docker Compose..."
cd "$SCRIPT_DIR"
docker compose -f docker-compose-redis.yml down > /dev/null 2>&1
echo "-> Done."

# Print output file
echo "Output files:"
echo $load_file
echo $run_file