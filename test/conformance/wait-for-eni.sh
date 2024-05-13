#!/bin/bash

function check_for_elb {
  aws elb describe-load-balancers --region us-east-2 | jq ".LoadBalancerDescriptions[] | .VPCId" | grep ${1}
}

# it's crucial for cleanup that this succeeds so wait up to 10 minutes.
for i in $(seq 20); do
    elbs=$(check_for_elb ${1})
    if [ -z "${elbs}" ] && [ -z "${natgws}" ] && [ -z ${enis} ]; then
      break
    fi
    echo "still waiting for:"
    echo "elbs: ${elbs}"
    sleep 30
done
echo "done!"
