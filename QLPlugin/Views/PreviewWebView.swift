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

	func renderPage(contentHtml: String = "", css: String = "", js: String = "") {
		let pageHtml = """
			<!DOCTYPE html>
			<html>
				<head>
					<meta charset="utf-8" />
					<meta
						name="viewport"
						content="width=device-width, initial-scale=1, shrink-to-fit=no"
					/>
					<style>\(css)</style>
				</head>
				<body>
					<div id="content">\(contentHtml)</div>
					<script>\(js)</script>
				</body>
			</html>
		"""
		loadHTMLString(pageHtml, baseURL: Bundle.main.resourceURL)
	}
}
