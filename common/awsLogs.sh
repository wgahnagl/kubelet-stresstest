export platform=$1
. ./config.sh aws  

aws configure import --csv file://$awsConfigLocation

IP=$(oc get nodes | grep burner | awk '{print $1}' | grep -o -P '(?<=ip-).*(?=.ec2)' | sed s/-/./g) 
AWS_ID=$(aws ec2 describe-instances --filter Name=private-ip-address,Values=$IP | grep -o "\bi-.................")
echo stopping $AWS_ID 
aws ec2 stop-instances --instance-ids $AWS_ID > /dev/null 
echo $AWS_ID stopped 

while [ "$STATUS" != "running" ] 
do
    echo "waiting 30s for instance to be started"
    sleep 30
    aws ec2 start-instances --instance-ids $AWS_ID > /dev/null
    STATUS=$(aws ec2 describe-instance-status --instance-id $AWS_ID | grep INSTANCESTATE | awk '{print $3}') 
done 

