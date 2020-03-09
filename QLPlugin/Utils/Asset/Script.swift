import Foundation

class Script: Asset {
	private var content: String?
	private var url: URL?

	required init(content: String) {
		self.content = content
	}

	required init(url: URL) {
		self.url = url
	}

	func getHtml() -> String {
		if let url = url {
			return "<script src=\"\(url.path)\"></script>"
		} else {
			return "<script>\(content ?? "")</script>"
		}
	}
}
