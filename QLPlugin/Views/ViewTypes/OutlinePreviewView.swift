import Cocoa

/// Implementation of a `NSOutlineView` for file hiearchies
class OutlinePreviewView: NSView, LoadableNib {
	// swiftlint:disable:next private_outlet
	@IBOutlet internal var contentView: NSView!
	@IBOutlet private var label: NSTextField!
	@IBOutlet private var outlineView: NSOutlineView!
	@objc dynamic var fileTreeNodes: [FileTreeNode]
	private let treeController = NSTreeController()

	required init(frame: CGRect, fileTree: FileTree) {
		fileTreeNodes = Array(fileTree.root.children.values)
		super.init(frame: frame)
		loadViewFromNib(nibName: "OutlinePreviewView")
		setUpView()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
	}

	/// Expands all first-level tree nodes.
	func expandFirstLevel() {
		let proxyRoot = treeController.arrangedObjects
		for node in proxyRoot.children ?? [] {
			outlineView.expandItem(node)
		}
	}
}

extension OutlinePreviewView: NSOutlineViewDelegate {
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
