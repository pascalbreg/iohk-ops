#echo "stopping 0"
#nixops ssh node0-coordinator -- systemctl kill cardano-node
#for i in {1..100}; do echo "stopping $i"; nixops ssh node$i -- systemctl kill cardano-node; done

#Hack, but can't imagine better
#yes_file=/tmp/pos-prototype-deployment-yes-file.txt
#yes | head -100 > $yes_file

cmd=$1

if [[ "$cmd" == "" ]]; then
  cmd=redeploy
fi

deploy_args=$2

batch=50
pause=600
node_count=`nixops info --plain | grep node | wc -l`

function node_list {
  i=$1
  j=$((i*batch))
  while [[ $j -lt $((i*batch+batch)) ]]; do
   echo -n "node$j "
   j=$((j+1))
  done
}

function runBatched {
pause_=$3
for i in {0..20}; do
  echo "$2 nodes $((i*batch))..$((i*batch+batch-1))"
  #j=$((i*batch))
  #pids=''
  #while [[ $j -lt $((i*batch+batch)) ]]; do
  #  $1 $j 1>&2 <$yes_file &
  #  pids="$pids $!"
  #  j=$((j+1))
  #done
  #echo "Pids: $pids"
  #wait
  echo $1 `node_list $i`
  yes | $1 `node_list $i`
  if [[ $((i*batch+batch)) -gt $node_count ]]; then
    break;
  fi
  echo "Pausing for $pause_ sec"
  sleep ${pause_}s
done

}

function stop_node {
  nixops stop --include $@
}

function deploy_node {
  nixops deploy -d cardano -I nixpkgs=~/nixpkgs --show-trace $deploy_args --include $@
}

case "$cmd" in
   stop | redeploy )
     runBatched stop_node "Stopping" $((pause/2))
     ;;
esac
if [[ "$cmd" == "redeploy" ]]; then
     echo "Pausing for $pause sec"
     sleep ${pause}s
fi
case "$cmd" in
   redeploy | start )
     runBatched deploy_node "Deploying" $pause
     ;;
esac