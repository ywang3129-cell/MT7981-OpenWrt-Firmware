#!/usr/bin/env bash
set -euo pipefail

# libffi 3.3 的 Build/InstallDev 里有一行历史遗留的死代码:
#   $(CP) $(PKG_BUILD_DIR)/$(GNU_TARGET_NAME)-gnu/fficonfig.h $(1)/usr/include/
# 这行早于本 Makefile 加入 PKG_INSTALL:=1 之前就存在,PKG_INSTALL:=1
# 启用后 `make install` 已经把 fficonfig.h 装进了 $(PKG_INSTALL_DIR)/usr/include/,
# 会被上面那句 `$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h` 一并拷走,
# 这行死代码永远找不到它假设的目录,注定失败。
# 上游 openwrt/packages master 分支已经在升级到 libffi 3.4.7 时删除了
# 这三行(不是改路径,是整段删掉),这里对 openwrt-21.02 分支的旧
# Makefile 做同样的清理,而不是猜一个新路径。
echo '>>> Patch libffi: drop dead fficonfig.h InstallDev line >>>'
python3 - <<'PYEOF'
path = "feeds/packages/libs/libffi/Makefile"
with open(path, encoding="utf-8", newline="") as f:
    content = f.read()

old = (
    "\t$(CP) \\\n"
    "\t\t$(PKG_BUILD_DIR)/$(GNU_TARGET_NAME)-gnu/fficonfig.h \\\n"
    "\t\t$(1)/usr/include/\n"
)

if old not in content:
    raise SystemExit(f"expected dead-code block not found in {path}; libffi Makefile changed upstream, re-check")

content = content.replace(old, "")
with open(path, "w", encoding="utf-8", newline="") as f:
    f.write(content)
print("removed dead fficonfig.h InstallDev block")
PYEOF
grep -n 'fficonfig' feeds/packages/libs/libffi/Makefile || echo '(no fficonfig references remain, expected)'
echo '<<< Completed libffi patch <<<'
