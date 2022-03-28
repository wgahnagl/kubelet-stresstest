export KUBECONFIG="kubeconfig.txt" 
NODES="$(oc get nodes | grep worker | awk '{print $1}')"
while IFS= read -r line; do 
    oc adm cordon $line 
done <<< "$NODES"

oc create -f burner.mcp.yaml
oc create -f burner.mc.yaml 
oc label machineconfigpool burner custom-kubelet=burner
oc apply -f setmaxpods.yaml

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

podman run --mount type=bind,src=.,relabel=private,target=/var/configs --env KUBECONFIG=/var/configs/kubeconfig.txt kube-burner init -c /var/configs/kubelet-density.yml

ssh core@"$BASTIONIP" -o StrictHostKeyChecking=no -i ~/.ssh/libra.pem
