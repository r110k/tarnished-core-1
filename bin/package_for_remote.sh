#!/bin/bash
function title {
  echo
  echo "################################################################################"
  echo "## $1"
  echo "################################################################################"
  echo
}

title '💀 运行测试用例'
rspec || exit 1

user=tarnished-user
# ucloud
ip=152.32.233.140

# aliyun
# ip=47.116.30.230

time=$(date +'%Y%m%d-%H%M%S')
cache_dir=tmp/deploy_cache
dist=$cache_dir/tarnishedcore-1-$time.tar.gz
current_dir=$(dirname $0)
dir=tarnishedcore-1
deploy_dir=/home/$user/workspace/$dir/deploys/$time
gemfile=$current_dir/../Gemfile
gemfile_lock=$current_dir/../Gemfile.lock
vendor_dir=$current_dir/../vendor
vendor_api_doc=rspec_api_documentation
api_dir=$current_dir/../doc/api

echo '🖖 READY TO PACK!'

mkdir -p $cache_dir
title '🎎 打包源代码为压缩文件'
sync
tar --exclude="tmp/cache/*" --exclude="tmp/deploy_cache/*" --exclude="vendor/*" -czv -f $dist *

title '🔮 打包本地依赖'
bundle cache --quiet
tar -cz -f "$vendor_dir/cache.tar.gz" -C ./vendor cache
tar -cz -f "$vendor_dir/$vendor_api_doc.tar.gz" -C ./vendor $vendor_api_doc

title '🐇 创建远程目录'
ssh $user@$ip "mkdir -p $deploy_dir/vendor"

title '👬🏻 上传压缩文件'
scp $dist $user@$ip:$deploy_dir/
yes | rm $dist
scp $gemfile $user@$ip:$deploy_dir/
scp $gemfile_lock $user@$ip:$deploy_dir/
scp -r $vendor_dir/cache.tar.gz $user@$ip:$deploy_dir/vendor/
yes | rm $vendor_dir/cache.tar.gz
scp -r $vendor_dir/$vendor_api_doc.tar.gz $user@$ip:$deploy_dir/vendor/
yes | rm $vendor_dir/$vendor_api_doc.tar.gz

title '👬🏻 上传 Dockfile'
scp $current_dir/../config/remote.Dockerfile $user@$ip:$deploy_dir/Dockerfile

title '👬🏻 上传 starter(setup) 脚本'
scp $current_dir/starter_for_remote.sh $user@$ip:$deploy_dir/

title '👬🏻 上传 API 文档'
scp -r $api_dir $user@$ip:$deploy_dir/

title '👬🏻 上传版本号码'
ssh $user@$ip "echo $time > $deploy_dir/version"

title '🔥 执行远程脚本'
ssh $user@$ip "export version=$time; /bin/bash $deploy_dir/starter_for_remote.sh"

echo '🤟🏼 HAPPY PACKAGE!'
