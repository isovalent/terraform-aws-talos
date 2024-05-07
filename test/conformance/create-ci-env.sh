#!/bin/bash

if [ -f env.tfvars ]; then
	echo "env.tfvars already exists, please cleanup cluster and remove this file"
fi

kube_proxy=""
talos_version=""
cilium_version=""
owner=""

run_id=
num_no=

test=

# Function to display usage
usage() {
    echo "Usage: $0 [--kube-proxy <value>] [--version <value>] [--owner <owner_name>]"
    exit 1
}

# Parse command line options
while [ $# -gt 0 ]; do
    case "$1" in
        --run-id)
            shift
            if [ -n "$1" ] && [ ${1:0:1} != "-" ]; then
                run_id="$1"
            else
                echo "Error: Missing or invalid argument for --run-id" >&2
                usage
            fi
            ;;
        --run-no)
            shift
            if [ -n "$1" ] && [ ${1:0:1} != "-" ]; then
                run_no="$1"
            else
                echo "Error: Missing or invalid argument for --run-no" >&2
                usage
            fi
            ;;
        --test)
            shift
            if [ -n "$1" ] && [ ${1:0:1} != "-" ]; then
                test="$1"
            else
                echo "Error: Missing or invalid argument for --test" >&2
                usage
            fi
            ;;
        --kube-proxy)
            shift
            if [ -n "$1" ] && [ ${1:0:1} != "-" ]; then
                kube_proxy="$1"
            else
                echo "Error: Missing or invalid argument for --kube-proxy" >&2
                usage
            fi
            ;;
        --talos-version)
            shift
            if [ -n "$1" ] && [ ${1:0:1} != "-" ]; then
                talos_version="$1"
            else
                echo "Error: Missing or invalid argument for --version" >&2
                usage
            fi
            ;;
        --cilium-version)
            shift
            if [ -n "$1" ] && [ ${1:0:1} != "-" ]; then
                cilium_version="$1"
            else
                echo "Error: Missing or invalid argument for --cilium-version" >&2
                usage
            fi
            ;;
        --owner)
            shift
            if [ -n "$1" ] && [ ${1:0:1} != "-" ]; then
                owner="$1"
            else
                echo "Error: Missing or invalid argument for --owner" >&2
                usage
            fi
            ;;
        *)
            echo "Error: Invalid option: $1" >&2
            usage
            ;;
    esac
    shift
done

# Display information based on flags
if [ -n "$kube_proxy" ]; then
    echo "Kube Proxy flag is set with value: $kube_proxy"
fi

if [ -n "$talos_version" ]; then
    echo "Version flag is set with value: $talos_version"
fi

if [ -n "$owner" ]; then
    echo "Owner flag is set with owner name: $owner"
fi

# If no flags are provided, display usage
if [ -z "$kube_proxy" ] && [ -z "$talos_version" ] && [ -z "$owner" ]; then
    usage
fi

id=$(echo ${run_id}-${run_no}-${RANDOM} | md5sum | head -c 5)

disable_kube_proxy=false
if [ ${kube_proxy} == "false" ]; then
	disable_kube_proxy=true
fi

cat > env.tfvars << EOF
cluster_name = "talos-e2e-${id}"
region = "us-east-2"
owner = "${owner}"
talos_version = "${talos_version}"
disable_kube_proxy = ${disable_kube_proxy} 
run_id = "${run_id}"
run_number = "${run_no}"
test_name = "${test}"
cilium_version = "${cilium_version}"
EOF

cat env.tfvars

