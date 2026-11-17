# mac-context-menu-kit

macOS 访达（Finder）右键菜单增强工具集 —— 同时提供 **原生 FinderSync 扩展** 与 **系统「服务」工作流（Workflow）**，开箱即用、可模块化扩展，方便分发给其他 Mac 用户或配合 AI 工作流集成。

## 当前功能模块：`copy-path`（一键复制路径）

| 右键场景 | FinderSync 一级菜单 | 系统「服务」工作流 |
| :--- | :--- | :--- |
| 右键点击**文件 / `.app` 包** | **复制所在目录路径**（父目录）<br>**复制完整路径（含文件名）** | **复制所在目录路径**（父目录）<br>**复制完整路径（含文件名）** |
| 右键点击**普通文件夹** | **复制所在目录路径**（自身路径）<br>**复制完整路径（含文件名）** | **复制所在目录路径**（自身路径）<br>**复制完整路径（含文件名）** |
| 右键点击**文件夹空白处** | **复制当前文件夹路径** | — |
| 多选文件/文件夹 | 自动去重 / 按行分隔，末尾无多余换行 | 自动去重 / 按行分隔，末尾无多余换行 |
| 外接磁盘（`/Volumes/*`） | 自动监听挂载/卸载并生效 | 原生支持 |
| 全局快捷键绑定 | — | 支持在「系统设置 → 键盘 → 键盘快捷键 → 服务」中绑定 |

---

## 快速安装（分发到任意 Mac）

### 1. 克隆仓库并安装

```zsh
git clone https://github.com/amasun/mac-context-menu-kit.git
cd mac-context-menu-kit
chmod +x setup.sh scripts/*.sh
./setup.sh
```

或者直接指定模式静默安装：

```zsh
# 同时安装 FinderSync 扩展 + 系统服务工作流（推荐）
./setup.sh --mode both

# 仅安装原生 FinderSync 扩展（右键一级菜单，需已安装 Xcode Command Line Tools）
./setup.sh --mode findersync

# 仅安装系统「服务」工作流（零编译依赖，任何 Mac 开箱即用）
./setup.sh --mode workflow

# 编译 Apple Silicon + Intel 通用二进制（Universal Binary）
./setup.sh --mode findersync --universal
```

### 2. 卸载

```zsh
# 全部卸载
./setup.sh --uninstall

# 仅卸载其中一个
./setup.sh --uninstall --mode findersync
./setup.sh --uninstall --mode workflow
```

---

## 常见问题排查

1. **安装 FinderSync 后右键没看到菜单？**
   - 打开 **「系统设置 → 通用 → 登录项与扩展 → 访达」**，确认已勾选 **「复制路径（CopyPathFinder）」**。
   - 也可以直接双击运行 `/Applications/CopyPathFinder.app`，会自动跳转到该设置页面。
2. **目标 Mac 没有安装 `swiftc`？**
   - 运行 `xcode-select --install` 安装基础命令行工具后重跑 `./setup.sh --mode findersync`；
   - 或者直接使用零依赖的 `./setup.sh --mode workflow`。

---

## 目录结构

```text
mac-context-menu-kit/
├── setup.sh                      # 统一安装 / 卸载入口
├── SKILL.md                      # AI Agent Skill 描述文件
├── scripts/
│   ├── install_findersync.sh     # 编译、Ad-Hoc 签名并注册 FinderSync 扩展
│   ├── install_workflows.sh      # 生成并注册 ~/Library/Services 工作流
│   └── uninstall.sh              # 一键卸载脚本
└── modules/
    └── copy-path/                # 一键复制路径模块源码
```

## License

[MIT](LICENSE)
