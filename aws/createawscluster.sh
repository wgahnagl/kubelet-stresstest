# https://openshift-dev.signin.aws.amazon.com/console
# aws console 
. ./config.sh aws 
. ./setup.sh aws

aws iam get-user 

podman login -u $quayUsername -p $quayPassword --authfile auth/pull-secret
# oc registry login --registry registry.ci.openshift.org --to=auth/registry-build.json 
# jq -s ".[0] * .[1]" auth/registry-build.json ~/.docker/config.json > tmp.json
# mv tmp.json ~/.docker/config.json
$installerLocation --dir $secretsLocation create cluster
