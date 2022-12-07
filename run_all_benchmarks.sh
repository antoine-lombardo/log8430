#!/bin/bash

attempts=$1
if test -z "$attempts" 
then
      attempts=3
fi

/shared/log8430/mongodb/run_all_benchmarks_mongodb.sh $attempts
/shared/log8430/redis/run_all_benchmarks_redis.sh $attempts
/shared/log8430/cassandra/run_all_benchmarks_cassandra.sh $attempts