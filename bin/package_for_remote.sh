#!/bin/bash
function title {
  echo
  echo "################################################################################"
  echo "## $1"
  echo "################################################################################"
  echo
}

user=tarnished-user
ip=152.32.233.140

time=$(date +'%Y%m%d-%H%M%S')
cache_dir=tmp/deploy_cache
dist=$cache_dir/tarnishedcore-1-$time.tar.gz
current_dir=$(dirname $0)
dir=tarnishedcore-1
deploy_dir=/home/$user/workspace/$dir/deploys/$time
gemfile=$current_dir/../Gemfile
gemfile_lock=$current_dir/../Gemfile.lock
vendor_cache_dir=$current_dir/../vendor/cache

echo '🖖 READY TO PACK!'


title '🎎 打包源代码为压缩文件'
mkdir $cache_dir
bundle cache
sync
tar --exclude="tmp/cache/*" --exclude="tmp/deploy_cache/*" -czv -f $dist *

title '🐇 创建远程目录'
ssh $user@$ip "mkdir -p $deploy_dir/vendor"

title '👬🏻 上传压缩文件'
scp $dist $user@$ip:$deploy_dir
yes | rm $dist
scp $gemfile $user@$ip:$deploy_dir
scp $gemfile_lock $user@$ip:$deploy_dir
scp -r $vendor_cache_dir $user@$ip:$deploy_dir/vendor/

title '👬🏻 上传 Dockfile'
scp $current_dir/../config/remote.Dockerfile $user@$ip:$deploy_dir/Dockerfile

title '👬🏻 上传 starter(setup) 脚本'
scp $current_dir/starter_for_remote.sh $user@$ip:$deploy_dir/

title '👬🏻 上传版本号码'
ssh $user@$ip "echo $time > $deploy_dir/version"

title '🔥 执行远程脚本'
ssh $user@$ip "export version=$time; /bin/bash $deploy_dir/starter_for_remote.sh"

echo '🤟🏼 HAPPY PACKAGE!'
