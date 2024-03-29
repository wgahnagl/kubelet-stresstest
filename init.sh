function help {
    echo "usage"
    echo "---------------"
    echo "if you don't already have a cluster running, launch one by using " 
    echo "./init launch [aws/azure]"
    echo ""
    echo "clusters can be destroyed by using" 
    echo "./init destroy" 
    echo "" 
    echo "logs can be collected by using"
    echo "./init getLogs"
    echo ""
    echo "featuregates" 
    echo "./init cgroupv2"
    echo "./init crun" 
    echo "" 
    echo "kubeburner can be activated by" 
    echo "./init kubeBurner"  

}
export KUBECONFIG="auth/auth/kubeconfig" 

if [[ -z "$1" ]]; then
    help
    exit 0
fi 

if [[ $1 == "destroy" ]]; then 
    ./common/destroyCluster.sh 
    exit 0
fi 

if [[ $1 == "launch" ]]; then 
    
    if [[ $2 == "aws" ]]; then
        ./aws/createawscluster.sh aws
    fi 
    if [[ $2 == "azure" ]]; then
        ./azure/createazurecluster.sh azure
    else 
        echo "unknown cluster cannot be launched. Options are aws or azure "
        help
    fi
fi

if [[ "$@" == *"cgroupv2"* ]]; then 
    ./common/setFeaturegate.sh cgroupv2
fi

if [[ "$@" == *"crun"* ]]; then 
    ./common/setFeaturegate.sh crun 
fi 
    
if [[ "$@" == *"kubeBurner"* ]]; then 
    ./kubeBurner/test-kube-burner.sh aws
fi 

if [[ "$@" == *"getLogs"* ]]; then 
    ./common/getLogs.sh $1
fi 

