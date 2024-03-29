export platform=$1
. ./config.sh $platform
time=$(date +'%Y-%m-%d_%T')

# collects the logs from the cluster

if [[ $platform == "aws" ]]; then
    . ./common/awsLogs.sh $platform  
    # AWS KUBECONFIG 
else 
    if [[ $platform == "azure" ]]; then 
        # AZURE KUBECONFIG 
        az vm restart -g $groupName -n $workingNode 
    fi 
fi 

workingNode="$(oc get nodes | grep burner | awk '{print $1}' | sed -n '1 p')"
bastionNode="$(oc get nodes | grep bastion | awk '{print $1}' | sed -n '1 p')"

logsLocation=$logDestination/$time"_"$platform"_"$workingNode.txt 
oc adm uncordon "$bastionNode"  
echo $workingNode
echo $logsLocation 
sed s/900/910/ templates/setmaxpods.yaml > tmp/bumpmaxpods.yaml
oc apply -f tmp/bumpmaxpods.yaml 
sleep 30 
oc debug node/$workingNode -- chroot /host "journalctl" "-b" "-1" > $logsLocation

