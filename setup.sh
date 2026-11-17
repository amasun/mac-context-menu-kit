#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"

MODE=""
ACTION="install"
UNIVERSAL_FLAG=""

print_usage() {
    cat <<EOF
用法: ./setup.sh [选项]

选项:
  --mode <findersync|workflow|both>   指定安装或卸载的模式（默认交互选择，或配合 --yes 使用 both）
  --uninstall                         卸载已安装的菜单
  --universal                         编译 FinderSync 通用二进制（arm64 + x86_64）
  -h, --help                          显示帮助信息
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            MODE="${2:-}"
            shift 2
            ;;
        --uninstall)
            ACTION="uninstall"
            shift
            ;;
        --universal)
            UNIVERSAL_FLAG="--universal"
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            print_usage
            exit 1
            ;;
    esac
done

if [[ -z "$MODE" ]]; then
    if [[ "$ACTION" == "uninstall" ]]; then
        MODE="all"
    else
        echo "请选择要安装的 macOS 访达右键菜单模式："
        echo "  1) both        同时安装 FinderSync 扩展 + 系统「服务」工作流（推荐）"
        echo "  2) findersync  仅安装原生 FinderSync 扩展（右键一级菜单，支持空白处右键）"
        echo "  3) workflow    仅安装系统「服务」工作流（零编译依赖，支持快捷键绑定）"
        printf "请输入选项 [1/2/3]（默认 1）: "
        read -r choice
        case "${choice:-1}" in
            1|both) MODE="both" ;;
            2|findersync) MODE="findersync" ;;
            3|workflow) MODE="workflow" ;;
            *) echo "无效选项"; exit 1 ;;
        esac
    fi
fi

if [[ "$ACTION" == "uninstall" ]]; then
    [[ "$MODE" == "both" ]] && MODE="all"
    zsh "$SCRIPTS_DIR/uninstall.sh" "$MODE"
    exit 0
fi

case "$MODE" in
    findersync)
        zsh "$SCRIPTS_DIR/install_findersync.sh" ${UNIVERSAL_FLAG:+"$UNIVERSAL_FLAG"}
        ;;
    workflow)
        zsh "$SCRIPTS_DIR/install_workflows.sh"
        ;;
    both)
        zsh "$SCRIPTS_DIR/install_workflows.sh"
        zsh "$SCRIPTS_DIR/install_findersync.sh" ${UNIVERSAL_FLAG:+"$UNIVERSAL_FLAG"}
        ;;
    *)
        echo "不支持的模式: $MODE"
        print_usage
        exit 1
        ;;
esac
