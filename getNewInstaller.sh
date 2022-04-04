mkdir installers 
cd installers
oc registry login 
oc adm release extract --tools registry.ci.openshift.org/ocp/release:4.11.0-0.ci-2022-04-03-041227
mkdir install
mv openshift-install* install
cd install
tar -xvzf openshift-install-linux*
cd ..
cd ..
