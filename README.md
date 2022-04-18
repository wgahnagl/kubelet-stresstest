# Kubelet Stress Testing Toolkit
a library of scripts useful for stress testing kubernetes clusters 

## Getting Started 
first, copy the template config out of the templates/config.sh folder, and rename it to config.sh in the top level of your directory. 
Edit the values at the top of the file, and be sure to check the values on the section beneath. 
then simply run ./init.sh to see the help and begin testing. 

## Commands 
#### ./init.sh launch [aws/azure] 
launches an aws or azure cluster with credentials provided during setup, and automatically runs test scripts on the launched cluster 

#### ./init.sh [path] 
copies an existing kubeconfig to the auth directory of the project and runs the test scripts

#### ./init.sh destroy 
destroys the most recently launched cluster 

#### ./init collect 
collects logs from the cluster described in auth/kubeconfig
