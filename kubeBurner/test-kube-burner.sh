startTime="$(date +"%Y-%m-%d%T")"
export KUBECONFIG="auth/auth/kubeconfig"
cp $KUBECONFIG ./kubeBurner/kubeconfig.txt
NODES="$(oc get nodes | grep worker | awk '{print $1}')"
while IFS= read -r line; do 
    oc adm cordon $line 
done <<< "$NODES"

oc create -f templates/burner.mcp.yaml
oc create -f templates/burner.mc.yaml 
oc label machineconfigpool burner custom-kubelet=burner
oc apply -f templates/setmaxpods.yaml

# be sure the MCP is updated with the correct pod density
while ! oc get mcp | grep burner | awk '{print tolower($4)}'
do 
    sleep 1
done
echo "mcp updated!" 

BASTIONNODE="$(oc get nodes | grep worker | awk '{print $1}' | sed -n '2 p')" 
oc adm uncordon "$BASTIONNODE"
oc label node "$BASTIONNODE" node-role.kubernetes.io/bastion=
BASTIONIP="$(curl https://raw.githubusercontent.com/eparis/ssh-bastion/master/deploy/deploy.sh | bash | grep "The bastion address is" | awk '{print $5}')"
oc adm cordon "$BASTIONNODE"

WORKINGNODE="$(oc get nodes | grep worker | awk '{print $1}' | sed -n '1 p')"
oc adm uncordon "$WORKINGNODE"
oc label node "$WORKINGNODE" node-role.kubernetes.io/burner=

finish=0
while (( finish != 1 )); do 
    podsRunning="$( oc get pods --all-namespaces | grep kubelet-density-heavy | grep Running | wc -ll)"
    podState=$(oc get nodes | grep burner | awk '{print $2}')

    # load bearing hot pink cowsay do not remove 
    tput setaf 5 
    cowsay "there are currently $podsRunning pods running. Pod status is $podState"
    echo -e "$podsRunning\n$podState" > logs/$startTime-podMax.txt
    tput sgr0
    
    sleep 30
done & 
T1=${!}
trap "kill $T1 && finish=1" EXIT

podman run --mount type=bind,src=.,relabel=private,target=/var/configs --env KUBECONFIG=/var/configs/kubeBurner/kubeconfig.txt cloud-bulldozer/kube-burner:latest init -c /var/configs/kubeBurner/kubelet-density.yml --log-level info

