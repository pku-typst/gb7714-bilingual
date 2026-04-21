// End-to-end test for the public data API.
// Exercises `init-gb7714` + `@key` citations + `get-cited-entries()` together,
// and asserts that the returned entries carry BOTH the resolved `entry-type`
// (e.g., @book with entrysubtype=standard → "standard") and the original
// BibTeX `raw-entry-type` (issue #15).

#import "/lib.typ": gb7714-bibliography, get-cited-entries, init-gb7714

#show: init-gb7714.with(
  read("test.bib"),
  style: "numeric",
  version: "2025",
)

// Register three citations covering distinct resolution paths.
@bookstandard
@arxivpaper
@plainjournal

// Render the bibliography so the cite handlers' `label(...)` targets resolve
// (without this, Typst errors out on "label does not exist").
#gb7714-bibliography(title: none)

#context {
  let entries = get-cited-entries()
  assert.eq(entries.len(), 3, message: "expected 3 cited entries")

  // @book + entrysubtype = standard → resolved to "standard"
  let book-std = entries.find(e => e.key == "bookstandard")
  assert.ne(book-std, none, message: "bookstandard not found in entries")
  assert.eq(book-std.entry-type, "standard")
  assert.eq(book-std.raw-entry-type, "book")

  // @misc + archivePrefix = arXiv + eprint → resolved to "preprint"
  let arxiv = entries.find(e => e.key == "arxivpaper")
  assert.ne(arxiv, none, message: "arxivpaper not found in entries")
  assert.eq(arxiv.entry-type, "preprint")
  assert.eq(arxiv.raw-entry-type, "misc")

  // Plain @article — both fields should be "article"
  let plain = entries.find(e => e.key == "plainjournal")
  assert.ne(plain, none, message: "plainjournal not found in entries")
  assert.eq(plain.entry-type, "article")
  assert.eq(plain.raw-entry-type, "article")

  // Language detection: all three entries have explicit `language = english`
  for e in entries {
    assert.eq(e.lang, "en", message: "entry " + e.key + " should be en")
  }

  // Sentence-case regression: citegeist is called with
  // sentence-case-titles: false, so mixed-case English titles must be
  // preserved verbatim. Would fail ("Neural networks for text classification")
  // if the sentence-case option is ever flipped back on upstream.
  assert.eq(
    plain.fields.title,
    "Neural Networks for Text Classification",
  )
}
