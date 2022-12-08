
### Manual install on the EC2 instance:

Run these command to install the script on a Ubuntu instance:

````
sudo apt update
sudo apt install curl -y
curl -O --location https://github.com/antoine-lombardo/log8430/releases/download/v1/manual_install.sh
sudo chmod +x manual_install.sh
sudo ./manual_install.sh
````
You can then run all the benchmark using the following command:
````
/shared/log8430/run_all_benchmarks.sh
````

### Automatic deploy, installation and benchmarking:
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
