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

echo "✅ 已安装基础路径复制服务："
echo "   • 复制所在目录路径"
echo "   • 复制完整路径（含文件名）"
echo ""
echo "🔍 正在检测本机已安装的 IDE / AI 应用..."

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

# 5. Codex
if CODEX_APP="$(detect_app "Codex")"; then
    CODEX_SCRIPT="for f in \"\$@\"
do
    open -a \"$CODEX_APP\" \"\$f\"
done"
    create_workflow \
        "Open with Codex" \
        "使用 Codex 打开" \
        "在 Codex 中打开选中的项" \
        "$CODEX_SCRIPT" \
        "$TYPES_ALL"
    echo "   ✓ 检测到 Codex ($CODEX_APP) → 已安装「使用 Codex 打开」"
else
    echo "   - 未检测到 Codex，已跳过"
fi

/System/Library/CoreServices/pbs -flush 2>/dev/null || true
/System/Library/CoreServices/pbs -update 2>/dev/null || true
killall Finder 2>/dev/null || true
