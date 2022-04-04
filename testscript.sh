. ./config.sh
echo $configLoaded
NODES="$(oc get nodes | grep worker | awk '{print $1}')"
oc get nodes
while IFS= read -r line; do 
    oc adm cordon $line 
done <<< "$NODES"

oc create -f $templatesLocation/burner.mcp.yaml
oc create -f $templatesLocation/burner.mc.yaml 
oc label machineconfigpool burner custom-kubelet=burner
oc create -f $templatesLocation/setmaxpods.yaml
oc create -f $templatesLocation/namespace.yaml

BASTIONNODE="$(oc get nodes | grep worker | awk '{print $1}' | sed -n '2 p')" 
oc adm uncordon "$BASTIONNODE"
oc label node "$BASTIONNODE" node-role.kubernetes.io/bastion=
BASTIONIP="$(curl https://raw.githubusercontent.com/eparis/ssh-bastion/master/deploy/deploy.sh | bash | grep "The bastion address is" | awk '{print $5}')"
oc adm cordon "$BASTIONNODE"

oc adm uncordon "$workingNode"
oc label node "$workingNode" node-role.kubernetes.io/burner=

./podCreate.sh
echo "node failed" 
echo "gathering logs"
./afterPods.sh
