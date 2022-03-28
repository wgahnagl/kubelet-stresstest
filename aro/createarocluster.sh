az login --scope https://management.core.windows.net//.default
az provider register -n Microsoft.RedHatOpenShift --wait
az provider register -n Microsoft.Compute --wait
az provider register -n Microsoft.Storage --wait
az provider register -n Microsoft.Authorization --wait
az feature register --namespace Microsoft.RedHatOpenShift --name preview
./getAzureCreds.sh
export LOCATION=eastus                 # the location of your cluster
export RESOURCEGROUP=wgahnagl-rg            # the name of the resource group where you want to create your cluster
export CLUSTER=wgahnagl-002                # the name of your cluster
az group create \
  --name $RESOURCEGROUP \
  --location $LOCATION
az network vnet create \
   --resource-group $RESOURCEGROUP \
   --name aro-vnet \
   --address-prefixes 10.0.0.0/22
az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --name master-subnet \
  --address-prefixes 10.0.0.0/23 \
  --service-endpoints Microsoft.ContainerRegistry
az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --name worker-subnet \
  --address-prefixes 10.0.2.0/23 \
  --service-endpoints Microsoft.ContainerRegistry
az network vnet subnet update \
  --name master-subnet \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --disable-private-link-service-network-policies true
az aro create \
  --resource-group $RESOURCEGROUP \
  --name $CLUSTER \
  --vnet aro-vnet \
  --master-subnet master-subnet \
  --worker-subnet worker-subnet \
  --pull-secret @pull-secret
kubectl config view --raw > kubeconfig.txt
export KUBECONFIG=kubeconfig.txt
../testscript.sh 

