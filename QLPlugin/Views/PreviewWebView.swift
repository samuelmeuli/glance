import Foundation
import WebKit

class PreviewWebView: WKWebView {
	init(frame: CGRect) {
		// Web view configuration
		let preferences = WKPreferences()
		preferences.javaScriptCanOpenWindowsAutomatically = false
		let configuration = WKWebViewConfiguration()
		configuration.preferences = preferences

		super.init(frame: frame, configuration: configuration)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func renderPage(htmlBody: String = "", cssFiles: [URL] = [], jsFiles: [URL] = []) {
		let linkTags = cssFiles
			.map { "<link rel=\"stylesheet\" type=\"text/css\" href=\"\($0.path)\" />" }
			.joined(separator: "\n")
		let scriptTags = jsFiles
			.map { "<script src=\"\($0.path)\" />" }
			.joined(separator: "\n")

		let html = """
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
					<div id="content">\(htmlBody)</div>
					\(scriptTags)
				</body>
			</html>
		"""
		loadHTMLString(html, baseURL: Bundle.main.resourceURL)
	}
}
