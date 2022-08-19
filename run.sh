#!/bin/sh -eu
trap 'kill $(jobs -p)' EXIT

diffResources(){
    echo "Diffing"
    CEP_IPS=$(kubectl get cep -o=jsonpath="{range .items[*]}{.status.networking.addressing[0].ipv4}{\"\n\"}{end}"|sort)
    POD_IPS=$(kubectl get pod -o=jsonpath="{range .items[*]}{.status.podIP}{\"\n\"}{end}"|sort)
    diff <(echo $CEP_IPS) <(echo $POD_IPS)
}

mark(){
    while true
    do
        kubectl label pod web-0 selected=true --overwrite &>/dev/null || echo "no work"
        sleep 0.5
        kubectl label pod web-0 selected=false --overwrite &>/dev/null || echo "no work"
        kubectl label pod web-1 selected=true --overwrite &>/dev/null || echo "no work"
        sleep 0.5
        kubectl label pod web-1 selected=false --overwrite &>/dev/null || echo "no work"
    done
}

mark &

while true
 do
    diffResources
    echo "Restarting"
    kubectl rollout restart sts web
    kubectl rollout status sts web



    diffResources

    echo "$CEP_IPS"
    echo "sleeping"
    sleep 2
    echo
    echo
    echo
done