import Cocoa

let APP_NAME = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	var window: NSWindow!

	override init() {
		super.init()
	}

	func applicationDidFinishLaunching(_: Notification) {
		createWindow()
	}

	func applicationWillTerminate(_: Notification) {}

	func createWindow() {
		window = NSWindow(
			contentRect: .init(
				origin: .zero,
				size: .init(width: NSScreen.main!.frame.midX, height: NSScreen.main!.frame.midY)
			),
			styleMask: [.closable, .miniaturizable, .titled],
			backing: .buffered,
			defer: false
		)
		window.center()
		window.title = APP_NAME
		window.makeKeyAndOrderFront(nil)
	}
}
