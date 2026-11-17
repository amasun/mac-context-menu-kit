import Cocoa
import FinderSync
import os

private let logger = Logger(subsystem: "com.amasun.CopyPathFinder.Extension", category: "FinderSync")

@objc(FinderSyncExtension)
final class FinderSyncExtension: FIFinderSync {
    private struct AppTarget {
        let name: String
        let bundleIDs: [String]
        let fallbackPaths: [String]
    }

    private let antigravityTarget = AppTarget(
        name: "Antigravity IDE",
        bundleIDs: ["com.google.antigravity-ide", "com.google.antigravity"],
        fallbackPaths: ["/Applications/Antigravity IDE.app", "/Applications/Antigravity.app"]
    )
    private let vscodeTarget = AppTarget(
        name: "VS Code",
        bundleIDs: ["com.microsoft.VSCode", "com.microsoft.VSCodeInsiders"],
        fallbackPaths: ["/Applications/Visual Studio Code.app", "/Applications/Visual Studio Code - Insiders.app"]
    )
    private let claudeTarget = AppTarget(
        name: "Claude",
        bundleIDs: ["com.anthropic.claudefordesktop"],
        fallbackPaths: ["/Applications/Claude.app"]
    )
    private let codexTarget = AppTarget(
        name: "Codex",
        bundleIDs: ["com.openai.codex"],
        fallbackPaths: ["/Applications/Codex.app"]
    )

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

        if !selected.isEmpty {
            let copyDirItem = NSMenuItem(
                title: "复制所在目录路径",
                action: #selector(copyDirectoryPath(_:)),
                keyEquivalent: ""
            )
            copyDirItem.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
            menu.addItem(copyDirItem)

            let copyFullItem = NSMenuItem(
                title: "复制完整路径（含文件名）",
                action: #selector(copyFullPath(_:)),
                keyEquivalent: ""
            )
            copyFullItem.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
            menu.addItem(copyFullItem)
        } else if target != nil {
            let copyCurrentDirItem = NSMenuItem(
                title: "复制当前文件夹路径",
                action: #selector(copyDirectoryPath(_:)),
                keyEquivalent: ""
            )
            copyCurrentDirItem.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
            menu.addItem(copyCurrentDirItem)
        }

        if !activeURLs.isEmpty {
            var appItems: [NSMenuItem] = []

            if findApplicationURL(for: antigravityTarget) != nil {
                let item = NSMenuItem(
                    title: "使用 Antigravity IDE 打开",
                    action: #selector(openWithAntigravity(_:)),
                    keyEquivalent: ""
                )
                item.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: nil)
                appItems.append(item)
            }

            if findApplicationURL(for: vscodeTarget) != nil {
                let item = NSMenuItem(
                    title: "使用 VS Code 打开",
                    action: #selector(openWithVSCode(_:)),
                    keyEquivalent: ""
                )
                item.image = NSImage(systemSymbolName: "curlybraces", accessibilityDescription: nil)
                appItems.append(item)
            }

            if findApplicationURL(for: codexTarget) != nil {
                let item = NSMenuItem(
                    title: "使用 Codex 打开",
                    action: #selector(openWithCodex(_:)),
                    keyEquivalent: ""
                )
                item.image = NSImage(systemSymbolName: "terminal", accessibilityDescription: nil)
                appItems.append(item)
            }

            if findApplicationURL(for: claudeTarget) != nil {
                let sendItem = NSMenuItem(
                    title: "发送到 Claude",
                    action: #selector(sendToClaude(_:)),
                    keyEquivalent: ""
                )
                sendItem.image = NSImage(systemSymbolName: "paperplane", accessibilityDescription: nil)
                appItems.append(sendItem)

                if let first = activeURLs.first, isRegularDirectory(first) {
                    let codeItem = NSMenuItem(
                        title: "在此新建 Claude Code 会话",
                        action: #selector(openClaudeCodeHere(_:)),
                        keyEquivalent: ""
                    )
                    codeItem.image = NSImage(systemSymbolName: "bubble.left.and.text.bubble.right", accessibilityDescription: nil)
                    appItems.append(codeItem)
                }
            }

            if !appItems.isEmpty {
                menu.addItem(NSMenuItem.separator())
                for item in appItems {
                    menu.addItem(item)
                }
            }
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
        let controller = FIFinderSyncController.default()
        let selected = controller.selectedItemURLs() ?? []

        let paths: [String]
        if !selected.isEmpty {
            paths = selected.map { normalizedPath($0) }
        } else if let target = controller.targetedURL() {
            paths = [normalizedPath(target)]
        } else {
            return
        }

        copyToPasteboard(paths.joined(separator: "\n"))
    }

    // MARK: - Open With App Actions

    @objc private func openWithAntigravity(_ sender: AnyObject?) {
        openActiveItems(with: antigravityTarget)
    }

    @objc private func openWithVSCode(_ sender: AnyObject?) {
        openActiveItems(with: vscodeTarget)
    }

    @objc private func openWithCodex(_ sender: AnyObject?) {
        openActiveItems(with: codexTarget)
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

    private func openActiveItems(with target: AppTarget) {
        let urls = activeTargetURLs()
        guard !urls.isEmpty, let appURL = findApplicationURL(for: target) else {
            logger.error("Failed to locate app \(target.name, privacy: .public)")
            return
        }
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.open(urls, withApplicationAt: appURL, configuration: config) { _, error in
            if let error {
                logger.error("Failed to open with \(target.name, privacy: .public): \(error.localizedDescription, privacy: .public)")
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
