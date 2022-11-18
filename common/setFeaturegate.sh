

oc get featuregate cluster -o json | jq '.spec = {"featureSet": "TechPreviewNoUpgrade"}' > tmp/TechPreviewNoUpgrade.json
oc apply -f tmp/TechPreviewNoUpgrade.json
if [[ $1 == "cgroupv2" ]]; then 
    oc get nodes.config cluster -o json | jq '.spec = {"cgroupMode": "v2"}' > tmp/cgroupsV2.json
    oc apply -f tmp/cgroupsV2.json 
fi 
