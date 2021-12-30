import sys
import boto3
import boto3.ec2


def main(argv):
    ec2 = boto3.resource('ec2')
    instances = ec2.instances.all()
    for instance in instances:
        print("%s;%s;%s;%s;%s;%s" % (instance.id,
                                     get_instance_name(instance),
                                     get_instance_iam_instance_profile(instance),
                                     get_instance_stack_name(instance),
                                     instance.image_id,
                                     instance.state['Name']))


def get_instance_name(ec2_instance):
    instance_name = ''
    if ec2_instance.tags:
        for tag in ec2_instance.tags:
            if tag["Key"] == 'Name':
                instance_name = tag["Value"]
    return instance_name


def get_instance_stack_name(ec2_instance):
    stack_name = ''
    if ec2_instance.tags:
        for tags in ec2_instance.tags:
            if tags["Key"] == 'aws:cloudformation:stack-name':
                stack_name = tags["Value"]
    return stack_name


def get_instance_iam_instance_profile(ec2_instance):
    if ec2_instance.iam_instance_profile is not None:
        return ec2_instance.iam_instance_profile.get("Arn", '')
    return ""


if __name__ == '__main__':
    main(sys.argv[1:])