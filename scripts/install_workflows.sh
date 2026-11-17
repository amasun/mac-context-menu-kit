#!/bin/zsh
set -euo pipefail

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

detect_app() {
    for app_name in "$@"; do
        if [[ -d "/Applications/${app_name}.app" ]]; then
            echo "/Applications/${app_name}.app"
            return 0
        fi
        if [[ -d "$HOME/Applications/${app_name}.app" ]]; then
            echo "$HOME/Applications/${app_name}.app"
            return 0
        fi
    done
    return 1
}

create_workflow() {
    local workflow_name="$1"
    local menu_title="$2"
    local description="$3"
    local script_content="$4"
    local send_types_xml="$5"
    local required_context_xml="${6:-}"
    local uuid1 uuid2 uuid3
    uuid1="$(uuidgen)"
    uuid2="$(uuidgen)"
    uuid3="$(uuidgen)"

    local wf_dir="$SERVICES_DIR/${workflow_name}.workflow/Contents"
    mkdir -p "$wf_dir"

    cat > "$wf_dir/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>${menu_title}</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
${required_context_xml}
            <key>NSSendFileTypes</key>
            <array>
${send_types_xml}
            </array>
        </dict>
    </array>
    <key>NSServicesUsageDescription</key>
    <string>${description}</string>
</dict>
</plist>
EOF

    cat > "$wf_dir/document.wflow" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>523</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.path</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>2.0.3</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMParameterProperties</key>
				<dict>
					<key>COMMAND_STRING</key>
					<dict/>
					<key>CheckedForUserDefaultShell</key>
					<dict/>
					<key>inputMethod</key>
					<dict/>
					<key>shell</key>
					<dict/>
					<key>source</key>
					<dict/>
				</dict>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.path</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>运行 Shell 脚本</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key>
					<string>${script_content}</string>
					<key>CheckedForUserDefaultShell</key>
					<true/>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/zsh</string>
					<key>source</key>
					<string></string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>2.0.3</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanUseCurrentWorkingDirectoryWhenRun</key>
				<false/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>${uuid1}</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
					<string>脚本</string>
					<string>运行</string>
				</array>
				<key>OutputUUID</key>
				<string>${uuid2}</string>
				<key>UUID</key>
				<string>${uuid3}</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict>
					<key>0</key>
					<dict>
						<key>default value</key>
						<integer>0</integer>
						<key>name</key>
						<string>inputMethod</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>0</string>
					</dict>
					<key>1</key>
					<dict>
						<key>default value</key>
						<false/>
						<key>name</key>
						<string>CheckedForUserDefaultShell</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>1</string>
					</dict>
					<key>2</key>
					<dict>
						<key>default value</key>
						<string></string>
						<key>name</key>
						<string>source</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>2</string>
					</dict>
					<key>3</key>
					<dict>
						<key>default value</key>
						<string></string>
						<key>name</key>
						<string>COMMAND_STRING</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>3</string>
					</dict>
					<key>4</key>
					<dict>
						<key>default value</key>
						<string>/bin/sh</string>
						<key>name</key>
						<string>shell</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>4</string>
					</dict>
				</dict>
				<key>isViewVisible</key>
				<true/>
				<key>location</key>
				<string>309.000000:252.000000</string>
				<key>nibPath</key>
				<string>/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib</string>
			</dict>
			<key>isViewVisible</key>
			<true/>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>applicationBundleIDsByPath</key>
		<dict/>
		<key>applicationPathsByPath</key>
		<dict/>
		<key>inputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject</string>
		<key>outputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>presentationMode</key>
		<integer>15</integer>
		<key>processesInput</key>
		<integer>0</integer>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<integer>0</integer>
		<key>systemImageName</key>
		<string>NSActionTemplate</string>
		<key>useUniversalActionImport</key>
		<true/>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
EOF
}

TYPES_ALL='                <string>public.item</string>
                <string>public.folder</string>
                <string>public.directory</string>'
TYPES_FOLDER='                <string>public.folder</string>'
FINDER_CONTEXT='            <key>NSRequiredContext</key>
            <dict>
                <key>NSApplicationIdentifier</key>
                <string>com.apple.finder</string>
            </dict>'

# 1. 基础路径复制服务（始终安装）
DIR_SCRIPT='export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
results=()
for f in "$@"; do
    f="${f%/}"
    [[ -z "$f" ]] &amp;&amp; f="/"
    if [[ -d "$f" &amp;&amp; ! "$f" =~ \.(app|bundle|framework|plugin|prefPane|qlgenerator|saver|wdgt|workflow|xcodeproj|xcworkspace)$ ]]; then
        dir="$f"
    else
        dir="$(dirname "$f")"
    fi
    results+=("$dir")
done
typeset -U results
printf "%s" "${(F)results}" | pbcopy'

