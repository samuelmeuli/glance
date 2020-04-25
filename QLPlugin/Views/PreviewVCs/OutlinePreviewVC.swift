import Cocoa

class OutlinePreviewVC: NSViewController, PreviewVC {
	@objc dynamic let fileTreeNodes: [FileTreeNode]
	private let labelText: String?

	private let treeController = NSTreeController()

	@IBOutlet private var outlineView: NSOutlineView!
	@IBOutlet private var label: NSTextField!

	required convenience init(fileTreeNodes: [FileTreeNode], labelText: String?) {
		self.init(nibName: nil, bundle: nil, fileTreeNodes: fileTreeNodes, labelText: labelText)
	}

	init(
		nibName nibNameOrNil: NSNib.Name?,
		bundle nibBundleOrNil: Bundle?,
		fileTreeNodes: [FileTreeNode],
		labelText: String?
	) {
		self.fileTreeNodes = fileTreeNodes
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

	private func setUpView() {
		outlineView.delegate = self

		// See `FileTreeNode`'s computed properties
		treeController.objectClass = FileTreeNode.self
		treeController.childrenKeyPath = "childrenList"
		treeController.countKeyPath = "childrenCount"
		treeController.leafKeyPath = "hasChildren"

		treeController.bind(
			NSBindingName(rawValue: "contentArray"),
			to: self,
			withKeyPath: "fileTreeNodes",
			options: nil
		)
		outlineView.bind(
			NSBindingName(rawValue: "content"),
			to: treeController,
			withKeyPath: "arrangedObjects",
			options: nil
		)

		label.stringValue = labelText ?? ""
	}

	/// Expands all first-level tree nodes.
	func expandFirstLevel() {
		let proxyRoot = treeController.arrangedObjects
		for node in proxyRoot.children ?? [] {
			outlineView.expandItem(node)
		}
	}
}

extension OutlinePreviewVC: NSOutlineViewDelegate {
	public func outlineView(
		_ outlineView: NSOutlineView,
		viewFor tableColumn: NSTableColumn?,
		item _: Any
	) -> NSView? {
		var cellView: NSTableCellView?

		guard let columnID = tableColumn?.identifier else {
			return cellView
		}

		switch columnID {
			case .init("name"):
				if let view = outlineView.makeView(
					withIdentifier: columnID,
					owner: outlineView.delegate
				) as? NSTableCellView {
					view.textField?.bind(
						.value,
						to: view,
						withKeyPath: "objectValue.name",
						options: nil
					)
					cellView = view
				}
			case .init("size"):
				if let view = outlineView.makeView(
					withIdentifier: columnID,
					owner: outlineView.delegate
				) as? NSTableCellView {
					view.textField?.bind(
						.value,
						to: view,
						withKeyPath: "objectValue.size",
						options: nil
					)
					cellView = view
				}
			case .init("dateModified"):
				if let view = outlineView.makeView(
					withIdentifier: columnID,
					owner: outlineView.delegate
				) as? NSTableCellView {
					view.textField?.bind(
						.value,
						to: view,
						withKeyPath: "objectValue.dateModified",
						options: nil
					)
					cellView = view
				}
			default:
				return cellView
		}
		return cellView
	}
}
