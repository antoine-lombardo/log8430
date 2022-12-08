#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

workload=$1
attempt=$2
load_file=$3
run_file=$4

if test -z "$load_file" 
then
      load_file=/results/cassandra_${workload}_${attempt}_load.txt
fi
if test -z "$run_file" 
then
      run_file=/results/cassandra_${workload}_${attempt}_run.txt
fi

echo ""
echo ""
echo "| =============================== |"
echo "|       CASSANDRA BENCHMARK       |"
echo "|           WORKLOAD  $workload           |"
echo "|            ATTEMPT $attempt            |"
echo "| =============================== |"
echo ""


# Do some cleaning
echo "Cleaning Docker files..."
cd "$SCRIPT_DIR"
sudo rm -rf cassandra_data
echo "-> Done."

# Start the containers
echo "Starting Docker Compose..."
docker compose -f docker-compose-cassandra.yml up -d > /dev/null 2>&1
echo "-> Done."

# Create the keyspace
echo "Creating the keyspace..."
cd ..
while true; do
    ret=$(./cqlsh-6.8.29/bin/cqlsh --username cassandra --password log8430pass -f cassandra/init_keyspace.cql 2>&1)
    if [[ $ret ]]; then
        echo "-> Cassandra not ready yet, retrying..."
        sleep 10
    else
        echo "-> Done."
        break
    fi
done


# Start the benchmark
echo "Loading the benchmark..."
cd ycsb-0.17.0
./bin/ycsb load cassandra-cql -s -P workloads/workload$workload -p recordcount=1000 \
-p "hosts=127.0.0.1" -p cassandra.username=cassandra -p cassandra.password=log8430pass -p cassandra.keyspace=ycsb \
> $load_file  2>&1
echo "-> Done."
echo "Running the benchmark..."
./bin/ycsb run cassandra-cql -s -P workloads/workload$workload -p recordcount=1000 \
-p "hosts=127.0.0.1" -p cassandra.username=cassandra -p cassandra.password=log8430pass -p cassandra.keyspace=ycsb \
> $run_file  2>&1
cd ..
echo "-> Done."

# Stop the containers
echo "Stopping the Docker Compose..."
cd "$SCRIPT_DIR"
docker compose -f docker-compose-cassandra.yml down > /dev/null 2>&1
echo "-> Done."

# Print output file
echo "Output files:"
echo $load_file
echo $run_file