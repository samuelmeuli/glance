import Foundation
import WebKit

class PreviewWebView: OfflineWebView {
	init(frame: CGRect) {
		// Web view configuration
		let preferences = WKPreferences()
		preferences.javaScriptCanOpenWindowsAutomatically = false
		let configuration = WKWebViewConfiguration()
		configuration.preferences = preferences

		super.init(frame: frame, configuration: configuration)
	}

	func renderPage(htmlBody: String = "", stylesheets: [Stylesheet] = [], scripts: [Script] = []) {
		let linkTags = stylesheets
			.map { $0.getHtml() }
			.joined(separator: "\n")
		let scriptTags = scripts
			.map { $0.getHtml() }
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
				\(htmlBody)
				\(scriptTags)
			</body>
		</html>
		"""
		loadHTMLString(html, baseURL: Bundle.main.resourceURL)
	}
}
