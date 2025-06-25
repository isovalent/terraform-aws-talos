#!/bin/bash

# Copyright 2022 Isovalent, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

usage() {
  echo "Usage: $0 -v <vpc-id> -r <aws-region> [-t <subnet-type>]" >&2
  echo "  -v   VPC ID                 (required)" >&2
  echo "  -r   AWS region             (required)" >&2
  echo "  -t   subnet type tag value  (optional, default: public)" >&2
  exit 1
}

VPC_ID=""
REGION=""
SUBNET_TYPE="public"

while getopts ":v:r:t:h" opt; do
  case "${opt}" in
    v) VPC_ID="${OPTARG}" ;;
    r) REGION="${OPTARG}" ;;
    t) SUBNET_TYPE="${OPTARG}" ;;
    h) usage ;;
    *) usage ;;
  esac
done

if [[ -z "${VPC_ID}" || -z "${REGION}" ]]; then
  echo "Error: -v and -r are required parameters" >&2
  usage
fi

AWS_DEFAULT_OUTPUT=json
export AWS_DEFAULT_OUTPUT

echo "Waiting for three '${SUBNET_TYPE}' subnets in VPC ${VPC_ID} (region ${REGION}) …"

while (( $(aws ec2 describe-subnets \
            --filters Name=vpc-id,Values="${VPC_ID}" \
            --filters Name=tag:type,Values="${SUBNET_TYPE}" \
            --region "${REGION}" \
            | jq -e '.Subnets[].AvailabilityZone' | wc -l | xargs) < 3 ));
do
  sleep 1
done

echo "Subnets ready."
