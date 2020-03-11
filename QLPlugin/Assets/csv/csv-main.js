function render(fileContent) {
	// Create HTML table
	const previewDiv = document.getElementById("csv-preview");
	const tableElement = document.createElement("table");
	previewDiv.append(tableElement);

	function appendRows(rows) {
		const rowElements = rows
			.map(row => `<tr>${row.map(column => `<td>${column}</td>`).join("\n")}</tr>`)
			.join("\n");
		tableElement.innerHTML = rowElements;
	}

	// Parse CSV
	Papa.parse(fileContent, {
		worker: true,
		chunk: results => appendRows(results.data),
	});
}
