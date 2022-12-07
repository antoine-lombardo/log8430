#!/bin/bash

workload=$1
attempt=$2
load_file=$3
run_file=$4

if test -z "$load_file" 
then
      load_file=/results/mongodb_${workload}_${attempt}_load.txt
fi
if test -z "$run_file" 
then
      run_file=/results/mongodb_${workload}_${attempt}_run.txt
fi

echo ""
echo ""
echo "| =============================== |"
echo "|        MONGODB BENCHMARK        | "
echo "|           WORKLOAD  $workload           |"
echo "|            ATTEMPT $attempt            |"
echo "| =============================== |"
echo ""


# Do some cleaning
echo "Cleaning Docker files..."
sudo rm -rf /shared/log8430/mongodb/data
echo "-> Done."

# Start the containers
cd /shared/log8430/mongodb
echo "Starting Docker Compose..."
docker compose -f docker-compose-mongodb.yml up -d > /dev/null 2>&1
echo "-> Done."

# Wait for the cluster to run
echo "Waiting for the cluster to be created..."
docker logs -f mongo1 2>&1 | grep -m 1 'MongoDB Shell' > /dev/null 2>&1
sleep 15
echo "-> Done."

# Write hosts entries
echo "Modifying /etc/hosts..."
grep -v "mongo" "/etc/hosts" > tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongo1) mongo1 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongo2) mongo2 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongo3) mongo3 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongo4) mongo4 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongo5) mongo5 >> tmp_hosts
echo $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongo6) mongo6 >> tmp_hosts
sudo mv tmp_hosts /etc/hosts
echo "-> Done."

# Start the benchmark
echo "Loading the benchmark..."
cd /shared/log8430/ycsb-0.17.0
./bin/ycsb load mongodb -s -P workloads/workload$workload -p recordcount=1000 \
-p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003,mongo4:30004,mongo5:30005,mongo6:30006/?replicaSet=my-replica-set \
> $load_file  2>&1
echo "-> Done."
echo "Running the benchmark..."
./bin/ycsb run mongodb -s -P workloads/workload$workload -p recordcount=1000 \
-p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003,mongo4:30004,mongo5:30005,mongo6:30006/?replicaSet=my-replica-set \
> $run_file  2>&1
cd ..
echo "-> Done."

# Stop the containers
echo "Stopping the Docker Compose..."
cd /shared/log8430/mongodb
docker compose -f docker-compose-mongodb.yml down > /dev/null 2>&1
echo "-> Done."

# Print output file
echo "Output files:"
echo $load_file
echo $run_file

cd /shared/log8430