#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

attempts=$1
if test -z "$attempts" 
then
      attempts=3
fi

cd "$SCRIPT_DIR"
while IFS= read -r workload; do
  for (( i=1; i<=$attempts; i++ ))
  do
    cd "$SCRIPT_DIR"
    ./mongodb/run_single_benchmark_mongodb.sh $workload $i
  done
done < ../workloads