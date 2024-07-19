echo '🖖 READY TO PACK!'
dir=tarnishedcore-1

time=$(date +'%Y%m%d-%H%M%S')
dist=tmp/tarnishedcore-1-$time.tar.gz
current_dir=$(dirname $0)
deploy_dir=$HOME/workspace/$dir/tarnishedcore_deploy

yes | rm tmp/tarnishedcore-*.tar.gz;
yes | rm $deploy_dir/tarnishedcore-*.tar.gz;
sync
tar --exclude="tmp/cache/*" -czv -f $dist *
mkdir -p $deploy_dir
cp $current_dir/../config/local.Dockerfile $deploy_dir/Dockerfile
cp $current_dir/starter.sh $deploy_dir/
mv $dist $deploy_dir
echo $time > $deploy_dir/version
echo '🤟🏼 DONE!'