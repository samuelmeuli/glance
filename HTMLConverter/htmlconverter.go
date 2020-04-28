package main

import (
	"C"
	"bytes"
	"fmt"
	"github.com/Depado/bfchroma"
	"github.com/alecthomas/chroma"
	htmlFormatter "github.com/alecthomas/chroma/formatters/html"
	"github.com/alecthomas/chroma/lexers"
	"github.com/alecthomas/chroma/styles"
	"github.com/microcosm-cc/bluemonday"
	"github.com/samuelmeuli/nbtohtml"
	"gopkg.in/russross/blackfriday.v2"
	"regexp"
)

// Regex for YAML front matter in a Markdown document
var markdownFrontMatterRegex = regexp.MustCompile(`---\n[\s\S]*?\n---\n`)

// Functions for conversion between C and Go strings. Required here because cgo cannot be used in
// tests.

func convertToCString(goString string) *C.char {
	return C.CString(goString)
}

func convertToGoString(cString *C.char) string {
	return C.GoString(cString)
}

// Convention: Because all functions return C strings, errors are implemented as return values which
// start with "error: ".

//export convertCodeToHTML
func convertCodeToHTML(source *C.char, lexer *C.char) *C.char {
	sourceString := convertToGoString(source)
	lexerString := convertToGoString(lexer)
	htmlBuffer := new(bytes.Buffer)

	// Set up lexer for programming language
	var l chroma.Lexer
	if lexerString != "" {
		l = lexers.Get(lexerString)
	}
	if l == nil {
		l = lexers.Analyse(sourceString)
	}
	if l == nil {
		l = lexers.Fallback
	}
	l = chroma.Coalesce(l)

	// Use classes instead of inline styles
	formatter := htmlFormatter.New(htmlFormatter.WithClasses(true))

	iterator, err := l.Tokenise(nil, sourceString)
	if err != nil {
		errMessage := fmt.Sprintf("error: Could not render source code (tokenization error): %d", err)
		return convertToCString(errMessage)
	}

	err = formatter.Format(htmlBuffer, styles.GitHub, iterator)
	if err != nil {
		errMessage := fmt.Sprintf("error: Could not render source code (formatting error): %d", err)
		return convertToCString(errMessage)
	}

	// Chroma escapes tags, so HTML should be safe from code injection
	htmlString := htmlBuffer.String()
	return convertToCString(htmlString)
}

//export convertMarkdownToHTML
func convertMarkdownToHTML(source *C.char) *C.char {
	sourceString := convertToGoString(source)

	// Sanitize output but keep classes (required for syntax highlighting)
	policy := bluemonday.UGCPolicy()
	policy.AllowStyling()

	// Use Chroma for syntax highlighting in code blocks
	renderer := bfchroma.NewRenderer(
		bfchroma.WithoutAutodetect(),
		bfchroma.ChromaOptions(htmlFormatter.WithClasses(true)),
	)

	// Strip YAML front matter
	sourceString = markdownFrontMatterRegex.ReplaceAllString(sourceString, "")

	// Convert Markdown to HTML
	html := blackfriday.Run([]byte(sourceString), blackfriday.WithRenderer(renderer))
	htmlString := string(html)
	htmlStringSanitized := policy.Sanitize(htmlString)
	return convertToCString(htmlStringSanitized)
}

//export convertNotebookToHTML
func convertNotebookToHTML(source *C.char) *C.char {
	sourceString := convertToGoString(source)

	html := new(bytes.Buffer)
	err := nbtohtml.ConvertString(html, sourceString)
	if err != nil {
		errMessage := fmt.Sprintf("error: Could not convert Notebook to HTML: %d", err)
		return convertToCString(errMessage)
	}
	htmlString := html.String()
	return convertToCString(htmlString)
}

// Main function is required for `c-archive` builds.
func main() {}
