import Cocoa

class OutlinePreviewVC: NSViewController, PreviewVC {
	@objc dynamic var root: FileTreeNode
	private let labelText: String?

	@IBOutlet private var treeController: NSTreeController!
	@IBOutlet private var outlineView: NSOutlineView!
	@IBOutlet private var label: NSTextField!

	required convenience init(root: FileTreeNode, labelText: String?) {
		self.init(nibName: nil, bundle: nil, root: root, labelText: labelText)
	}

	init(
		nibName nibNameOrNil: NSNib.Name?,
		bundle nibBundleOrNil: Bundle?,
		root: FileTreeNode,
		labelText: String?
	) {
		self.root = root
		self.labelText = labelText
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpView()
		expandFirstLevel()
	}

	func setUpView() {
		// Add file tree to `treeController`
		treeController.addObject(root)

		// Add label
		label.stringValue = labelText ?? ""
	}

	/// Expands all first-level tree nodes.
	func expandFirstLevel() {
		let root = treeController.arrangedObjects
		for node in root.children ?? [] {
			outlineView.expandItem(node)
		}
	}
}
