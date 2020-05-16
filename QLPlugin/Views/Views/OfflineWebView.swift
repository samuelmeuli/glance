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
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)

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
				self.configuration.userContentController.add(contentRuleList)
			} else {
				os_log(
					"Error adding WKWebView content rule list: Content rule list is not defined",
					log: Log.render,
					type: .error
				)
			}
		}
	}
}
