#!/bin/bash

attempts=$1
if test -z "$attempts" 
then
      attempts=3
fi

while IFS= read -r workload; do
  for (( i=1; i<=$attempts; i++ ))
  do
    ./redis/run_single_benchmark_redis.sh $workload $i
  done
done < workloads.txt