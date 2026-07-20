#!/usr/bin/env bash
set -euo pipefail

# libffi 3.3 的 InstallDev 写死了 "$(GNU_TARGET_NAME)-gnu" 目录,
# musl 工具链下 configure 生成的目录是 *-openwrt-linux-musl,导致
# "cp: cannot stat .../aarch64-openwrt-linux-gnu/fficonfig.h"。
# 改成通配符,无论三元组叫什么都能匹配。
echo '>>> Patch libffi InstallDev fficonfig.h path for musl >>>'
sed -i 's|\$(PKG_BUILD_DIR)/\$(GNU_TARGET_NAME)-gnu/fficonfig.h|$(PKG_BUILD_DIR)/*-openwrt-linux-*/fficonfig.h|' \
  feeds/packages/libs/libffi/Makefile
grep -n 'fficonfig.h' feeds/packages/libs/libffi/Makefile
echo '<<< Completed libffi patch <<<'
