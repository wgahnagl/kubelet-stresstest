if [[ -z "$1" ]]; then 
    echo "please specify the type of cluster you want to test on"
    exit 0
fi 

if [[ $1 == "aws" ]]; then
    ./aws/createawscluster.sh
else
    if [[ $1 == "azure" ]]; then
        echo "azure"
        ./azure/createazurecluster.sh
    else 
        echo "cluster type not recognized"
        exit 0
    fi
fi
