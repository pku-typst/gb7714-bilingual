// Guards the public surface of `lib.typ`. Fails at import time if any of
// the documented re-exports is removed or renamed — in particular the
// helpers that callers need from inside a `full-control` callback
// (issue #18): format-authors, format-author-intext, detect-language.
//
// Also touch each symbol once to ensure it's actually callable, not just
// importable.

#import "/lib.typ": (
  detect-language, format-author-intext, format-authors, gb7714-bibliography,
  get-all-entries, get-cited-entries, init-gb7714, multicite,
)

// Sanity: each helper is callable and returns a sensible value.
#let parsed-names = (
  author: ((family: "Smith", given: "John"), (family: "Jones", given: "Alice")),
)

#let rendered = format-authors(parsed-names, "en", version: "2025")
#assert.eq(type(rendered), str)
#assert(rendered != "", message: "format-authors returned empty string")

#let intext = format-author-intext(parsed-names, "en", version: "2025")
#assert.eq(type(intext), str)
#assert(intext != "", message: "format-author-intext returned empty string")

// detect-language accepts the (fields: (...)) shape used internally.
#assert.eq(
  detect-language((fields: (language: "english", title: "A Paper"))),
  "en",
)
#assert.eq(
  detect-language((fields: (title: "论文标题"))),
  "zh",
)

// The other re-exports need init-gb7714 state to be meaningful at
// runtime — exercise them at type level instead so a rename / removal
// still fails here beyond import.
#for symbol in (
  gb7714-bibliography,
  get-all-entries,
  get-cited-entries,
  init-gb7714,
  multicite,
) {
  assert.eq(
    type(symbol),
    function,
    message: "re-exported symbol is not a function",
  )
}
