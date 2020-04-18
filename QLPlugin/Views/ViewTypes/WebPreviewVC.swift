import Cocoa
import Foundation
import os.log
import WebKit

class WebPreviewVC: NSViewController, PreviewVC {
	/// File to render
	let file: File

	/// Stylesheet with CSS that applies to all file types
	private let sharedCSSURL = Bundle.main.url(forResource: "shared-main", withExtension: "css")

	required convenience init(file: File) {
		self.init(nibName: nil, bundle: nil, file: file)
	}

	init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?, file: File) {
		self.file = file
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		// Required because the view controller is not initialized using a Storyboard
		view = NSView()
	}

	func getStylesheets() -> [Stylesheet] {
		var stylesheets: [Stylesheet] = []

		if let sharedCSSURL = sharedCSSURL {
			stylesheets.append(Stylesheet(url: sharedCSSURL))
		} else {
			os_log("Could not find shared stylesheet", type: .error)
		}

		return stylesheets
	}

	func getHTML() throws -> String { "" }

	func getScripts() throws -> [Script] { [] }

	private func renderPage(
		htmlBody: String = "",
		stylesheets: [Stylesheet] = [],
		scripts: [Script] = []
	) -> String {
		let linkTags = stylesheets
			.map { $0.getHTML() }
			.joined(separator: "\n")
		let scriptTags = scripts
			.map { $0.getHTML() }
			.joined(separator: "\n")

		return """
		<!DOCTYPE html>
		<html>
			<head>
				<meta charset="utf-8" />
				<meta
					name="viewport"
					content="width=device-width, initial-scale=1, shrink-to-fit=no"
				/>
				\(linkTags)
			</head>
			<body>
				\(htmlBody)
				\(scriptTags)
			</body>
		</html>
		"""
	}

	func loadPreview() throws {
		// Configure web view to disallow any user interaction
		let preferences = WKPreferences()
		preferences.javaScriptCanOpenWindowsAutomatically = false
		let configuration = WKWebViewConfiguration()
		configuration.preferences = preferences

		let webView = OfflineWebView(frame: view.frame, configuration: configuration)
		webView.autoresizingMask = [.height, .width]

		// Remove background to prevent white flicker on load in Dark Mode
		webView.setValue(false, forKey: "drawsBackground")

		// Load HTML/CSS/JS into web view
		let htmlString = renderPage(
			htmlBody: try getHTML(),
			stylesheets: getStylesheets(),
			scripts: try getScripts()
		)
		webView.loadHTMLString(htmlString, baseURL: Bundle.main.resourceURL)
		view.addSubview(webView)
	}
}
