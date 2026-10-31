#!/bin/bash
clear

### 基础部分 ###
# 使用 O2 级别的优化
#sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 定义预期的内核版本
#SUPPORTED_KERNEL="6.12"

#current_version=$(sed -n 's/^KERNEL_PATCHVER:=//p' ./target/linux/rockchip/Makefile) # 如 6.12
#if [ -z "${current_version}" ]; then
#    echo "Error: Failed to extract KERNEL_PATCHVER from ./target/linux/rockchip/Makefile"
#    exit 1
#fi
#if [[ "${SUPPORTED_KERNEL}" != "${current_version}" ]]; then
#    echo "##########
#      错误：
#      编译的内核版本为 ${current_version} ，
#      预期的版本为 ${SUPPORTED_KERNEL}
#    ##########"
#    exit 1
#fi
#export KERNEL_VERSION="${SUPPORTED_KERNEL}"
#echo "KERNEL_VERSION=${SUPPORTED_KERNEL}" | tee -a "$GITHUB_ENV" 
# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
sed -i '/CONFIG_BUILDBOT/d' include/feeds.mk
sed -i 's/;)\s*\\/; \\/' include/feeds.mk

### Add luci-app-turboacc ###
curl -sSL https://raw.githubusercontent.com/mufeng05/turboacc/main/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

### ADD PKG 部分 ###
cp -rf ../OpenWrt-Add ./package/new
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls,smartdns}
rm -rf feeds/luci/applications/{luci-app-frps,luci-app-frpc,luci-app-zerotier}

# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 27.x feeds/packages/lang/golang

# apk
pushd feeds/luci
wget -qO- https://github.com/sbwml/r4s_build_script/raw/refs/heads/master/openwrt/patch/luci/applications/luci-app-package-manager/0001-luci-app-package-manager-support-installing-uploaded.patch | patch -p1
popd

# Boost 通用即插即用
mkdir -p feeds/packages/net/miniupnpd/patches
wget https://github.com/miniupnp/miniupnp/commit/0e8c68d.patch -O feeds/packages/net/miniupnpd/patches/0e8c68d.patch
sed -i 's,/miniupnpd/,/,g' ./feeds/packages/net/miniupnpd/patches/0e8c68d.patch
wget https://github.com/miniupnp/miniupnp/commit/21541fc.patch -O feeds/packages/net/miniupnpd/patches/21541fc.patch
sed -i 's,/miniupnpd/,/,g' ./feeds/packages/net/miniupnpd/patches/21541fc.patch
wget https://github.com/miniupnp/miniupnp/commit/b78a363.patch -O feeds/packages/net/miniupnpd/patches/b78a363.patch
sed -i 's,/miniupnpd/,/,g' ./feeds/packages/net/miniupnpd/patches/b78a363.patch
wget https://github.com/miniupnp/miniupnp/commit/8f2f392.patch -O feeds/packages/net/miniupnpd/patches/8f2f392.patch
sed -i 's,/miniupnpd/,/,g' ./feeds/packages/net/miniupnpd/patches/8f2f392.patch
wget https://github.com/miniupnp/miniupnp/commit/60f5705.patch -O feeds/packages/net/miniupnpd/patches/60f5705.patch
sed -i 's,/miniupnpd/,/,g' ./feeds/packages/net/miniupnpd/patches/60f5705.patch
wget https://github.com/miniupnp/miniupnp/commit/3f3582b.patch -O feeds/packages/net/miniupnpd/patches/3f3582b.patch
sed -i 's,/miniupnpd/,/,g' ./feeds/packages/net/miniupnpd/patches/3f3582b.patch
wget https://github.com/miniupnp/miniupnp/commit/6aefa9a.patch -O feeds/packages/net/miniupnpd/patches/6aefa9a.patch
sed -i 's,/miniupnpd/,/,g' ./feeds/packages/net/miniupnpd/patches/6aefa9a.patch
pushd feeds/packages
patch -p1 <../../../PATCH/pkgs/miniupnpd/01-set-presentation_url.patch
patch -p1 <../../../PATCH/pkgs/miniupnpd/02-force_forwarding.patch
popd
pushd feeds/luci
patch -p1 <../../../PATCH/pkgs/miniupnpd/luci-upnp-support-force_forwarding-flag.patch
popd

# Build date and add date prefix
sed -i '/#Dropbear/i\sed -i '\''/BUILD_ID/d'\'' /etc/os-release\necho "BUILD_ID='\''R261024" >> /etc/os-release' package/new/addition-trans-zh/files/zzz-default-settings
sed -i "s|\$(VERSION_DIST_SANITIZED)-|\$(VERSION_DIST_SANITIZED)-$(TZ=Asia/Shanghai date +%Y%m%d)-|" include/image.mk

### 最后的收尾工作 ###
# Lets Fuck
mkdir -p package/base-files/files/usr/bin
cp -rf ../OpenWrt-Add/core/tools/clean-overlay.sh ./package/base-files/files/usr/bin/fuck
# 生成默认配置及缓存
rm -rf .config

./scripts/feeds update -i
./scripts/feeds install -a

#exit 0
