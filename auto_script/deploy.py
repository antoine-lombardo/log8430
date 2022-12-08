
import boto3
import logging
from boto3_type_annotations.ec2 import ServiceResource as ec2ServiceResource
from boto3_type_annotations.ec2 import Client as ec2Client
from boto3_type_annotations.ec2 import Instance as ec2Instance
import security_groups, instances

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

def deploy() -> ec2Instance:
    '''
    Fully deploy a ec2 instance with all scripts installed.
    '''

    ec2_service_resource: ec2ServiceResource = boto3.resource('ec2')
    ec2_client: ec2Client = boto3.client('ec2')

    # Delete all old objects
    instances.delete_all_instances(ec2_service_resource)

    # Create the security group
    security_group = security_groups.get_security_group(ec2_service_resource, 'default')
    security_groups.add_ssh_rules(security_group)

    # Create the instance
    instance = instances.create_instance(
        ec2_service_resource,
        ec2_client,
        'log8430',
        't2.large',
        'us-east-1a',
        'ami-08c40ec9ead489470',
        security_group
    )

    print('')
    logging.info('You can now login using SSH using this command:')
    logging.info('ssh ubuntu@{}'.format(instance.public_dns_name))
    logging.info('And the following password: log8430')


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format='%(levelname)s - %(message)s')
    deploy()