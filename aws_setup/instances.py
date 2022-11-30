import os, logging
from typing import List
from boto3_type_annotations.ec2 import ServiceResource, SecurityGroup, Instance

USER_DATA_SCRIPT_FILE = 'instance_user_data.txt'
dir_path = os.path.dirname(os.path.realpath(__file__))
with open(os.path.join(dir_path, USER_DATA_SCRIPT_FILE)) as file:
    USER_DATA_SCRIPT = file.read()

def delete_all_instances(ec2: ServiceResource):
    logging.info('Terminating all instances...')
    for instance in ec2.instances.all():
        if instance.state['Name'] != 'terminated':
            instance.terminate()
    for instance in ec2.instances.all():
        if instance.state['Name'] != 'terminated':
            instance.wait_until_terminated()
            logging.info('  {}: Terminated.'.format(instance.id))


def create_instance(ec2: ServiceResource, name: str, instance_type: str, availability_zone: str, image_id: str, security_group: SecurityGroup, additionnal_commands: str = '') -> Instance:
    logging.info(f'Creating instance "{name}" of type "{instance_type}" instance in zone "{availability_zone}"...')
    
    modified_user_data_script = USER_DATA_SCRIPT.format(commands=additionnal_commands)

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
        UserData=modified_user_data_script,
        KeyName='vockey',
        Placement={
            'AvailabilityZone': availability_zone,
        },
        SecurityGroupIds=[security_group.id]
    )[0]
    ec2.create_tags(
        Resources=[instance.id], 
        Tags=[{'Key': 'Name', 'Value': name}])
    instance.reload()
    return instance

def wait_for_running(instances: List[Instance]):
    logging.info('Waiting for all instances to be running...')
    for instance in instances:
        instance.wait_until_running()
        logging.info('  {}: Running.'.format(instance.id))

def retreive_instances(ec2: ServiceResource, instance_type: str) -> List[Instance]:
    instances = []
    for instance in ec2.instances.all():
        if instance.state['Name'] == 'terminated':
            continue
        if instance.instance_type == instance_type:
            instances.append(instance)
    return instances