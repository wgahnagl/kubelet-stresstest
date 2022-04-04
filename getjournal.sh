./config.sh
az vm restart -g $groupName -n $workingNode
currentTime=$(date +%s)
oc debug $workingNode -- chroot /host "journalctl" > $currentTime.txt 
