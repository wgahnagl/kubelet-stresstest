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
fi

rm -f -- $secretsLocation/metadata.json 
rm -f -- $counterSaveFile
rm -f -- $secretsLocation/kubeconfig.txt
rm -f -- $secretsLocation/cluster.tfvars.json
rm -f -- $secretsLocation/terraform*
rm -f -- $secretsLocation/bootstrap.tfvars.json
rm -f -- $secretsLocation/cluster.tfvars.json 
rm -f -- $secretsLocation/registry-build.json
rm -f -- .openshift_install_state.json
rm -f -- $osServicePrincipalLocation
rm -f -- ~/.kube/config

rm -f -- terraform* 
rm -f -- bootstrap.tfvars.json
rm -f -- cluster.tfvars.json
rm -f -- metadata.json 
rm -f -- registry-build.json 

pullSecretModified=$(stat -c %Y $pullSecretLocation 2> /dev/null) 
now=$(date +%s)
secondsSinceLastEdit=$((now-pullSecretModified))
if [ $secondsSinceLastEdit -gt $DAY ]; then
    xdg-open https://console.redhat.com/openshift/install/pull-secret 
    echo "paste in pull secret" 
    read pullSecret
    echo $pullSecret > $pullSecretLocation
    echo "updating pull secret" ; 
fi 
pullSecret=$(cat $pullSecretLocation)

sed "/pullSecret: */c pullSecret: '$pullSecret'" $installConfigTemplateLocation > $configLocation

sshKey=$(cat $sshLocation) 
sed -i "/sshKey: */c sshKey: '$sshKey'" $configLocation

sed -i "s/region: */region: '$region'/" $configLocation

if [[ $platform == "aws" ]]; then 
    sed -i "s/baseDomainResourceGroupName: *//" $configLocation
else 
    if [[ $platform == "azure" ]]; then 
        sed -i "s/baseDomainResourceGroupName: */baseDomainResourceGroupName: $baseDomainResourceGroupName/" $configLocation
    fi 
fi 

sed -i "s/name: */name: $clusterName/" $configLocation

sed -i "s/<platform>: */$platform:/" $configLocation

sed -i "s/baseDomain: */baseDomain: $baseDomain/" $configLocation
