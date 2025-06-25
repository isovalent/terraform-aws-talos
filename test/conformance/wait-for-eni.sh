#!/bin/bash

function check_for_nlb {
  aws elbv2 describe-load-balancers --region us-east-2 | jq ".LoadBalancers[] | select(.Type==\"network\") | .VpcId" | grep ${1}
}

# it's crucial for cleanup that this succeeds so wait up to 10 minutes.
for i in $(seq 20); do
    nlbs=$(check_for_nlb ${1})
    if [ -z "${nlbs}" ] && [ -z "${natgws}" ] && [ -z ${enis} ]; then
      break
    fi
    echo "still waiting for:"
    echo "nlbs: ${nlbs}"
    sleep 30
done
echo "done!"
