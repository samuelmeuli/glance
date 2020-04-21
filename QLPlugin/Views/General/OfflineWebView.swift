import Cocoa
import os.log
import WebKit

// Block all URLs except those starting with "blob:" or "file://"
let blockRules = """
[
	{
		"trigger": {
			"url-filter": ".*"
		},
		"action": {
			"type": "block"
		}
	},
	{
		"trigger": {
			"url-filter": "blob:.*"
		},
		"action": {
			"type": "ignore-previous-rules"
		}
	},
	{
		"trigger": {
			"url-filter": "file://.*"
		},
		"action": {
			"type": "ignore-previous-rules"
		}
	}
]
"""

/// `WKWebView` which only allows the loading of local resources
class OfflineWebView: WKWebView {
	override init(frame: CGRect, configuration: WKWebViewConfiguration) {
		WKContentRuleListStore.default().compileContentRuleList(
			forIdentifier: "ContentBlockingRules",
			encodedContentRuleList: blockRules
		) { contentRuleList, error in
			if let error = error {
				os_log(
					"Error compiling WKWebView content rule list: %{public}s",
					log: Log.render,
					type: .error,
					error.localizedDescription
				)
			} else if let contentRuleList = contentRuleList {
				configuration.userContentController.add(contentRuleList)
			} else {
				os_log(
					"Error adding WKWebView content rule list: Content rule list is not defined",
					log: Log.render,
					type: .error
				)
			}
		}

		super.init(frame: frame, configuration: configuration)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
