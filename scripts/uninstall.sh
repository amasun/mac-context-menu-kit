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
    rm -rf "$SERVICES_DIR/复制目录树（Tree）.workflow"
    rm -rf "$SERVICES_DIR/复制为 AI 上下文（Markdown）.workflow"
    rm -rf "$SERVICES_DIR/在终端中打开.workflow"
    rm -rf "$SERVICES_DIR/Open with Antigravity IDE.workflow"
    rm -rf "$SERVICES_DIR/Open with VS Code.workflow"
    rm -rf "$SERVICES_DIR/Open with Cursor.workflow"
    rm -rf "$SERVICES_DIR/Open with Windsurf.workflow"
    rm -rf "$SERVICES_DIR/Open with Zed.workflow"
    rm -rf "$SERVICES_DIR/Open with Trae.workflow"
    rm -rf "$SERVICES_DIR/Open with Codex.workflow"
    rm -rf "$SERVICES_DIR/Claude - send.workflow"
    rm -rf "$SERVICES_DIR/Claude - codeHere.workflow"
    /System/Library/CoreServices/pbs -flush 2>/dev/null || true
    /System/Library/CoreServices/pbs -update 2>/dev/null || true
    echo "✅ 已卸载系统「服务」工作流"
fi

killall Finder 2>/dev/null || true
