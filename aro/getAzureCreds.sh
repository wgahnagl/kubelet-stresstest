credentials="$(oc -n kube-system get secret azure-credentials -o yaml)"
clientId=$(echo "$credentials" | grep "azure_client_id" | awk '{print $2}' | sed -n '1 p' | base64 -d)
clientSecret=$(echo "$credentials" | grep "azure_client_secret" | awk '{print $2}' | sed -n '1 p' | base64 -d)
tenantId=$(echo "$credentials" | grep "azure_tenant_id" | awk '{print $2}' | sed -n '1 p' | base64 -d)
az login --service-principal -u $clientId -p $clientSecret --tenant $tenantId
