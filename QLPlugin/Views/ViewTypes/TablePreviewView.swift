import Cocoa
import os.log

class TablePreviewView: NSView, LoadableNib {
	private let tableData: [[String: String]]

	// swiftlint:disable:next private_outlet
	@IBOutlet internal var contentView: NSView!

	@IBOutlet private var tableView: NSTableView!

	required init(frame: CGRect, tableData: [[String: String]]) {
		self.tableData = tableData

		super.init(frame: frame)

		loadViewFromNib(nibName: "TablePreviewView")
		setUpView()
		createColumns()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setUpView() {
		contentView.autoresizingMask = [.height, .width]
		tableView.delegate = self
		tableView.dataSource = self
	}

	private func createColumns() {
		guard let firstRow = tableData.first else {
			os_log("Skipping creation of table columns (no rows in `tableData`)")
			return
		}
		guard !firstRow.isEmpty else {
			os_log("Skipping creation of table columns (no columns in `tableData`)")
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

extension TablePreviewView: NSTableViewDataSource, NSTableViewDelegate {
	func numberOfRows(in _: NSTableView) -> Int {
		tableData.count
	}

	/// Fills the table with the `tableData`
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
