. ./config.sh
time=$(date +'%Y-%m-%d_%T')
# collects the logs from the cluster
az vm restart -g $groupName -n $workingNode 
oc debug node/$workingNode -- chroot /host "journalctl" "-b" "1" > $logDestination/$time"_"$workingNode.txt 
