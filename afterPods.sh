. ./config.sh

# collects the logs from the cluster
workingNode="$(oc get nodes | grep worker | awk '{print $1}' | sed -n '1 p')"
az vm restart -g $groupName -n $workingNode 
oc debug node/$workingNode -- chroot /host "journalctl" > logs.txt 
