import Foundation
import HTMLConverter

extension String {
	/// Converts the Swift string to a C string.
	func toCString() -> UnsafeMutablePointer<Int8> {
		UnsafeMutablePointer<Int8>(mutating: (self as NSString).utf8String!)
	}
}

enum HTMLRendererError {
	case rendererError(fileType: String, errorMessage: String)
}

extension HTMLRendererError: LocalizedError {
	public var errorDescription: String? {
		switch self {
			case let .rendererError(fileType, errorMessage):
				return NSLocalizedString(
					"Could not convert \(fileType) to HTML: \(errorMessage)",
					comment: ""
				)
		}
	}
}

class HTMLRenderer {
	/// Throws an error if the return value indicates one. Because all `HTMLConverter` return values
	/// are C strings, errors are implemented as return values starting with "error: ".
	static func throwIfErrored(fileType: String, returnValue: String) throws {
		if returnValue.hasPrefix("error :") {
			let startIndex = returnValue.index(returnValue.startIndex, offsetBy: 7)
			let errorMessage = returnValue[startIndex ..< returnValue.endIndex]
			throw HTMLRendererError.rendererError(
				fileType: fileType,
				errorMessage: String(errorMessage)
			)
		}
	}

	/// Converts a code string to HTML with support for syntax highlighting.
	static func renderCode(_ source: String, lexer: String) throws -> String {
		let htmlCString = convertCodeToHTML(source.toCString(), lexer.toCString())
		let htmlString = String(cString: htmlCString!)
		try throwIfErrored(fileType: "code", returnValue: htmlString)
		return htmlString
	}

	/// Converts a Markdown string to HTML.
	static func renderMarkdown(_ source: String) throws -> String {
		let htmlCString = convertMarkdownToHTML(source.toCString())
		let htmlString = String(cString: htmlCString!)
		try throwIfErrored(fileType: "Markdown", returnValue: htmlString)
		return htmlString
	}

	/// Converts a Jupyter Notebook JSON file to HTML.
	static func renderNotebook(_ source: String) throws -> String {
		let htmlCString = convertNotebookToHTML(source.toCString())
		let htmlString = String(cString: htmlCString!)
		try throwIfErrored(fileType: "Jupyter Notebook", returnValue: htmlString)
		return htmlString
	}
}
