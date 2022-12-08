#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

attempts=$1
if test -z "$attempts" 
then
      attempts=3
fi

cd "$SCRIPT_DIR"
./mongodb/run_all_benchmarks_mongodb.sh $attempts
cd "$SCRIPT_DIR"
./redis/run_all_benchmarks_redis.sh $attempts
cd "$SCRIPT_DIR"
./cassandra/run_all_benchmarks_cassandra.sh $attempts