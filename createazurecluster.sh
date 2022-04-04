. ./config.sh azure
. ./setup.sh azure
echo $configLoaded

# login and store the credentials 
az login --scope https://graph.windows.net//.default
credentials=$(az ad sp create-for-rbac --role Owner --name $servicePrincipalName) 
appId=$(echo "$credentials" | grep appId | awk '{print $2}' | sed 's/,//' | sed 's/"//g')
password=$(echo "$credentials" | grep password | awk '{print $2}' | sed 's/,//' | sed 's/"//g')  
echo $appId
echo $password

az ad sp create-for-rbac --role Owner --name $servicePrincipalName \
   | jq --arg sub_id "$(az account show | jq -r '.id')" \
     '{subscriptionId:$sub_id,clientId:.appId, clientSecret:.password,tenantId:.tenant}' \
     > $osServicePrincipalLocation

az ad app permission add --id $appId \
     --api 00000002-0000-0000-c000-000000000000 \
     --api-permissions 824c81eb-e3f8-4ee6-8f6d-de7f50d565b7=Role

az role assignment create --role "User Access Administrator"\
    --assignee-object-id $(az ad sp show --id $appId --query "objectId" -o tsv)

# oc login that gets updated by the setup script
cat $loginCommandLocation | bash 
oc registry login --registry registry.ci.openshift.org --to=registry-build.json 
jq -s ".[0] * .[1]" registry-build.json ~/.docker/config.json > tmp.json
mv tmp.json ~/.docker/config.json
./getNewInstaller.sh
./$installerLocation --dir $secretsLocation create cluster
