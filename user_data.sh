#!/bin/bash
yum update -y
yum install -y aws-cli amazon-cloudwatch-agent

# Log S3 bucket listing
aws s3 ls s3://case-study6-bucket-bhavani-20250624/ >> /var/log/s3_access.log

# Setup CloudWatch Agent config
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "CaseStudy6-SystemLogs",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/s3_access.log",
            "log_group_name": "CaseStudy6-S3Access",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
