#!/bin/bash

attempts=$1
if test -z "$attempts" 
then
      attempts=3
fi

while IFS= read -r workload; do
  for (( i=1; i<=$attempts; i++ ))
  do
    /shared/log8430/mongodb/run_single_benchmark_mongodb.sh $workload $i
  done
done < /shared/log8430/workloads.txt