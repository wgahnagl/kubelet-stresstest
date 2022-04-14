# https://openshift-dev.signin.aws.amazon.com/console
# aws console 
. ./config.sh aws 
. ./common/setup.sh aws

aws configure import --csv file://$awsConfigLocation

podman login -u $quayUsername -p $quayPassword --authfile ~/.docker/config.json
oc registry login --registry registry.ci.openshift.org --to=auth/registry-build.json 
jq -s ".[0] * .[1]" auth/registry-build.json ~/.docker/config.json > tmp.json
mv tmp.json ~/.docker/config.json
$installerLocation --dir $secretsLocation create cluster
