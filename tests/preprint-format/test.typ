// Visual regression: locks the rendered output of a preprint entry (issue #12).
// Verifies the GB/T 7714—2025 preprint layout end-to-end:
//   - `[PP/OL]` type identifier (2025 preprint type code)
//   - platform directly followed by `（YYYY）` with no separator
//   - cited date `[YYYY-MM-DD]` adjacent to the creation date
//   - URL then DOI at the end, hyperlinked
//
// Requires the bundled SimSun font to render GB/T 7714—2025's full-width
// punctuation (`，`, `（`, `）`) — run tests with `just test` / `tt run --font-path fonts`
// (CI and the top-level Justfile do this). Regenerate the reference snapshot
// with `just test-update preprint-format`.

#import "/lib.typ": gb7714-bibliography, init-gb7714

#set page(width: 16cm, height: auto, margin: 1cm)
// GB/T 7714—2025 uses Chinese full-width punctuation (，（）) even for English
// entries — the default Typst-embedded fonts lack these glyphs, so we pin the
// repo's bundled SimSun fallback. Run tests with `tt run --font-path fonts`
// (CI does this) to make these fonts visible.
#set text(font: ("Times New Roman", "SimSun"), size: 10pt)

#show: init-gb7714.with(
  read("test.bib"),
  style: "numeric",
  version: "2025",
)

@arxivpaper

#gb7714-bibliography(title: none)
