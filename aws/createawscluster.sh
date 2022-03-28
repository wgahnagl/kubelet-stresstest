# https://openshift-dev.signin.aws.amazon.com/console
# aws console 
. ./config.sh
. ./setup.sh
aws iam get-user 
oc registry login --registry registry.ci.openshift.org --to=registry-build.json 
jq -s ".[0] * .[1]" registry-build.json ~/.docker/config.json > tmp.json
mv tmp.json ~/.docker/config.json
./openshift-install --dir ../$secretslocation create cluster
