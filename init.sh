#!/bin/bash

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

# -------------- #
# Download CQLSH #
# -------------- #
cd /shared/log8430
curl -O --location https://downloads.datastax.com/enterprise/cqlsh-6.8.tar.gz
tar -xzvf cqlsh-6.8.tar.gz
chmod +x /shared/log8430/cqlsh-6.8.29/bin/cqlsh