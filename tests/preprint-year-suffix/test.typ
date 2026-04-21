// Regression test for the year-suffix leak in the preprint renderer.
// Two same-author same-year arXiv preprints → author-date mode assigns
// 'a' / 'b' year-suffixes for disambiguation. The suffix is a
// bibliography-display artifact for the author segment only; it must NOT
// appear in the creation date parens. Prior buggy output (hidden regression):
//     Brown T，2023a. Foo Paper[PP/OL]. arXiv（2023a）. ...
// Expected output:
//     Brown T，2023a. Foo Paper[PP/OL]. arXiv. ...
// (no `（2023…）` segment at all, because plain-year == created → duplicate
// suppression kicks in).
//
// Requires repo-bundled SimSun for 2025 full-width punctuation; run via
// `just test` / `tt run --font-path fonts`.

#import "/lib.typ": gb7714-bibliography, init-gb7714

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: ("Times New Roman", "SimSun"), size: 10pt)

#show: init-gb7714.with(
  read("test.bib"),
  style: "author-date",
  version: "2025",
)

@arxiva
@arxivb

#gb7714-bibliography(title: none)
