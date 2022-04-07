mkdir installers 2> /dev/null 
cd installers
oc registry login 2> /dev/null
oc adm release extract --tools registry.ci.openshift.org/ocp/release:4.11.0-0.ci-2022-04-03-041227
mkdir install 2> /dev/null
mv openshift-install* install
cd install
tar -xvzf openshift-install-linux*
cd ..
cd ..
