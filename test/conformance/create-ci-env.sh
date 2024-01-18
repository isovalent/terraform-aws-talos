#!/bin/bash

if [ -f env.tfvars ]; then
	echo "env.tfvars already exists, please cleanup cluster and remove this file"
fi

pr_name=""
kube_proxy=""
talos_version=""
owner=""

# Function to display usage
usage() {
    echo "Usage: $0 [--kube-proxy <value>] [--version <value>] [--owner <owner_name>]"
    exit 1
}

# Parse command line options
while [ $# -gt 0 ]; do
    case "$1" in
        --pr)
            shift
            if [ -n "$1" ] && [ ${1:0:1} != "-" ]; then
                pr_name="$1"
            else
                echo "Error: Missing or invalid argument for --pr" >&2
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


pr_name=$(head -c 15 <<< ${pr_name})
num=$(head -c 3 <<< ${RANDOM})

disable_kube_proxy=false
if [ ${kube_proxy} == "false" ]; then
	disable_kube_proxy=true
fi

cat > env.tfvars << EOF
cluster_name = "talos-e2e-${pr_name}-${num}"
region = "us-east-2"
owner = "${owner}"
talos_version = "${talos_version}"
disable_kube_proxy = ${disable_kube_proxy} 
EOF

cat env.tfvars


