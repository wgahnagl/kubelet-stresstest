. ./config.sh

DAY=86400
loginCommandModified=$(stat -c %Y $loginCommandLocation) 
now=$(date +%s)
secondsSinceLastEdit=$((now-loginCommandModified))
if [ $secondsSinceLastEdit -gt $DAY ]; then
    xdg-open https://oauth-openshift.apps.ci.l2s4.p1.openshiftapps.com/oauth/token/display
    echo "paste in login command"
    read loginCommand
    echo $loginCommand > $loginCommandLocation
    echo "updating login command"
fi
rm -f -- metadata.json 
rm -f -- $counterSaveFile
rm -f -- kubeconfig.txt
rm -f -- cluster.tfvars.json
rm -f -- terraform*
rm -f -- $secretsLocation/kubeconfig
rm -f -- .openshift_install_state.json
rm -f -- $osServicePrincipalLocation

pullSecretModified=$(stat -c %Y $pullSecretLocation) 
now=$(date +%s)
secondsSinceLastEdit=$((now-pullSecretModified))
if [ $secondsSinceLastEdit -gt $DAY ]; then
    xdg-open https://console.redhat.com/openshift/install/pull-secret 
    echo "paste in pull secret" 
    read pullSecret
    echo $pullSecret > $pullSecretLocation
    echo "updating pull secret" ; else
    pullSecret=$(cat $pullSecretLocation)
fi 

sed "/pullSecret: */c pullSecret: '$pullSecret'" $installConfigTemplateLocation > $configLocation

sshKey=$(cat $sshLocation) 
sed -i "/sshKey: */c sshKey: '$sshKey'" $configLocation

sed -i "s/region: */region: '$region'/" $configLocation

sed -i "s/baseDomainResourceGroupName: */baseDomainResourceGroupName: $baseDomainResourceGroupName/" $configLocation

sed -i "s/name: */name: $clusterName/" $configLocation

sed -i "s/<platform>: */$platform:/" $configLocation

sed -i "s/baseDomain: */baseDomain: $baseDomain/" $configLocation
