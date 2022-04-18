function help {
    echo "usage"
    echo "---------------"
    echo "if you don't already have a cluster running, launch one by using " 
    echo "./init launch [aws/azure]"
    echo ""
    echo "if you already have a cluster, tests can be run by using " 
    echo "./init [path to kubeconfig]"
    echo "" 
    echo "clusters can be destroyed by using" 
    echo "./init destroy" 
    echo "" 
    echo "logs can be collected by using"
    echo "./init collect" 

}


if [[ -z "$1" ]]; then
    help
    exit 0
fi 

if [[ $1 == "launch" ]]; then 
    
    if [[ $2 == "aws" ]]; then
        ./aws/createawscluster.sh
    fi 
    if [[ $2 == "azure" ]]; then
        echo "azure"
        ./azure/createazurecluster.sh
    else 
        echo "unknown cluster cannot be launched. Options are aws or azure "
        help
        exit 0
    fi
    
fi

if [[ $1 == "collect"  ]]; then 
    ./common/afterPods.sh
    exit 0
fi 

if [[ $1 == "destroy" ]]; then 
    ./common/destroyCluster.sh 
    exit 0
fi 

if [[ -f $1 ]]; then 
      cp $1 auth/kubeconfig
      ./common/setup
      ./common/testscript.sh
      exit 0
  else 
      echo "file not found" 
      help 
fi 
