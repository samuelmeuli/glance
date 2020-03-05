import Foundation
import JavaScriptCore
import os.log

class CodeRenderer: Renderer {
	override func getCss() -> String {
		var css = super.getCss()

		if let url = Bundle.main.url(forResource: "prism.min", withExtension: "css") {
			css += try! "\n\n\(String(contentsOf: url))"
		} else {
			os_log("Could not find PrismJS stylesheet", type: .error)
		}

		// TODO: Handle light and dark mode

		return css
	}

	override func getHtml() throws -> String {
		// TODO: Encode file content that's returned from `guard` statements

		guard let context = JSContext() else {
			os_log("Could not create JSContext for executing PrismJS library", type: .error)
			return fileContent
		}

		// Load PrismJS library
		guard let url = Bundle.main.url(forResource: "prism.min", withExtension: "js") else {
			os_log("Could not find PrismJS script", type: .error)
			return fileContent
		}
		context.evaluateScript(try String(contentsOf: url))

		// Apply syntax highlighting with PrismJS
		guard let prismObj = context.objectForKeyedSubscript("Prism") else {
			os_log("Could not find `Prism` object in JSContext", type: .error)
			return fileContent
		}
		guard let languagesObj = prismObj.objectForKeyedSubscript("languages") else {
			os_log("Could not find `Prism.languages` object", type: .error)
			return fileContent
		}
		guard let grammarObj = languagesObj.objectForKeyedSubscript(fileExtension) else {
			os_log("Could not find `Prism.languages.%s` object", type: .error, fileExtension)
			return fileContent
		}
		guard let highlightedHtml = prismObj.invokeMethod(
			"highlight",
			withArguments: [fileContent, grammarObj, fileExtension]
		) else {
			os_log("Missing return value from `Prism.highlight` function call", type: .error)
			return fileContent
		}
		guard let highlightedHtmlString = highlightedHtml.toString() else {
			os_log(
				"Cannot convert result of `Prism.highlight` function call to string",
				type: .error
			)
			return fileContent
		}

		// Return generated HTML (with syntax highlighting)
		return "<pre><code>\(highlightedHtmlString)</code></pre>"
	}
}
