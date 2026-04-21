// Regression test for issue #13.
// Before the fix, `init-gb7714` emitted a hidden `bibliography()` at the very
// top of the document. Even wrapped in `hide(place(...))`, Typst treated the
// first page as non-empty, causing `pagebreak(weak: true, to: "odd")` to
// fire and — combined with `to: "odd"` — to insert up to two blank pages
// before any visible content.
//
// After the fix, the hidden `bibliography()` is emitted at the end of the
// document, so the opening page stays truly empty, the weak pagebreak elides,
// and this minimal document fits on exactly one page.

#import "/lib.typ": gb7714-bibliography, init-gb7714

#set page(width: 10cm, height: 10cm, margin: 1cm)
#show: init-gb7714.with(
  read("test.bib"),
  style: "numeric",
  version: "2025",
)

#pagebreak(weak: true, to: "odd")

= Heading
Testing @minimal.

#gb7714-bibliography()

#context {
  let total = counter(page).final().first()
  assert.eq(
    total,
    1,
    message: (
      "expected 1 page, got "
        + str(total)
        + " — regression of issue #13"
        + " (hidden bibliography() leaking layout at document start)"
    ),
  )
}
