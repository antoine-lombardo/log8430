
import boto3, sys, logging, os
from boto3_type_annotations.ec2 import ServiceResource as ec2ServiceResource
from boto3_type_annotations.ec2 import Client as ec2Client
from boto3_type_annotations.ec2 import Instance as ec2Instance
import instances
from paramiko.client import SSHClient
from paramiko import AutoAddPolicy

logging.basicConfig(level=logging.INFO, format='%(levelname)s - %(message)s')

# Constants
SECURITY_GROUP_NAME = 'tp1'
INSTANCE_INFOS = [
    {
        'name': 'log8430',
        'type': 't2.large', 
        'zone': 'us-east-1a', 
        'image_id': 'ami-08c40ec9ead489470'
    }
]
DBS = ['cassandra', 'mongodb', 'redis']
WLS = ['a', 'b', 'c', 'd', 'e', 'f', 'i']
ATS = ['1', '2', '3']

# Retrieve instance
ec2: ec2ServiceResource = boto3.resource('ec2')
logging.info(f'Retrieving the instance...')
instance_list = instances.retrieve_instances(ec2)
if len(instance_list) == 0:
    logging.error('Cannot retrieve the EC2 instance.')
    sys.exit(1)
instance = instance_list[0]
logging.info('  Instance ID......: {}'.format(instance.id))
logging.info('  Instance DNS.....: {}'.format(instance.public_dns_name))
logging.info('  Instance username: ubuntu')
logging.info('  Instance password: log8430')

def benchmark_all():
    for db in DBS:
        benchmark_db(db)

def benchmark_db(db: str):
    for wl in WLS:
        for at in ATS:
            benchmark(db, wl, at)


def single_benchmark():
    print('')
    print('Which database would you like to benchmark?')
    print('1) Cassandra')
    print('2) MongoDB')
    print('3) Redis')
    x = input()
    db: str = ''
    if x == '1':
        db = 'cassandra'
    elif x == '2':
        db = 'mongodb'
    elif x == '3':
        db = 'redis'
    else:
        print('Wrong input.')
        sys.exit(1)

    print('')
    print('Which workload would you like use?')
    print('a) Workload a')
    print('b) Workload b')
    print('c) Workload c')
    print('d) Workload d')
    print('e) Workload e')
    print('f) Workload f')
    print('i) Workload i')
    wl = input()
    if wl not in ['a', 'b', 'c', 'd', 'e', 'f', 'i']:
        print('Wrong input.')
        sys.exit(1)
    
    print('')
    print('Which attempt ID would you like to assign to this test?')
    at = input()

    print('')
    return benchmark(db, wl, at)


def benchmark(db: str, wl: str, at: str) -> ec2Instance:
    if not os.path.exists('../../results'):
        os.makedirs('../../results')

    logging.info('BENCHMARKING {} USING WORKLOAD {} #{}'.format(db, wl, at))
    logging.info(f'Connecting to the instance...')
    client = SSHClient()
    client.set_missing_host_key_policy(AutoAddPolicy())
    client.connect(
        hostname=instance.public_dns_name, 
        username='ubuntu',
        password='log8430')
    
    logging.info(f'Launching benchmarks...')
    stdin, stdout, stderr = client.exec_command('/shared/log8430/{db}/run_single_benchmark_{db}.sh {wl} {at}'.format(db=db, wl=wl, at=at), get_pty=True)
    run_file = None
    load_file = None
    for line in iter(stdout.readline, ""):
        logging.info(line.replace('\n', '').replace('\r', ''))
        if 'run.txt' in line:
            run_file = line.replace('\n', '').replace('\r', '')
            with client.open_sftp() as sftp:
                sftp.get(run_file, '../..' + run_file)
                logging.info('  Downloaded run file!')
        elif 'load.txt' in line:
            load_file = line.replace('\n', '').replace('\r', '')
            with client.open_sftp() as sftp:
                sftp.get(load_file, '../..' + load_file)
                logging.info('  Downloaded load file!')


if __name__ == "__main__":
    print('')
    print('What type of benchmark woulf you like to do?')
    print('1) Benchmark on all databases, using all workloads.')
    print('2) Benchmark Cassandra, using all workloads.')
    print('3) Benchmark MongoDB, using all workloads.')
    print('4) Benchmark Redis, using all workloads.')
    print('5) Single specific benchmark.')
    x = input()
    db: str = ''
    if x == '1':
        benchmark_all()
    elif x == '2':
        benchmark_db('cassandra')
    elif x == '3':
        benchmark_db('mongodb')
    elif x == '4':
        benchmark_db('redis')
    elif x == '5':
        single_benchmark()
    else:
        print('Wrong input.')
        sys.exit(1)