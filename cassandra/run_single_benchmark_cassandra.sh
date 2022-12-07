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
sudo rm -rf /shared/log8430/cassandra/cassandra_data
echo "-> Done."

# Start the containers
cd /shared/log8430/cassandra
echo "Starting Docker Compose..."
docker compose -f docker-compose-cassandra.yml up -d > /dev/null 2>&1
echo "-> Done."

# Wait for the cluster to run
echo "Waiting for the cluster to be created..."
sleep 30
echo "-> Done."

# Create the keyspace
cd /shared/log8430/cqlsh-6.8.29
./bin/cqlsh --username cassandra --password log8430pass -f init_keyspace.cql

# Start the benchmark
echo "Loading the benchmark..."
cd /shared/log8430/ycsb-0.17.0
./bin/ycsb load cassandra-cql -s -P workloads/workload$workload -p recordcount=1000 \
-p hosts="127.0.0.1" \
> $load_file  2>&1
echo "-> Done."
echo "Running the benchmark..."
./bin/ycsb run cassandra-cql -s -P workloads/workload$workload -p recordcount=1000 \
-p hosts="127.0.0.1" \
> $run_file  2>&1
cd ..
echo "-> Done."

# Stop the containers
echo "Stopping the Docker Compose..."
docker compose -f docker-compose-cassandra.yml down > /dev/null 2>&1
echo "-> Done."

# Print output file
echo "Output files:"
echo $load_file
echo $run_file

cd /shared/log8430