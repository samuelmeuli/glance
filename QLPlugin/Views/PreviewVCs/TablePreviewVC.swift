import Cocoa
import os.log

class TablePreviewVC: NSViewController, PreviewVC {
	let headers: [String]
	let cells: [[String: String]]

	@IBOutlet private var tableView: NSTableView!

	required convenience init(headers: [String], cells: [[String: String]]) {
		self.init(nibName: nil, bundle: nil, headers: headers, cells: cells)
	}

	init(
		nibName nibNameOrNil: NSNib.Name?,
		bundle nibBundleOrNil: Bundle?,
		headers: [String],
		cells: [[String: String]]
	) {
		self.headers = headers
		self.cells = cells
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpView()
		deleteDefaultColumns()
		createColumns()
	}

	private func setUpView() {
		tableView.delegate = self
		tableView.dataSource = self
	}

	/// Deletes all columns created by default using Interface Builder.
	private func deleteDefaultColumns() {
		while !tableView.tableColumns.isEmpty {
			if let column = tableView.tableColumns.first {
				tableView.removeTableColumn(column)
			}
		}
	}

	/// Creates table columns for all headers.
	private func createColumns() {
		for header in headers {
			let columnID = NSUserInterfaceItemIdentifier(rawValue: header)
			let column = NSTableColumn(identifier: columnID)
			column.title = header
			tableView.addTableColumn(column)
		}
	}
}

extension TablePreviewVC: NSTableViewDataSource, NSTableViewDelegate {
	func numberOfRows(in _: NSTableView) -> Int {
		cells.count
	}

	/// Fills the table with the `tableData`.
	func tableView(
		_: NSTableView,
		viewFor tableColumn: NSTableColumn?,
		row rowIndex: Int
	) -> NSView? {
		let row = cells[rowIndex]
		let cellValue = row[tableColumn!.identifier.rawValue] ?? ""

		let textField = NSTextField()
		textField.stringValue = cellValue
		textField.isEditable = false
		textField.isBordered = false
		textField.drawsBackground = false

		return textField
	}
}
