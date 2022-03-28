./config.sh
az vm restart -g $groupName -n $workingNode
currentTime=$(date +%s)
oc debug node/wgahnagl-0000001-8cmrp-worker-eastus1-2qszk -- chroot /host "journalctl" > $currentTime.txt 
