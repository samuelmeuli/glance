import Cocoa
import os.log
import Quartz

/// Max size of files to render: 100000 B = 100 KB
let MAX_FILE_SIZE = 100_000

enum PreviewError: Error {
	case fileSizeError(path: String, fileSize: UInt64)
}

extension PreviewError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case let .fileSizeError(path, fileSize):
			return NSLocalizedString(
				"File \(path) is too large to preview (\(fileSize) > \(MAX_FILE_SIZE))",
				comment: ""
			)
		}
	}
}

class PreviewViewController: NSViewController, QLPreviewingController {
	var webView: PreviewWebView!

	override func loadView() {
		// Do not call `super.loadView()` (related to storybooks)

		// Create NSView (overrides inherited storybook logic)
		view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
	}

	// swiftlint:disable:next overridden_super_call
	override func viewDidLoad() {
		// Do not call `super.viewDidLoad()` (related to storybooks)

		// Create web view for rendering file preview (subview of NSView)
		webView = PreviewWebView(frame: view.bounds)
		webView.autoresizingMask = [.height, .width]
		view.addSubview(webView)
	}

	/// Handles file previews. Called e.g. for Quick Look and previews in Finder/Spotlight
	func preparePreviewOfFile(
		at fileUrl: URL,
		completionHandler handler: @escaping (Error?) -> Void
	) {
		// Render preview
		os_log("Generating Quick Look preview for file %s", type: .debug, fileUrl.path)
		previewFile(fileUrl: fileUrl, completionHandler: handler)
	}

	/// Loads an HTML preview of the selected file into the `webView`
	private func previewFile(fileUrl: URL, completionHandler handler: @escaping (Error?) -> Void) {
		// Retrieve information about previewed file
		var file: File
		do {
			file = try File(url: fileUrl)
		} catch {
			handler(error)
			return
		}

		// Initialize renderer object for the file type
		let renderer = RendererFactory.getRenderer(file: file)

		// Abort and display error to user if file is too large to preview
		if !file.isDirectory, file.size > MAX_FILE_SIZE {
			os_log("Not loading file preview for %s: File too large", type: .info, fileUrl.path)
			handler(PreviewError.fileSizeError(path: file.path, fileSize: file.size))
			return
		}

		// Render file preview
		do {
			webView.renderPage(
				htmlBody: try renderer.getHtml(),
				stylesheets: renderer.getStylesheets(),
				scripts: try renderer.getScripts()
			)
		} catch {
			handler(error)
			return
		}

		// Hide Quick Look loading spinner
		handler(nil)
	}
}
