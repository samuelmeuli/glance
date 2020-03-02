import Cocoa
import Quartz
import WebKit

class PreviewViewController: NSViewController, QLPreviewingController, WKNavigationDelegate {
	var webView: WKWebView!

	override func loadView() {
		// Do not call `super.loadView()` (related to storybooks)

		// Create NSView (overrides inherited storybook logic)
		view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
	}

	// swiftlint:disable:next overridden_super_call
	override func viewDidLoad() {
		// Do not call `super.viewDidLoad()` (related to storybooks)

		// Create web view for rendering file preview
		webView = WKWebView(frame: view.bounds)
		webView.autoresizingMask = [.height, .width]
		view.addSubview(webView)
	}

	/// Spotlight preview handler
	func preparePreviewOfSearchableItem(
		identifier _: String,
		queryString _: String?,
		completionHandler handler: @escaping (Error?) -> Void
	) {
		previewFile(completionHandler: handler)
	}

	/// File preview handler (e.g. preview in the Finder or when pressing space on a file)
	func preparePreviewOfFile(at _: URL, completionHandler handler: @escaping (Error?) -> Void) {
		previewFile(completionHandler: handler)
	}

	private func previewFile(completionHandler handler: @escaping (Error?) -> Void) {
		if let url = Bundle.main.url(forResource: "content", withExtension: "html") {
			webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
		} else {
			// TODO: Display error message if HTML cannot be loaded
			print("Error loading preview HTML")
		}

		// Stop displaying Quick Look loading spinner
		handler(nil)
	}
}
