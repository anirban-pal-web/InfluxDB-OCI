import boto3
import os

ssm = boto3.client('ssm')

def handler(event, context):
    instance_id = os.environ['DR_INSTANCE_ID']
    bucket = os.environ['BUCKET']

    command = f"""
    set -e
    mkdir -p /opt/influx-restore
    aws s3 sync s3://{bucket}/primary/ /opt/influx-restore
    influx restore /opt/influx-restore
    """

    response = ssm.send_command(
        InstanceIds=[instance_id],
        DocumentName="AWS-RunShellScript",
        Parameters={
            "commands": [command]
        }
    )

    return {"status": "Restore triggered"}
