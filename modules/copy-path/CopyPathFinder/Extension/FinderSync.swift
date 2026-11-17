import Cocoa
import FinderSync
import os

private let logger = Logger(subsystem: "com.amasun.CopyPathFinder.Extension", category: "FinderSync")

@objc(FinderSyncExtension)
final class FinderSyncExtension: FIFinderSync {
    private struct AppTarget {
        let menuTitle: String
        let bundleIDs: [String]
        let fallbackPaths: [String]
        let symbolName: String
    }

    private let terminalTargets: [AppTarget] = [
        AppTarget(menuTitle: "在 Ghostty 中打开", bundleIDs: ["com.mitchellh.ghostty"], fallbackPaths: ["/Applications/Ghostty.app"], symbolName: "terminal"),
        AppTarget(menuTitle: "在 Warp 中打开", bundleIDs: ["dev.warp.Warp-Stable"], fallbackPaths: ["/Applications/Warp.app"], symbolName: "terminal"),
        AppTarget(menuTitle: "在 iTerm2 中打开", bundleIDs: ["com.googlecode.iterm2"], fallbackPaths: ["/Applications/iTerm.app"], symbolName: "terminal"),
        AppTarget(menuTitle: "在终端（Terminal）中打开", bundleIDs: ["com.apple.Terminal"], fallbackPaths: ["/System/Applications/Utilities/Terminal.app"], symbolName: "terminal")
    ]

    private let ideTargets: [AppTarget] = [
        AppTarget(menuTitle: "使用 Antigravity IDE 打开", bundleIDs: ["com.google.antigravity-ide", "com.google.antigravity"], fallbackPaths: ["/Applications/Antigravity IDE.app", "/Applications/Antigravity.app"], symbolName: "sparkles"),
        AppTarget(menuTitle: "使用 VS Code 打开", bundleIDs: ["com.microsoft.VSCode", "com.microsoft.VSCodeInsiders"], fallbackPaths: ["/Applications/Visual Studio Code.app", "/Applications/Visual Studio Code - Insiders.app"], symbolName: "curlybraces"),
        AppTarget(menuTitle: "使用 Cursor 打开", bundleIDs: ["com.todesktop.230313mzl4w4u92"], fallbackPaths: ["/Applications/Cursor.app"], symbolName: "cursorarrow.rays"),
        AppTarget(menuTitle: "使用 Windsurf 打开", bundleIDs: ["com.exafunction.windsurf"], fallbackPaths: ["/Applications/Windsurf.app"], symbolName: "wind"),
        AppTarget(menuTitle: "使用 Zed 打开", bundleIDs: ["dev.zed.Zed"], fallbackPaths: ["/Applications/Zed.app"], symbolName: "chevron.left.forwardslash.chevron.right"),
        AppTarget(menuTitle: "使用 Trae 打开", bundleIDs: ["com.trae.app"], fallbackPaths: ["/Applications/Trae.app"], symbolName: "wand.and.stars"),
        AppTarget(menuTitle: "使用 Codex 打开", bundleIDs: ["com.openai.codex"], fallbackPaths: ["/Applications/Codex.app"], symbolName: "cpu")
    ]

    private let claudeTarget = AppTarget(
        menuTitle: "Claude",
        bundleIDs: ["com.anthropic.claudefordesktop"],
        fallbackPaths: ["/Applications/Claude.app"],
        symbolName: "paperplane"
    )

    private let ignoredDirectoryNames: Set<String> = [
        ".git", "node_modules", "dist", "build", ".next", ".nuxt",
        "__pycache__", ".venv", "venv", "Pods", "DerivedData", ".DS_Store", ".Trash"
    ]

