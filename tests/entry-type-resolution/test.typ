// Compile-only test for entry-type resolution (issue #15).
// Locks the contract that `resolve-entry-type` returns the *resolved* type
// (e.g., @book + entrysubtype=standard → "standard"), which is then surfaced
// as `entry-type` (resolved) and `raw-entry-type` (original) by the public
// `get-cited-entries` / `get-all-entries` APIs.
//
// `mark` mapping, `entrysubtype` / `note` detection, arXiv-style preprint
// heuristics, and standard-by-number-prefix detection are all exercised here.

#import "/src/renderers/mod.typ": resolve-entry-type

#let entry(entry-type, ..fields) = (
  entry_type: entry-type,
  fields: fields.named(),
)

// 1. Pass-through: plain types resolve to themselves
#assert.eq(resolve-entry-type(entry("article")), "article")
#assert.eq(resolve-entry-type(entry("book")), "book")
#assert.eq(resolve-entry-type(entry("inproceedings")), "inproceedings")

// 2. entrysubtype detection (biblatex-gb7714 compatibility)
#assert.eq(
  resolve-entry-type(entry("book", entrysubtype: "standard")),
  "standard",
)
#assert.eq(
  resolve-entry-type(entry("book", note: "standard")),
  "standard",
)
#assert.eq(
  resolve-entry-type(entry("article", entrysubtype: "newspaper")),
  "newspaper",
)
#assert.eq(
  resolve-entry-type(entry("article", note: "news")),
  "newspaper",
)
#assert.eq(
  resolve-entry-type(entry("misc", entrysubtype: "preprint")),
  "preprint",
)

// 3. arXiv heuristics (issue: auto-detect preprints from biblatex fields)
#assert.eq(
  resolve-entry-type(entry(
    "misc",
    archiveprefix: "arXiv",
    eprint: "2303.12345",
  )),
  "preprint",
)
#assert.eq(
  resolve-entry-type(entry(
    "article",
    journal: "arXiv preprint arXiv:1706.03762",
  )),
  // @article is NOT in the heuristic's candidate set (would conflict with
  // ordinary journal articles), so this stays "article" unless the user adds
  // entrysubtype=preprint.
  "article",
)

// 4. Standard-by-number-prefix only triggers for unknown raw types
#assert.eq(
  resolve-entry-type(entry("unknown", number: "GB/T 7714-2025")),
  "standard",
)
#assert.eq(
  resolve-entry-type(entry("unknown", number: "ISO 690:2010")),
  "standard",
)

// 5. `mark` field overrides everything else
#assert.eq(resolve-entry-type(entry("misc", mark: "S")), "standard")
#assert.eq(resolve-entry-type(entry("misc", mark: "N")), "newspaper")
#assert.eq(resolve-entry-type(entry("misc", mark: "PP")), "preprint")
// `usera` is the biblatex-recommended alias for `mark`
#assert.eq(resolve-entry-type(entry("misc", usera: "S")), "standard")

// An empty `mark` (e.g., `mark = {}` in the bib) must NOT be treated as an
// explicit override — the entry should still fall through to subtype/
// heuristic detection.
#assert.eq(
  resolve-entry-type(entry(
    "misc",
    mark: "",
    archiveprefix: "arXiv",
    eprint: "2303.12345",
  )),
  "preprint",
)
#assert.eq(
  resolve-entry-type(entry("book", mark: "", entrysubtype: "standard")),
  "standard",
)

// 6. Missing entry_type defaults to "misc"
#assert.eq(resolve-entry-type((fields: (:))), "misc")
