package main

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"github.com/tdewolff/minify/v2"
	"github.com/tdewolff/minify/v2/html"
	"strings"
	"testing"
)

var minifier *minify.M

func minifyHTML(htmlString string) string {
	// Initialize minifier if necessary
	if minifier == nil {
		minifier = minify.New()
		minifier.Add("text/html", &html.Minifier{KeepEndTags: true, KeepQuotes: true})
	}

	minified, err := minifier.String("text/html", htmlString)
	if err != nil {
		panic(fmt.Sprintf("Could not minify HTML: %d", err))
	}
	return minified
}

func TestConvertCodeToHTML(t *testing.T) {
	source := `const print = (text) => console.log(text);
print("Hello world");`
	actual := convertToGoString(convertCodeToHTML(convertToCString(source), convertToCString("js")))
	actualTrimmed := strings.TrimSpace(actual)
	assert.True(t, strings.HasPrefix(actualTrimmed, `<pre class="chroma">`))
	assert.True(t, strings.HasSuffix(actualTrimmed, `</pre>`))
}

func TestConvertMarkdownToHTML(t *testing.T) {
	source := `# Heading

Text`
	expected := "<h1>Heading</h1><p>Text</p>"
	actual := convertToGoString(convertMarkdownToHTML(convertToCString(source)))
	assert.Equal(t, expected, minifyHTML(actual))
}

func TestConvertNotebookToHTML(t *testing.T) {
	source := `{"cells":[{"cell_type":"code","execution_count":1,"metadata":{},"outputs":[{"name":"stdout","output_type":"stream","text":["Hello world\n"]}],"source":["print(\"Hello world\")"]}],"metadata":{"kernelspec":{"display_name":"Python 3","language":"python","name":"python3"},"language_info":{"codemirror_mode":{"name":"ipython","version":3},"file_extension":".py","mimetype":"text/x-python","name":"python","nbconvert_exporter":"python","pygments_lexer":"ipython3","version":"3.8.2"}},"nbformat":4,"nbformat_minor":4}`
	actual := convertToGoString(convertNotebookToHTML(convertToCString(source)))
	actualTrimmed := strings.TrimSpace(actual)
	assert.True(t, strings.HasPrefix(actualTrimmed, `<div class="notebook">`))
	assert.True(t, strings.HasSuffix(actualTrimmed, `</div>`))
}

func TestConvertNotebookToHTMLInvalid(t *testing.T) {
	source := "This is not a valid JSON file."
	actual := convertToGoString(convertNotebookToHTML(convertToCString(source)))
	assert.True(t, strings.HasPrefix(actual, "error: "))
}
