#set -euo pipefail
. ./config.sh

mkdir installers 2> /dev/null 
cd installers
oc adm release extract -a ../$pullSecretLocation --tools quay.io/openshift-release-dev/ocp-release:4.10.10-x86_64
mkdir install 2> /dev/null
mv openshift-install* install
cd install
tar -xvzf openshift-install-linux*
cd ..
cd ..