    override init() {
        super.init()
        updateMonitoredDirectories()

        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(self, selector: #selector(volumesChanged(_:)), name: NSWorkspace.didMountNotification, object: nil)
        center.addObserver(self, selector: #selector(volumesChanged(_:)), name: NSWorkspace.didUnmountNotification, object: nil)
        logger.notice("FinderSyncExtension initialized")
    }

    @objc private func volumesChanged(_ notification: Notification) {
        updateMonitoredDirectories()
    }

    private func updateMonitoredDirectories() {
        var urls: Set<URL> = [URL(fileURLWithPath: "/")]
        if let volumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: []) {
            for volume in volumes {
                urls.insert(volume)
            }
        }
        FIFinderSyncController.default().directoryURLs = urls
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        switch menuKind {
        case .contextualMenuForItems, .contextualMenuForContainer, .toolbarItemMenu:
            break
        default:
            return nil
        }

        let menu = NSMenu(title: "")
        let selected = FIFinderSyncController.default().selectedItemURLs() ?? []
        let target = FIFinderSyncController.default().targetedURL()
        let activeURLs = !selected.isEmpty ? selected : (target.map { [$0] } ?? [])

        // 1. 高频路径复制（一级菜单直接显示）
        if !selected.isEmpty {
            let copyDirItem = NSMenuItem(title: "复制所在目录路径", action: #selector(copyDirectoryPath(_:)), keyEquivalent: "")
            copyDirItem.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
            menu.addItem(copyDirItem)

            let copyFullItem = NSMenuItem(title: "复制完整路径（含文件名）", action: #selector(copyFullPath(_:)), keyEquivalent: "")
            copyFullItem.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
            menu.addItem(copyFullItem)
        } else if target != nil {
            let copyCurrentDirItem = NSMenuItem(title: "复制当前文件夹路径", action: #selector(copyDirectoryPath(_:)), keyEquivalent: "")
            copyCurrentDirItem.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
            menu.addItem(copyCurrentDirItem)
        }

        guard !activeURLs.isEmpty else {
            return menu.items.isEmpty ? nil : menu
        }

        menu.addItem(NSMenuItem.separator())

        // 2. AI 上下文子菜单
        let aiContextSubmenu = NSMenu(title: "AI 上下文")

        let treeItem = NSMenuItem(title: "复制目录树（Tree）", action: #selector(copyDirectoryTree(_:)), keyEquivalent: "")
        treeItem.image = NSImage(systemSymbolName: "list.bullet.indent", accessibilityDescription: nil)
        aiContextSubmenu.addItem(treeItem)

        let markdownItem = NSMenuItem(title: "复制为 AI 上下文（Markdown）", action: #selector(copyMarkdownContext(_:)), keyEquivalent: "")
        markdownItem.image = NSImage(systemSymbolName: "doc.richtext", accessibilityDescription: nil)
        aiContextSubmenu.addItem(markdownItem)

        let relPathItem = NSMenuItem(title: "复制 Git 相对路径", action: #selector(copyGitRelativePath(_:)), keyEquivalent: "")
        relPathItem.image = NSImage(systemSymbolName: "arrow.triangle.branch", accessibilityDescription: nil)
        aiContextSubmenu.addItem(relPathItem)

        let aiContextMenuItem = NSMenuItem(title: "AI 上下文", action: nil, keyEquivalent: "")
        aiContextMenuItem.image = NSImage(systemSymbolName: "brain.head.profile", accessibilityDescription: nil)
        aiContextMenuItem.submenu = aiContextSubmenu
        menu.addItem(aiContextMenuItem)

        // 3. 在开发工具中打开子菜单（自动检测本机已安装应用）
        let openWithSubmenu = NSMenu(title: "在开发工具中打开")

        for (index, term) in terminalTargets.enumerated() {
            if findApplicationURL(for: term) != nil {
                let item = NSMenuItem(title: term.menuTitle, action: #selector(openInDetectedTerminal(_:)), keyEquivalent: "")
                item.tag = index
                item.image = NSImage(systemSymbolName: term.symbolName, accessibilityDescription: nil)
                openWithSubmenu.addItem(item)
            }
        }

        if openWithSubmenu.items.count > 0 {
            openWithSubmenu.addItem(NSMenuItem.separator())
        }

        for (index, ide) in ideTargets.enumerated() {
            if findApplicationURL(for: ide) != nil {
                let item = NSMenuItem(title: ide.menuTitle, action: #selector(openInDetectedIDE(_:)), keyEquivalent: "")
                item.tag = index
                item.image = NSImage(systemSymbolName: ide.symbolName, accessibilityDescription: nil)
                openWithSubmenu.addItem(item)
            }
        }

        if findApplicationURL(for: claudeTarget) != nil {
            openWithSubmenu.addItem(NSMenuItem.separator())

            let sendItem = NSMenuItem(title: "发送到 Claude", action: #selector(sendToClaude(_:)), keyEquivalent: "")
            sendItem.image = NSImage(systemSymbolName: "paperplane", accessibilityDescription: nil)
            openWithSubmenu.addItem(sendItem)

            if let first = activeURLs.first, isRegularDirectory(first) {
                let codeItem = NSMenuItem(title: "在此新建 Claude Code 会话", action: #selector(openClaudeCodeHere(_:)), keyEquivalent: "")
                codeItem.image = NSImage(systemSymbolName: "bubble.left.and.text.bubble.right", accessibilityDescription: nil)
                openWithSubmenu.addItem(codeItem)
            }
        }

        if !openWithSubmenu.items.isEmpty {
            let openWithMenuItem = NSMenuItem(title: "在开发工具中打开", action: nil, keyEquivalent: "")
            openWithMenuItem.image = NSImage(systemSymbolName: "hammer", accessibilityDescription: nil)
            openWithMenuItem.submenu = openWithSubmenu
            menu.addItem(openWithMenuItem)
        }

        return menu.items.isEmpty ? nil : menu
    }

    // MARK: - Copy Path Actions

    @objc private func copyDirectoryPath(_ sender: AnyObject?) {
        let controller = FIFinderSyncController.default()
        let selected = controller.selectedItemURLs() ?? []

        let paths: [String]
        if !selected.isEmpty {
            var seen = Set<String>()
            var ordered: [String] = []
            for url in selected {
                let dirPath = directoryPath(for: url)
                if seen.insert(dirPath).inserted {
                    ordered.append(dirPath)
                }
            }
            paths = ordered
        } else if let target = controller.targetedURL() {
            paths = [normalizedPath(target)]
        } else {
            return
        }

        copyToPasteboard(paths.joined(separator: "\n"))
    }

    @objc private func copyFullPath(_ sender: AnyObject?) {
        let urls = activeTargetURLs()
        guard !urls.isEmpty else { return }
        copyToPasteboard(urls.map { normalizedPath($0) }.joined(separator: "\n"))
    }

    @objc private func copyGitRelativePath(_ sender: AnyObject?) {
        let urls = activeTargetURLs()
        guard !urls.isEmpty else { return }
        let paths = urls.map { relativeToGitRootOrName(for: $0) }
        copyToPasteboard(paths.joined(separator: "\n"))
    }

    // MARK: - AI Context Actions

    @objc private func copyDirectoryTree(_ sender: AnyObject?) {
        let urls = activeTargetURLs()
        guard let first = urls.first else { return }

        let rootURL = isRegularDirectory(first) ? first : first.deletingLastPathComponent()
        var lines: [String] = ["\(rootURL.lastPathComponent)/"]
        var count = 0
        let maxEntries = 300
        let maxDepth = 4

        buildTree(at: rootURL, prefix: "", depth: 0, maxDepth: maxDepth, maxEntries: maxEntries, count: &count, lines: &lines)
        if count >= maxEntries {
            lines.append("... (已达到 \(maxEntries) 项上限，部分内容已省略)")
        }

        copyToPasteboard(lines.joined(separator: "\n"))
    }

    @objc private func copyMarkdownContext(_ sender: AnyObject?) {
        let urls = activeTargetURLs()
        guard !urls.isEmpty else { return }

        var collectedFiles: [URL] = []
        for url in urls {
            if isRegularDirectory(url) {
                collectTextFiles(in: url, depth: 0, maxDepth: 3, maxFiles: 30, into: &collectedFiles)
            } else {
                collectedFiles.append(url)
            }
            if collectedFiles.count >= 30 {
                break
            }
        }

        var blocks: [String] = []
        var totalBytes = 0
        let maxSingleFileBytes = 150 * 1024
        let maxTotalBytes = 512 * 1024

        for fileURL in collectedFiles {
            guard let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                  let fileSize = attrs[.size] as? Int,
                  fileSize <= maxSingleFileBytes,
                  totalBytes + fileSize <= maxTotalBytes,
                  let data = try? Data(contentsOf: fileURL),
                  !data.contains(0),
                  let content = String(data: data, encoding: .utf8) else {
                continue
            }

            totalBytes += fileSize
            let displayPath = relativeToGitRootOrName(for: fileURL)
            let lang = fileURL.pathExtension.lowercased()
            blocks.append("### \(displayPath)\n```\(lang)\n\(content)\n```")
        }

        guard !blocks.isEmpty else {
            copyToPasteboard("⚠️ 未找到可读取的文本/代码文件（已跳过二进制或超大文件）")
            return
        }

        copyToPasteboard(blocks.joined(separator: "\n\n"))
    }

    // MARK: - Open With App Actions

    @objc private func openInDetectedTerminal(_ sender: NSMenuItem) {
        let index = sender.tag
        guard terminalTargets.indices.contains(index) else { return }
        let target = terminalTargets[index]
        let urls = activeTargetURLs()
        guard let first = urls.first, let appURL = findApplicationURL(for: target) else { return }

        let dirURL = isRegularDirectory(first) ? first : first.deletingLastPathComponent()
        openURLs([dirURL], withApplicationAt: appURL, name: target.menuTitle)
    }

    @objc private func openInDetectedIDE(_ sender: NSMenuItem) {
        let index = sender.tag
        guard ideTargets.indices.contains(index) else { return }
        let target = ideTargets[index]
        let urls = activeTargetURLs()
        guard !urls.isEmpty, let appURL = findApplicationURL(for: target) else { return }
        openURLs(urls, withApplicationAt: appURL, name: target.menuTitle)
    }

    @objc private func sendToClaude(_ sender: AnyObject?) {
        let urls = activeTargetURLs()
        guard !urls.isEmpty else { return }

        var queryParts: [String] = []
        for url in urls.prefix(32) {
            let key = isRegularDirectory(url) ? "folder" : "file"
            let path = normalizedPath(url)
            if let encoded = encodeQueryValue(path) {
                queryParts.append("\(key)=\(encoded)")
            }
        }
        guard !queryParts.isEmpty,
              let deepLink = URL(string: "claude://cowork/new?source=services&\(queryParts.joined(separator: "&"))") else {
            return
        }
        NSWorkspace.shared.open(deepLink)
    }

    @objc private func openClaudeCodeHere(_ sender: AnyObject?) {
        guard let first = activeTargetURLs().first else { return }
        let folderPath = directoryPath(for: first)
        guard let encoded = encodeQueryValue(folderPath),
              let deepLink = URL(string: "claude://code/new?folder=\(encoded)&source=services") else {
            return
        }
        NSWorkspace.shared.open(deepLink)
    }

    // MARK: - Helpers

    private func buildTree(
        at url: URL,
        prefix: String,
        depth: Int,
        maxDepth: Int,
        maxEntries: Int,
        count: inout Int,
        lines: inout [String]
    ) {
        guard depth < maxDepth, count < maxEntries else { return }

        let keys: [URLResourceKey] = [.isDirectoryKey, .isPackageKey]
        guard let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles]) else {
            return
        }

        let filtered = contents
            .filter { !ignoredDirectoryNames.contains($0.lastPathComponent) }
            .sorted { lhs, rhs in
                let lDir = isRegularDirectory(lhs)
                let rDir = isRegularDirectory(rhs)
                if lDir != rDir { return lDir }
                return lhs.lastPathComponent.localizedStandardCompare(rhs.lastPathComponent) == .orderedAscending
            }

        for (idx, item) in filtered.enumerated() {
            if count >= maxEntries { break }
            count += 1
            let isLast = idx == filtered.count - 1
            let connector = isLast ? "└── " : "├── "
            let isDir = isRegularDirectory(item)
            lines.append("\(prefix)\(connector)\(item.lastPathComponent)\(isDir ? "/" : "")")

            if isDir {
                let childPrefix = prefix + (isLast ? "    " : "│   ")
                buildTree(at: item, prefix: childPrefix, depth: depth + 1, maxDepth: maxDepth, maxEntries: maxEntries, count: &count, lines: &lines)
            }
        }
    }

    private func collectTextFiles(in dirURL: URL, depth: Int, maxDepth: Int, maxFiles: Int, into results: inout [URL]) {
        guard depth < maxDepth, results.count < maxFiles else { return }
        guard let contents = try? FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey], options: [.skipsHiddenFiles]) else {
            return
        }

        let sorted = contents
            .filter { !ignoredDirectoryNames.contains($0.lastPathComponent) }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }

        for item in sorted {
            if results.count >= maxFiles { break }
            if isRegularDirectory(item) {
                collectTextFiles(in: item, depth: depth + 1, maxDepth: maxDepth, maxFiles: maxFiles, into: &results)
            } else {
                results.append(item)
            }
        }
    }

    private func relativeToGitRootOrName(for url: URL) -> String {
        let targetPath = normalizedPath(url)
        var cursor = isRegularDirectory(url) ? url : url.deletingLastPathComponent()

        while cursor.path != "/" {
            let gitDir = cursor.appendingPathComponent(".git")
            if FileManager.default.fileExists(atPath: gitDir.path) {
                let rootPath = normalizedPath(cursor)
                if targetPath == rootPath {
                    return url.lastPathComponent
                }
                let prefix = rootPath.hasSuffix("/") ? rootPath : rootPath + "/"
                if targetPath.hasPrefix(prefix) {
                    return String(targetPath.dropFirst(prefix.count))
                }
            }
            let parent = cursor.deletingLastPathComponent()
            if parent.path == cursor.path { break }
            cursor = parent
        }
        return url.lastPathComponent
    }

    private func activeTargetURLs() -> [URL] {
        let controller = FIFinderSyncController.default()
        let selected = controller.selectedItemURLs() ?? []
        if !selected.isEmpty {
            return selected
        }
        if let target = controller.targetedURL() {
            return [target]
        }
        return []
    }

    private func findApplicationURL(for target: AppTarget) -> URL? {
        for bundleID in target.bundleIDs {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                return url
            }
        }
        for path in target.fallbackPaths {
            if FileManager.default.fileExists(atPath: path) {
                return URL(fileURLWithPath: path)
            }
        }
        return nil
    }

    private func openURLs(_ urls: [URL], withApplicationAt appURL: URL, name: String) {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.open(urls, withApplicationAt: appURL, configuration: config) { _, error in
            if let error {
                logger.error("Failed to open \(name, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func isRegularDirectory(_ url: URL) -> Bool {
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .isPackageKey]
        let values = try? url.resourceValues(forKeys: keys)
        let isDirectory = values?.isDirectory ?? url.hasDirectoryPath
        let isPackage = values?.isPackage ?? false
        return isDirectory && !isPackage
    }

    private func directoryPath(for url: URL) -> String {
        if isRegularDirectory(url) {
            return normalizedPath(url)
        }
        return normalizedPath(url.deletingLastPathComponent())
    }

    private func normalizedPath(_ url: URL) -> String {
        let path = url.path
        if path.count > 1 && path.hasSuffix("/") {
            return String(path.dropLast())
        }
        return path
    }

    private func encodeQueryValue(_ value: String) -> String? {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+/?#")
        return value.addingPercentEncoding(withAllowedCharacters: allowed)
    }

    private func copyToPasteboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
