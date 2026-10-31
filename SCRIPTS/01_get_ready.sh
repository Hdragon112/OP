#!/bin/bash

# 这个脚本的作用是从不同的仓库中克隆openwrt相关的代码，并进行一些处理

# 定义一个函数，用来克隆指定的仓库和分支
clone_repo() {
  # 参数1是仓库地址，参数2是分支名，参数3是目标目录
  repo_url=$1
  branch_name=$2
  target_dir=$3
  # 克隆仓库到目标目录，并指定分支名和深度为1
  git clone -b $branch_name --depth 1 $repo_url $target_dir
}

# 定义一些变量，存储仓库地址和分支名
latest_release="$(curl -s https://github.com/openwrt/openwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/[2-9][5-9]/p' | sed -n 1p | sed 's/.tar.gz//g')"
#openwrt_repo="https://github.com/openwrt/openwrt.git"
openwrt_repo="https://github.com/Hdragon112/openwrt"
#openwrt_add_repo="https://github.com/QiuSimons/OpenWrt-Add.git"
openwrt_add_repo="https://github.com/Hdragon112/OpenWrt-Add"

# 开始克隆仓库，并行执行
#clone_repo $openwrt_repo $latest_release openwrt &
clone_repo $openwrt_repo openwrt-25.12 openwrt &
clone_repo $openwrt_add_repo OP25 OpenWrt-Add &

# 等待所有后台任务完成
wait

# 退出脚本
exit 0
