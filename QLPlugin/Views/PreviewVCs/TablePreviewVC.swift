import Cocoa
import os.log

class TablePreviewVC: NSViewController, PreviewVC {
	let tableData: [[String: String]]

	@IBOutlet private var tableView: NSTableView!

	required convenience init(tableData: [[String: String]]) {
		self.init(nibName: nil, bundle: nil, tableData: tableData)
	}

	init(
		nibName nibNameOrNil: NSNib.Name?,
		bundle nibBundleOrNil: Bundle?,
		tableData: [[String: String]]
	) {
		self.tableData = tableData
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
		guard let firstRow = tableData.first else {
			os_log(
				"Skipping creation of table columns (no rows in `tableData`)",
				log: Log.render,
				type: .info
			)
			return
		}
		guard !firstRow.isEmpty else {
			os_log(
				"Skipping creation of table columns (no columns in `tableData`)",
				log: Log.render,
				type: .info
			)
			return
		}

		for columnName in firstRow.keys {
			let columnID = NSUserInterfaceItemIdentifier(rawValue: columnName)
			let column = NSTableColumn(identifier: columnID)
			column.title = columnName
			tableView.addTableColumn(column)
		}
	}
}

extension TablePreviewVC: NSTableViewDataSource, NSTableViewDelegate {
	func numberOfRows(in _: NSTableView) -> Int {
		tableData.count
	}

	/// Fills the table with the `tableData`.
	func tableView(
		_: NSTableView,
		viewFor tableColumn: NSTableColumn?,
		row rowIndex: Int
	) -> NSView? {
		let row = tableData[rowIndex]
		let cellValue = row[tableColumn!.identifier.rawValue] ?? ""

		let textField = NSTextField()
		textField.stringValue = cellValue
		textField.isEditable = false
		textField.isBordered = false
		textField.drawsBackground = false

		return textField
	}
}
