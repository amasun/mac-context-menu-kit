#!/bin/zsh
set -euo pipefail

MODE="${1:-all}"
INSTALL_APP="/Applications/CopyPathFinder.app"
SERVICES_DIR="$HOME/Library/Services"

if [[ "$MODE" == "findersync" || "$MODE" == "all" ]]; then
    pluginkit -e ignore -i com.amasun.CopyPathFinder.Extension 2>/dev/null || true
    pluginkit -r "$INSTALL_APP/Contents/PlugIns/CopyPathFinderExtension.appex" 2>/dev/null || true
    rm -rf "$INSTALL_APP"
    echo "✅ 已卸载 FinderSync 扩展（CopyPathFinder.app）"
fi

if [[ "$MODE" == "workflow" || "$MODE" == "all" ]]; then
    rm -rf "$SERVICES_DIR/复制所在目录路径.workflow"
    rm -rf "$SERVICES_DIR/复制完整路径（含文件名）.workflow"
    /System/Library/CoreServices/pbs -flush 2>/dev/null || true
    /System/Library/CoreServices/pbs -update 2>/dev/null || true
    echo "✅ 已卸载系统「服务」工作流"
fi

killall Finder 2>/dev/null || true
