#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root using sudo ./manual_install.sh"
  exit
fi

# ------------------ #
# Create directories #
# ------------------ #
mkdir /results
mkdir /shared

# -------------------- #
# Clone GIT repository #
# -------------------- #
apt update
apt install git -y
cd /shared
git clone https://github.com/antoine-lombardo/log8430.git
cd /shared/log8430

# -------------------- #
# Install requirements #
# -------------------- #
apt update
apt install python2 default-jdk maven apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release -y
ln -s /bin/python2.7 /usr/bin/python
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-compose-plugin -y
usermod -aG docker ubuntu

# ------------- #
# Download YCSB #
# ------------- #
cd /shared/log8430
curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz
tar xfvz ycsb-0.17.0.tar.gz
chmod +x /shared/log8430/ycsb-0.17.0/bin/ycsb
rm ycsb-0.17.0.tar.gz

# -------------- #
# Download CQLSH #
# -------------- #
cd /shared/log8430
curl -O --location https://downloads.datastax.com/enterprise/cqlsh-6.8.tar.gz
tar -xzvf cqlsh-6.8.tar.gz
chmod +x /shared/log8430/cqlsh-6.8.29/bin/cqlsh
rm cqlsh-6.8.tar.gz

# --------------------- #
# Copy custom workloads #
# --------------------- #
cp custom_workloads/workloadi /shared/log8430/ycsb-0.17.0/workloads/workloadi

# ------------------------ #
# Mark scripts as runnable #
# ------------------------ #
chmod +x cassandra/run_all_benchmarks_cassandra.sh
chmod +x cassandra/run_single_benchmark_cassandra.sh
chmod +x mongodb/run_all_benchmarks_mongodb.sh
chmod +x mongodb/run_single_benchmark_mongodb.sh
chmod +x redis/run_all_benchmarks_redis.sh
chmod +x redis/run_single_benchmark_redis.sh
chmod +x run_all_benchmarks.sh
chmod -R 777 /results
chmod -R 777 /shared