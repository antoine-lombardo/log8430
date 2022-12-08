import os, logging
from typing import List
import boto3
from boto3_type_annotations.ec2 import ServiceResource, SecurityGroup, Instance, waiter, Client

USER_DATA_SCRIPT_FILE = 'instance_user_data.txt'
dir_path = os.path.dirname(os.path.realpath(__file__))
with open(os.path.join(dir_path, USER_DATA_SCRIPT_FILE)) as file:
    USER_DATA_SCRIPT = file.read()

def delete_all_instances(ec2: ServiceResource):
    logging.info('Terminating old instances...')
    for instance in ec2.instances.all():
        if instance.state['Name'] != 'terminated':
            instance.terminate()
    for instance in ec2.instances.all():
        if instance.state['Name'] != 'terminated':
            instance.wait_until_terminated()
            logging.info('  {}: Terminated.'.format(instance.id))


def create_instance(ec2: ServiceResource, ec2_client: Client, name: str, instance_type: str, availability_zone: str, image_id: str, security_group: SecurityGroup) -> Instance:
    logging.info(f'Creating instance "{name}" of type "{instance_type}" instance in zone "{availability_zone}"...')
    instance: Instance = ec2.create_instances(
        BlockDeviceMappings=[
        {
            'DeviceName': '/dev/sda1',
            'Ebs': { 'VolumeSize': 20 }
        },
    ],
        ImageId=image_id,
        MinCount=1,
        MaxCount=1,
        InstanceType=instance_type,
        UserData=USER_DATA_SCRIPT,
        KeyName='vockey',
        Placement={
            'AvailabilityZone': availability_zone,
        },
        SecurityGroupIds=[security_group.id]
    )[0]
    logging.info('  {}: Created.'.format(instance.id))
    logging.info('  {}: Adding tags...'.format(instance.id))
    ec2.create_tags(
        Resources=[instance.id], 
        Tags=[{'Key': 'Name', 'Value': name}])
    logging.info('  {}: Starting...'.format(instance.id))
    wait_for_running(instance)
    logging.info('  {}: Initializing...'.format(instance.id))
    wait_for_initialized(ec2_client, instance)
    logging.info('  {}: Ready.'.format(instance.id))
    instance.load()
    return instance

def wait_for_running(instance: Instance):
    instance.wait_until_running()

def wait_for_initialized(client: Client, instance: Instance):
    system_status_ok_waiter = client.get_waiter('system_status_ok')
    system_status_ok_waiter.wait(
        InstanceIds=[instance.id], 
        WaiterConfig={
            'Delay': 15,
            'MaxAttempts': 60
        })
    instance_status_ok_waiter = client.get_waiter('instance_status_ok')
    instance_status_ok_waiter.wait(
        InstanceIds=[instance.id],
        WaiterConfig={
            'Delay': 15,
            'MaxAttempts': 60
        })

def retrieve_instances(ec2: ServiceResource) -> List[Instance]:
    instances = []
    for instance in ec2.instances.all():
        if instance.state['Name'] != 'terminated':
            instances.append(instance)
    return instances