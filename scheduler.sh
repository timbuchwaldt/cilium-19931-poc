#!/bin/zsh -eu
NODES=$(kubectl get nodes -l node-role.kubernetes.io/brawn="" -o=jsonpath="{range .items[*]}{.metadata.name}{\"\n\"}{end}")
NUMNODES=$(echo $NODES|wc -l)

while true
do
    kubectl get pods -o json | jq '.items[] | select(.spec.schedulerName == "chaos-cloud") | select(.spec.nodeName == null) | .metadata.name' | tr -d '"'
    for PODNAME in $(kubectl get pods -o json | jq '.items[] | select(.spec.schedulerName == "chaos-cloud") | select(.spec.nodeName == null) | .metadata.name' | tr -d '"' );
    do
        CHOSEN=$(echo $NODES|shuf -n 1)
        echo  "scheduling $PODNAME to $CHOSEN"
        echo '{"apiVersion":"v1", "kind": "Binding", "metadata": {"name": "'$PODNAME'"}, "target": {"apiVersion": "v1", "kind": "Node", "name": "'$CHOSEN'"}}'|kubectl create -f -
    done
    sleep 1
done
