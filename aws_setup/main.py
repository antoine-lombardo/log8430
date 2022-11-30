
from time import sleep
from typing import List
import sys
import boto3
import logging
from boto3_type_annotations.elbv2 import Client as elbv2Client
from boto3_type_annotations.ec2 import ServiceResource as ec2ServiceResource
from boto3_type_annotations.ec2 import Instance
import security_groups, instances, load_balancers, vpcs, subnets, user_data_file_upload

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s - %(message)s')

SECURITY_GROUP_NAME = 'tp1'
INSTANCE_INFOS = [
    {
        'name': 'log8430',
        'type': 't2.large', 
        'zone': 'us-east-1a', 
        'image_id': 'ami-08c40ec9ead489470'
    },
]
FILES_TO_UPLOAD = [
    [ '../docker-compose-mongodb.yml',      '/shared/docker-compose-mongodb.yml'     ],
    [ '../docker-compose-redis.yml',        '/shared/docker-compose-redis.yml'       ],
    [ '../run_all_benchmarks.sh',           '/shared/run_all_benchmarks.sh'          ],
    [ '../run_all_benchmarks_mongodb.sh',   '/shared/run_all_benchmarks_mongodb.sh'  ],
    [ '../run_all_benchmarks_redis.sh',     '/shared/run_all_benchmarks_redis.sh'    ],
    [ '../run_single_benchmark_mongodb.sh', '/shared/run_single_benchmark_mongodb.sh'],
    [ '../run_single_benchmark_redis.sh',   '/shared/run_single_benchmark_redis.sh'  ],
    [ '../workloads.txt',                   '/shared/workloads.txt'                  ],
    [ '../workloadi',                       '/shared/ycsb-0.17.0/workloads/workloadi']
]

ec2: ec2ServiceResource = boto3.resource('ec2')

elbv2: elbv2Client = boto3.client('elbv2')

# Retrieve default Vpc
#vpc = vpcs.get_default_vpc(ec2)

# Retrieve subnets
#subnets_list = subnets.get_subnets(ec2)

# Delete all old objects
#instances.delete_all_instances(ec2)
#load_balancers.delete_load_balancers(elbv2)
#load_balancers.delete_all_target_groups(elbv2)
#security_groups.delete_security_group(ec2, SECURITY_GROUP_NAME)

# Create the security group
#security_group = security_groups.create_security_group(ec2, SECURITY_GROUP_NAME)
security_group = security_groups.get_security_group(ec2, 'default')
security_groups.add_ssh_rules(security_group)

# Create the instance
commands = ''
for file in FILES_TO_UPLOAD:
    commands += user_data_file_upload.file_upload_commands(file[0], file[1])
instance = instances.create_instance(
    ec2,
    'log8430',
    't2.large',
    'us-east-1a',
    'ami-08c40ec9ead489470',
    security_group,
    commands
)

sys.exit(1)

# Wait for instances to be running
instances.wait_for_running(initialized_instances)

# Retrieve instances
cluster1_instances = instances.retreive_instances(ec2, 't2.large')
cluster2_instances = instances.retreive_instances(ec2, 'm4.large')

# Create load balancer
target_group_1 = load_balancers.create_target_group(elbv2, 'cluster1', vpc, cluster1_instances)
target_group_2 = load_balancers.create_target_group(elbv2, 'cluster2', vpc, cluster2_instances)
target_group_1 = load_balancers.get_target_group(elbv2, 'cluster1')
target_group_2 = load_balancers.get_target_group(elbv2, 'cluster2')
load_balancer = load_balancers.create_load_balancer(elbv2, 'tp1', security_group, subnets_list, target_group_1, target_group_2)
load_balancer = load_balancers.get_load_balancer(elbv2, 'tp1')
load_balancer = load_balancers.wait_for_provisioning(elbv2, load_balancer)

# Wait for all targets to be healty
load_balancers.wait_for_healthy_target(elbv2, target_group_1)
load_balancers.wait_for_healthy_target(elbv2, target_group_2)

# Retrieving urls
dns_name = load_balancer['DNSName']
base_url = f'http://{dns_name}'
cluster1_url = base_url + '/cluster1'
cluster2_url = base_url + '/cluster2'
logging.info('URLs:')
logging.info('  ' + cluster1_url)
logging.info('  ' + cluster2_url)

exit(0)


