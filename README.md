the goal of this project is to automatically create clusters, burn down nodes, and get logs from them to determine which parts fail first.
set up your config by running cp templates/config.sh . and edit with your values
to set up a cluster simply run ./creaeazurecluster.sh, and follow the prompts! 
once the cluster is up run ./testscript.sh, and then ./afterPods.sh once you're done! 

this repo technically has a few other ways to provision an openshift cluster, but azure is working the best. Everything in this repo is subject to change as this is a work in progress! 
