#!/bin/bash

attempts=$1
if test -z "$attempts" 
then
      attempts=3
fi

./mongodb/run_all_benchmarks_mongodb.sh $attempts
./redis/run_all_benchmarks_redis.sh $attempts
./cassandra/run_all_benchmarks_cassandra.sh $attempts