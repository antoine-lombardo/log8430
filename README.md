# Installation

## Manual install on the EC2 instance:

### Installation

Run these command to install the script on a Ubuntu instance:

````
sudo apt update
sudo apt install curl -y
curl -O --location https://github.com/antoine-lombardo/log8430/releases/download/v1/manual_install.sh
sudo chmod +x manual_install.sh
sudo ./manual_install.sh
````

### Available commands

#### Run all benchmarks
Syntax:
````
/shared/log8430/run_all_benchmarks.sh
````

#### Run all benchmark for a specific model

Syntax:
````
/shared/log8430/{model}/run_all_benchmarks_{model}.sh
````

Parameters:
- **model:** mongodb, redis or cassandra

Example:
````
/shared/log8430/mongodb/run_all_benchmarks_mongodb.sh
````

#### Run a single benchmark

Syntax:
````
/shared/log8430/{model}/run_single_benchmark_{model}.sh {workload} {attempt}
````

Parameters:
- **model:** mongodb, redis or cassandra
- **workload:** a, b, c, d, e, f or i
- **attempt:** any id to identify the attempt (usually a number from 1 to 3)

Example:
````
/shared/log8430/mongodb/run_single_benchmark_mongodb.sh a 1
````

## Automatic deploy, installation and benchmarking:
The automatic script must be run on a local Ubuntu machine and have aws and python3 installed on it.

To run it, execute these commands:
````
sudo apt update
sudo apt install curl -y
curl -O --location https://github.com/antoine-lombardo/log8430/releases/download/v1/automatic_install.sh
sudo chmod +x automatic_install.sh
sudo ./automatic_install.sh
````
An interactive prompt will guide you with the deployment of your instance.
