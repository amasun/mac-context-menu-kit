---
name: mac-context-menu-kit
description: 在 macOS 访达（Finder）中一键部署、定制或卸载右键菜单增强工具（支持原生 FinderSync 一级菜单扩展与 ~/Library/Services 系统服务工作流）。当用户希望增强 macOS 右键菜单、复制文件/目录路径、或扩展自定义 AI/效率右键菜单时使用。
---

# mac-context-menu-kit

用于在 macOS 访达（Finder）中快速安装、管理与扩展右键菜单工具集。

## 当前内置模块

- **copy-path**：
  - **FinderSync 扩展**（`/Applications/CopyPathFinder.app`）：在右键一级菜单直接显示「复制所在目录路径」「复制完整路径（含文件名）」以及空白处右键「复制当前文件夹路径」，支持本地磁盘与 `/Volumes` 外接磁盘。
  - **系统「服务」工作流**（`~/Library/Services/*.workflow`）：零编译依赖，可在右键「服务」子菜单调用，并支持在系统设置中绑定全局快捷键。

## 安装指令

在仓库根目录执行：

```zsh
# 同时安装 FinderSync 扩展 + 系统服务工作流（推荐）
zsh setup.sh --mode both

# 仅安装原生 FinderSync 扩展（需要 Xcode Command Line Tools）
zsh setup.sh --mode findersync

# 仅安装系统服务工作流（零依赖，适合无 swiftc 环境的 Mac）
zsh setup.sh --mode workflow
```

## 卸载指令

```zsh
zsh setup.sh --uninstall --mode all
```

## 定制与扩展规范

1. 新增右键功能模块时，请在 `modules/<module-name>/` 下组织源码，并在 `scripts/` 中提供对应安装脚本。
2. 如修改 `FinderSync.swift`：
   - 必须通过 `FileManager.default.mountedVolumeURLs` 覆盖外接卷（仅传 `/` 或 `/Volumes` 不会自动监控外接磁盘）。
   - 编译 `.appex` 时必须包含 `-parse-as-library` 与 `-Xlinker -e -Xlinker _NSExtensionMain`。
3. 如修改 `.workflow`：
   - 修改 `~/Library/Services/*.workflow` 后需刷新 `pbs -flush && pbs -update && killall Finder`。
