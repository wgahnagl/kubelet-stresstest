. ./config.sh
echo $configLoaded
NODES="$(oc get nodes | grep worker | awk '{print $1}')"
while IFS= read -r line; do 
    oc adm cordon $line 
done <<< "$NODES"

oc create -f burner.mcp.yaml
oc create -f burner.mc.yaml 
oc label machineconfigpool burner custom-kubelet=burner
oc create -f setmaxpods.yaml
oc create -f namespace.yaml

BASTIONNODE="$(oc get nodes | grep worker | awk '{print $1}' | sed -n '2 p')" 
oc adm uncordon "$BASTIONNODE"
oc label node "$BASTIONNODE" node-role.kubernetes.io/bastion=
BASTIONIP="$(curl https://raw.githubusercontent.com/eparis/ssh-bastion/master/deploy/deploy.sh | bash | grep "The bastion address is" | awk '{print $5}')"
oc adm cordon "$BASTIONNODE"

oc adm uncordon "$workingNode"
oc label node "$workingNode" node-role.kubernetes.io/burner=

./podCreate.sh

echo "node failed" 
