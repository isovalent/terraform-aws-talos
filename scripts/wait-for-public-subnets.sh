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

set -euxo pipefail

AWS_DEFAULT_OUTPUT=json
export AWS_DEFAULT_OUTPUT

while (( $(aws ec2 describe-subnets --filters Name=vpc-id,Values="${1}" --filters Name=tag:type,Values=public --region "${2}" | jq -e '.Subnets[].AvailabilityZone' | wc -l | xargs) < 2 ));
do
  sleep 1;
done