create_workflow \
    "复制所在目录路径" \
    "复制所在目录路径" \
    "复制选中文件夹本身的路径，或选中文件所在的目录路径" \
    "$DIR_SCRIPT" \
    "$TYPES_ALL"

FULL_SCRIPT='export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
results=()
for f in "$@"; do
    f="${f%/}"
    [[ -z "$f" ]] &amp;&amp; f="/"
    results+=("$f")
done
printf "%s" "${(F)results}" | pbcopy'

create_workflow \
    "复制完整路径（含文件名）" \
    "复制完整路径（含文件名）" \
    "复制选中文件或文件夹的完整路径（路径+名称）" \
    "$FULL_SCRIPT" \
    "$TYPES_ALL"

TREE_SCRIPT='export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
/usr/bin/python3 - "$1" <<'\''PYEOF'\'' | pbcopy
import os, sys

target = sys.argv[1]
root = target if os.path.isdir(target) and not target.endswith((".app", ".bundle", ".workflow")) else os.path.dirname(target)
ignore = {".git", "node_modules", "dist", "build", ".next", ".nuxt", "__pycache__", ".venv", "venv", "Pods", "DerivedData", ".DS_Store"}
lines = [os.path.basename(root.rstrip("/")) + "/"]
count = 0
max_entries = 300
max_depth = 4

def walk(path, prefix, depth):
    global count
    if depth >= max_depth or count >= max_entries:
        return
    try:
        entries = [e for e in os.listdir(path) if not e.startswith(".") and e not in ignore]
    except OSError:
        return
    entries.sort(key=lambda name: (not os.path.isdir(os.path.join(path, name)), name.lower()))
    for idx, name in enumerate(entries):
        if count >= max_entries:
            break
        count += 1
        full = os.path.join(path, name)
        is_dir = os.path.isdir(full) and not name.endswith((".app", ".bundle", ".workflow"))
        is_last = idx == len(entries) - 1
        lines.append(f"{prefix}{\"└── \" if is_last else \"├── \"}{name}{\"/\" if is_dir else \"\"}")
        if is_dir:
            walk(full, prefix + ("    " if is_last else "│   "), depth + 1)

walk(root, "", 0)
if count >= max_entries:
    lines.append(f"... (已达到 {max_entries} 项上限)")
sys.stdout.write("\n".join(lines))
PYEOF'

create_workflow \
    "复制目录树（Tree）" \
    "复制目录树（Tree）" \
    "生成排除 node_modules/.git 等目录的树状结构并复制到剪贴板" \
    "$TREE_SCRIPT" \
    "$TYPES_ALL"

MD_CONTEXT_SCRIPT='export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
/usr/bin/python3 - "$@" <<'\''PYEOF'\'' | pbcopy
import os, sys

ignore = {".git", "node_modules", "dist", "build", ".next", "__pycache__", ".venv", "venv", "Pods", "DerivedData", ".DS_Store"}
files = []
for arg in sys.argv[1:]:
    if os.path.isdir(arg) and not arg.endswith((".app", ".bundle", ".workflow")):
        for root, dirs, names in os.walk(arg):
            dirs[:] = sorted([d for d in dirs if not d.startswith(".") and d not in ignore])
            for n in sorted(names):
                if not n.startswith("."):
                    files.append(os.path.join(root, n))
                if len(files) >= 30:
                    break
            if len(files) >= 30:
                break
    elif os.path.isfile(arg):
        files.append(arg)
    if len(files) >= 30:
        break

blocks = []
total = 0
for fp in files:
    try:
        size = os.path.getsize(fp)
        if size > 150 * 1024 or total + size > 512 * 1024:
            continue
        with open(fp, "rb") as f:
            raw = f.read()
        if b"\x00" in raw:
            continue
        text = raw.decode("utf-8")
    except Exception:
        continue
    total += size
    ext = os.path.splitext(fp)[1].lstrip(".").lower()
    blocks.append(f"### {os.path.basename(fp)}\n```{ext}\n{text}\n```")

sys.stdout.write("\n\n".join(blocks) if blocks else "⚠️ 未找到可读取的文本/代码文件")
PYEOF'

create_workflow \
    "复制为 AI 上下文（Markdown）" \
    "复制为 AI 上下文（Markdown）" \
    "将选中的代码文件打包为 Markdown 代码块上下文并复制到剪贴板" \
    "$MD_CONTEXT_SCRIPT" \
    "$TYPES_ALL"

echo "✅ 已安装基础路径与 AI 上下文服务："
echo "   • 复制所在目录路径"
echo "   • 复制完整路径（含文件名）"
echo "   • 复制目录树（Tree）"
echo "   • 复制为 AI 上下文（Markdown）"
echo ""
echo "🔍 正在检测本机已安装的终端、IDE 与 AI 工具..."

# 终端自动检测
TERM_APP=""
for candidate in "/Applications/Ghostty.app" "/Applications/Warp.app" "/Applications/iTerm.app" "/System/Applications/Utilities/Terminal.app"; do
    if [[ -d "$candidate" ]]; then
        TERM_APP="$candidate"
        break
    fi
