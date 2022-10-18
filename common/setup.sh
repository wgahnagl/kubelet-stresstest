if [[ -z "$1" ]]; then 
    echo "please specify the type of cluster you want to test on"
    exit 0
fi 

export platform=$1
. ./config.sh "$platform"

DAY=86400
loginCommandModified=$(stat -c %Y $loginCommandLocation 2> /dev/null) 
now=$(date +%s)
secondsSinceLastEdit=$((now-loginCommandModified))
if [ $secondsSinceLastEdit -gt $DAY ]; then
    xdg-open https://oauth-openshift.apps.ci.l2s4.p1.openshiftapps.com/oauth/token/display
    echo "paste in login command"
    read loginCommand
    echo $loginCommand > $loginCommandLocation
    echo "updating login command"
    
    # only login once a day 
    if [[ $platform == "azure" ]]; then 
        az login --scope https://graph.windows.net//.default
    fi 
fi


rm -f -- $podCounterLocation
rm -f -- $secretsLocation/metadata.json 
rm -f -- $secretsLocation/kubeconfig.txt
rm -f -- $secretsLocation/cluster.tfvars.json
rm -f -- $secretsLocation/terraform*
rm -f -- $secretsLocation/bootstrap.tfvars.json
rm -f -- $secretsLocation/cluster.tfvars.json 
rm -f -- $secretsLocation/registry-build.json
rm -f -- $secretsLocation/.openshift*
rm -f -- .openshift_install_state.json
rm -f -- $osServicePrincipalLocation
rm -f -- $secretsLocation/vnet.tfvars.json
rm -f -- ~/.kube/config
rm -f -- ~/.azure/az.json
rm -f -- ~/.azure/az.sess
rm -f -- ~/.aws/credentials
rm -f -- $secretsLocation/*bundle*
rm -f -- terraform* 
rm -f -- bootstrap.tfvars.json
rm -f -- cluster.tfvars.json
rm -f -- metadata.json 
rm -f -- registry-build.json 
rm -rf -- tls 
rm -rf -- tmp

mkdir -p auth 

pullSecretModified=$(stat -c %Y $pullSecretLocation 2> /dev/null) 
now=$(date +%s)
secondsSinceLastEdit=$((now-pullSecretModified))
if [ $secondsSinceLastEdit -gt $DAY ]; then
    xdg-open https://console.redhat.com/openshift/install/pull-secret 
    echo "paste in pull secret" 
    read pullSecret
    $pullSecret=$(sed -r ‘s/\s+//g’<<<$pullSecret)
    echo $pullSecret > $pullSecretLocation
    echo "updating pull secret" ; 
fi 
pullSecret=$(cat $pullSecretLocation)
cat $loginCommandLocation | bash
oc registry login --to=$registryPullSecretLocation
jq -s ".[0] * .[1]" $pullSecretLocation $registryPullSecretLocation > $secretsLocation/tmp
cat $secretsLocation/tmp | tr -d '[:space:]' > $pullSecretLocation


sshKey=$(cat $sshLocation)
sed "/pullSecret: */c pullSecret: '$pullSecret'" $installConfigTemplateLocation > $configLocation
sed -i "/sshKey: */c sshKey: '$sshKey'" $configLocation
sed -i "s/region: */region: '$region'/" $configLocation
if [[ $platform == "aws" ]]; then 
    sed -i "s/baseDomainResourceGroupName: *//" $configLocation

    # creates the aws creds.csv
    sed "s/exampleUsername/$awsUsername/" $awsConfigTemplateLocation > $awsConfigLocation
    sed -i "s/exampleAccessKeyID/$awsAccessKey/" $awsConfigLocation
    sed -i "s~exampleSecretAccessKey~$awsSecretAccessKey~" $awsConfigLocation
else 
    if [[ $platform == "azure" ]]; then 
        sed -i "s/baseDomainResourceGroupName: */baseDomainResourceGroupName: $baseDomainResourceGroupName/" $configLocation
    fi 
fi 
sed -i "s/name: */name: $clusterName/" $configLocation
sed -i "s/<platform>: */$platform:/" $configLocation
sed -i "s/baseDomain: */baseDomain: $baseDomain/" $configLocation


