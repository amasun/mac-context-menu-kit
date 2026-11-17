import Cocoa
import FinderSync

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FIFinderSyncController.showExtensionManagementInterface()

        let alert = NSAlert()
        alert.messageText = "CopyPathFinder 访达扩展已就绪"
        alert.informativeText = """
        请在打开的「系统设置 → 扩展 → 访达」中勾选启用「复制路径（CopyPathFinder）」。

        启用后，在访达（Finder）中右键点击任意文件、文件夹或空白处，即可直接看到：
        • 复制所在目录路径
        • 复制完整路径（含文件名）
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "完成")
        alert.addButton(withTitle: "再次打开扩展设置")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            FIFinderSyncController.showExtensionManagementInterface()
        }
        NSApp.terminate(nil)
    }
}
