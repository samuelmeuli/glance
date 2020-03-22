function render(fileContent) {
	// Create HTML table
	const previewDiv = document.getElementById("csv-preview");
	const tableElement = document.createElement("table");
	previewDiv.append(tableElement);

	function appendRows(rows) {
		if (!tableElement.innerHTML) {
			const header = rows.shift();
			tableElement.insertAdjacentHTML(
				"beforeend",
				`<tr>${header.map(column => `<th>${column}</th>`).join("\n")}</tr>`,
			);
		}
		const rowElements = rows
			.map(row => `<tr>${row.map(column => `<td>${column}</td>`).join("\n")}</tr>`)
			.join("\n");
		tableElement.insertAdjacentHTML("beforeend", rowElements);
	}

	// Parse CSV
	Papa.parse(fileContent.trim(), {
		worker: true,
		chunk: results => appendRows(results.data),
	});
}
