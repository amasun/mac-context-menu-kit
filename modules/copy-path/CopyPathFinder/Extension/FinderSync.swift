import Cocoa
import FinderSync
import os

private let logger = Logger(subsystem: "com.amasun.CopyPathFinder.Extension", category: "FinderSync")

@objc(FinderSyncExtension)
final class FinderSyncExtension: FIFinderSync {
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
        let paths = urls.map(\.path).sorted().joined(separator: ", ")
        logger.notice("directoryURLs updated: \(paths, privacy: .public)")
    }

    override func beginObservingDirectory(at url: URL) {
        logger.notice("beginObservingDirectory: \(url.path, privacy: .public)")
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        logger.notice("menu(for:) called with kind=\(menuKind.rawValue)")
        switch menuKind {
        case .contextualMenuForItems, .contextualMenuForContainer, .toolbarItemMenu:
            break
        default:
            return nil
        }

        let menu = NSMenu(title: "")
        let selected = FIFinderSyncController.default().selectedItemURLs() ?? []

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
        } else if FIFinderSyncController.default().targetedURL() != nil {
            let copyCurrentDirItem = NSMenuItem(
                title: "复制当前文件夹路径",
                action: #selector(copyDirectoryPath(_:)),
                keyEquivalent: ""
            )
            copyCurrentDirItem.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
            menu.addItem(copyCurrentDirItem)
        }

        return menu.items.isEmpty ? nil : menu
    }

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

    private func directoryPath(for url: URL) -> String {
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .isPackageKey]
        let values = try? url.resourceValues(forKeys: keys)
        let isDirectory = values?.isDirectory ?? url.hasDirectoryPath
        let isPackage = values?.isPackage ?? false

        if isDirectory && !isPackage {
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

    private func copyToPasteboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
