#!/bin/bash

function usage() { echo "Usage: $0 [-d <duration in seconds>] [-u <number of concurrent users>] [-w <work rate - requests/second] [-n <kubernetes namespace from where to run the load injector] [<target url> ]" 1>&2; exit 1; }

function loadTestExists?() {
    exists=`kubectl get pod -n $namespace|grep loadtest|cut -f 1 -d " "`
    if [ -z $exists ] ; then
        printf "false"
    else
        printf "true"
    fi
}

function isRunning?() {
    running=`kubectl get pod -n $namespace|grep loadtest|grep "Running"|cut -f 1 -d " "`
    if [ -z $running ] ; then
        printf "false"
    else
        printf "true"
    fi
}

while getopts ":d:u:w:n:h:i:" o; do
    case "${o}" in
        d)
            duration=${OPTARG}
            ;;
        u)
            users=${OPTARG}
            ;;
        w)
            workRate=${OPTARG}
            ;;
        n)
            namespace=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ ! -z "$1" ] ; then
    url=$1
fi

if [ -z "$duration" ] || [ -z "$users" ] || [ -z "$workRate" ] || [ -z "$namespace" ] || [ -z "$url" ]; then
    usage
    exit 1
fi

exist=`loadTestExists?`

if [ $exist = true ]; then
    echo "aborting existing load test, or cleaning up previous load test..."
    kubectl delete pod/loadtest
fi

echo "run load test in $namespace namespace with parameters:"
echo "  duration: $duration"
echo "  number of users: $users"
echo "  work rate (requests per second: $workRate"
echo "  url: $url"

kubectl run loadtest --image pivotaleducation/loadtest:latest  --env="DURATION=$duration" --env="NUM_USERS=$users" --env="REQUESTS_PER_SECOND=$workRate" --env="URL=$url" --restart=Never

echo "waiting for pod/loadtest to start."

running=`isRunning?`
while [ $running = false ]; do
    printf "."
    sleep 1
    running=`isRunning?`
done
echo ""
echo ""

kubectl logs pod/loadtest -n $namespace -f