export platform=$1
. ./config.sh $platform
time=$(date +'%Y-%m-%d_%T')
# collects the logs from the cluster

if [[ $platform == "aws" ]]; then
    echo "aws"
    # AWS KUBECONFIG 
else 
    if [[ $platform == "azure" ]]; then 
        # AZURE KUBECONFIG 
        az vm restart -g $groupName -n $workingNode 
    fi 
fi 

rm -rf tmp

logsContent=$(oc debug node/$workingNode -- chroot /host "journalctl" "-b" "-1") 
if ! [[ -z $logsContent ]]; then
   echo "$logsContent" > $logDestination/$time"_"$platform"_"$workingNode.txt 
fi 
cp logs/* $googleDrivePath 
