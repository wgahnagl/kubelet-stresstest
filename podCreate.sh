. ./config.sh
echo $configLoaded

maxPodsCounter=1
maxPods=500
counter=0

touch "$counterSaveFile"
counterSave=$(cat $podCounterLocation)
if [ -z "$counterSave" ]; then
    counterSave="$counter"; else
    counter="$counterSave"; fi
NODERUNNING="true"
while "$NODERUNNING"
    do
    # get the ready status of the burner node
    tmp=$(oc get nodes | grep burner | awk '{print $2}')
    running="Ready"
    schedulingDisabled="Ready,SchedulingDisabled"
    echo "$tmp, $running, $maxPodsCounter"
    #if the burner node is still in the ready status
    if [[ $tmp == $running ]]; then
        # get the number of pods running
        runningPods=$(oc get pods -n burner | wc -ll)
        #if the amount of running pods are greater than the current pod density, increase the density by 100
        if [[ "$runningPods" -ge $(($maxPods - 10)) ]]; then
            maxPods=$((($maxPodsCounter*100) +$maxPods))
            #replace the current max pods with the increased max pods
            touch $tmpLocation/setmaxpods"$maxPodsCounter".yaml
            sed "s/maxPods:.*/maxPods: "$maxPods"/g" setmaxpods.yaml > $tmpLocation/setmaxpods"$maxPodsCounter".yaml
            echo "increasing pod density to $maxPods"
            oc apply -f $tmpLocation/setmaxpods"$maxPodsCounter".yaml
            maxPodsCounter=$(($maxPodsCounter + 1))
            # be sure the MCP is updated with the correct pod density
            while ! oc get mcp | grep burner | awk '{print tolower($4)}'
            do
                sleep 1
            done
            echo "mcp updated!"
        fi
        sed "s/{{.Iteration}}.*/"$counter"/g" templates/pod.yaml > $tmplLocation/pod"$counter".yaml
        oc create -f $tmpLocation/pod"$counter".yaml
        rm $tmpLocation/pod"$counter".yaml
        counter=$(($counter+1))
        echo $counter > "$counterSaveFile"
    else
        if [[ $tmp == $schedulingDisabled ]]; then 
            oc adm uncordon $WORKINGNODE 
        else 
            echo "Burner node $WORKINGNODE entered $tmp state"
            NODERUNNING="false"
        fi 
    fi
done
