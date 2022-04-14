#set -euo pipefail
. ./config.sh

mkdir installers 2> /dev/null 
cd installers
oc adm release extract -a ../$pullSecretLocation --from="registry.ci.openshift.org/ocp/release:4.10.8"
mkdir install 2> /dev/null
mv openshift-install* install
cd install
tar -xvzf openshift-install-linux*
cd ..
cd ..