done
if [[ -n "$TERM_APP" ]]; then
    TERM_SCRIPT="f=\"\$1\"
[ ! -d \"\$f\" ] &amp;&amp; f=\"\$(dirname \"\$f\")\"
open -a \"$TERM_APP\" \"\$f\""
    create_workflow \
        "在终端中打开" \
        "在终端中打开" \
        "在终端中打开当前目录" \
        "$TERM_SCRIPT" \
        "$TYPES_ALL"
    echo "   ✓ 检测到终端 ($TERM_APP) → 已安装「在终端中打开」"
fi

# 2. Antigravity IDE
if AGY_APP="$(detect_app "Antigravity IDE" "Antigravity")"; then
    AGY_SCRIPT="for f in \"\$@\"
do
    open -a \"$AGY_APP\" \"\$f\"
done"
    create_workflow \
        "Open with Antigravity IDE" \
        "使用 Antigravity IDE 打开" \
        "在 Antigravity IDE 中打开选中的项" \
        "$AGY_SCRIPT" \
        "$TYPES_ALL"
    echo "   ✓ 检测到 Antigravity ($AGY_APP) → 已安装「使用 Antigravity IDE 打开」"
else
    echo "   - 未检测到 Antigravity IDE，已跳过"
fi

# 3. Visual Studio Code
if VSCODE_APP="$(detect_app "Visual Studio Code" "Visual Studio Code - Insiders")"; then
    VSCODE_SCRIPT="for f in \"\$@\"
do
    open -a \"$VSCODE_APP\" \"\$f\"
done"
    create_workflow \
        "Open with VS Code" \
        "使用 VS Code 打开" \
        "在 VS Code 中打开选中的项" \
        "$VSCODE_SCRIPT" \
        "$TYPES_ALL"
    echo "   ✓ 检测到 VS Code ($VSCODE_APP) → 已安装「使用 VS Code 打开」"
else
    echo "   - 未检测到 Visual Studio Code，已跳过"
fi

# 4. Claude Desktop
if CLAUDE_APP="$(detect_app "Claude")"; then
    CLAUDE_SEND_SCRIPT='q=""; for f in "${@:1:32}"; do k=file; [ -d "$f" ] &amp;&amp; k=folder; q="$q&amp;$k=$(V="$f" osascript -l JavaScript -e '\''ObjC.import("stdlib"); function run(){return encodeURIComponent($.getenv("V"))}'\'')"; done; open "claude://cowork/new?source=services$q"'
    create_workflow \
        "Claude - send" \
        "发送到 Claude" \
        "将选中的文件或文件夹发送到 Claude" \
        "$CLAUDE_SEND_SCRIPT" \
        "$TYPES_ALL"

    CLAUDE_CODE_SCRIPT='u=$(V="$1" osascript -l JavaScript -e '\''ObjC.import("stdlib"); function run(){return encodeURIComponent($.getenv("V"))}'\''); open "claude://code/new?folder=$u&amp;source=services"'
    create_workflow \
        "Claude - codeHere" \
        "在此新建 Claude Code 会话" \
        "在选中文件夹中新建 Claude Code 会话" \
        "$CLAUDE_CODE_SCRIPT" \
        "$TYPES_FOLDER" \
        "$FINDER_CONTEXT"

    echo "   ✓ 检测到 Claude ($CLAUDE_APP) → 已安装「发送到 Claude」「在此新建 Claude Code 会话」"
else
    echo "   - 未检测到 Claude，已跳过"
fi

# 5. Cursor / Windsurf / Zed / Trae / Codex
for app_spec in \
    "Cursor|Open with Cursor|使用 Cursor 打开" \
    "Windsurf|Open with Windsurf|使用 Windsurf 打开" \
    "Zed|Open with Zed|使用 Zed 打开" \
    "Trae|Open with Trae|使用 Trae 打开" \
    "Codex|Open with Codex|使用 Codex 打开"; do
    app_name="${app_spec%%|*}"
    rest="${app_spec#*|}"
    wf_name="${rest%%|*}"
    menu_title="${rest#*|}"
    if FOUND_APP="$(detect_app "$app_name")"; then
        APP_SCRIPT="for f in \"\$@\"
do
    open -a \"$FOUND_APP\" \"\$f\"
done"
        create_workflow \
            "$wf_name" \
            "$menu_title" \
            "在 ${app_name} 中打开选中的项" \
            "$APP_SCRIPT" \
            "$TYPES_ALL"
        echo "   ✓ 检测到 ${app_name} ($FOUND_APP) → 已安装「${menu_title}」"
    else
        echo "   - 未检测到 ${app_name}，已跳过"
    fi
done

/System/Library/CoreServices/pbs -flush 2>/dev/null || true
/System/Library/CoreServices/pbs -update 2>/dev/null || true
killall Finder 2>/dev/null || true
