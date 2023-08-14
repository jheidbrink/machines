#!/usr/bin/env bash

set -euo pipefail

instance_id=$1
instance_user=$2

az=$(aws ec2 describe-instances --instance-ids "$instance_id" | jq -r '.Reservations[0].Instances[0].Placement.AvailabilityZone')
aws ec2-instance-connect send-ssh-public-key --instance-id "$instance_id" --instance-os-user "$instance_user" --ssh-public-key 'file://~/.ssh/id_ed25519.pub' --availability-zone "$az"
ssh -o ProxyCommand="aws ssm start-session \
  --target $instance_id \
  --document-name AWS-StartSSHSession" \
  ec2-user@"$instance_id"
