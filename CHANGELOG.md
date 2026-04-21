# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Dedicated preprint renderer: formats `[PP/OL]` / `[A/OL]` entries per GB/T 7714—2025 § preprint template (`主要责任者. 题名[PP/OL]. 版本. 预印本出版平台（创建或修改日期）[引用日期]. 获取和访问路径. 永久标识符.`). Platform name is taken verbatim from `journal` / `journaltitle` / `howpublished` / `publisher`, falling back to `archiveprefix` / `eprinttype` when none are set. Creation date `（YYYY-MM-DD）` is placed directly after the platform with no separator and flows straight into the cited date `[YYYY-MM-DD]`. Under GB/T 7714—2015 the same entry resolves to `[A/OL]` via the existing archive type map. Example (numeric, 2025) for a `@misc` with `archiveprefix = {arXiv}`, `eprint = {2303.12345}`, `year = {2023}`, `url = {https://arxiv.org/abs/2303.12345}`, `urldate = {2024-01-10}`, `doi = {10.48550/arXiv.2303.12345}`:
  ```text
  Brown T，Smith J. Large Language Models: A Survey[PP/OL]. arXiv（2023）[2024-01-10]. https://arxiv.org/abs/2303.12345. DOI: 10.48550/arXiv.2303.12345.
  ```
- `raw-entry-type` field on entries returned by `get-cited-entries`/`get-all-entries`: exposes the original BibTeX entry type for callers that need it.
- Public re-exports (for `full-control` callbacks and other custom rendering): `format-authors`, `format-author-intext`, `detect-language`, `get-all-entries`. Previously only `get-cited-entries` was reachable from `lib.typ`, forcing users to import from internal paths (e.g., `src/authors.typ`).

### Changed

- `entry-type` returned by `get-cited-entries`/`get-all-entries` is now the resolved type (e.g., `@book` with `entrysubtype = {standard}` is reported as `standard`), matching what the internal renderers use. Callers that relied on the raw BibTeX type should read `raw-entry-type` instead.
- Language auto-detection now scans a wider set of fields (title, authors, editor, translator, journal, booktitle, publisher, organization, institution, school, address, location, series, note, howpublished) in addition to the previous title + author, so entries that omit `language`/`langid` are classified more reliably. The Han-character threshold is unchanged (two or more consecutive Han characters → Chinese), so stray foreign-language transliterations in an English entry still don't flip the language.

### Fixed

- English titles are no longer lowercased by citegeist's default sentence-case transformation (e.g., `Neural Networks for Text Classification` now renders verbatim instead of `Neural networks for text classification`). `load-bibliography` is now called with `sentence-case-titles: false`.
- The hidden `bibliography()` that backs `@key` resolution is now emitted at the _end_ of the document instead of the start. When users put `pagebreak(weak: true, to: "odd")` before their first heading, the previous position caused Typst to treat the opening page as non-empty, firing the weak pagebreak and (with `to: "odd"`) inserting up to two blank pages before any content.
- An empty `mark` / `usera` / `medium` field (e.g., `mark = {}` in the bib) is now treated as unset. Previously the empty string was accepted as an explicit type override, bypassing `entrysubtype` / `note` detection, standard-by-number-prefix inference, and the arXiv preprint heuristic.
- Explicit `language` / `langid` matching now tokenizes the value on non-alphabetic characters and checks against an exact BCP-47 primary-subtag allowlist. Previously substring matching would misclassify `french`, `japanese`, `korean` etc. as English because those tokens contain `en`.

## [0.2.3] - 2026-03-27

### Added

- `cn-first` parameter for author-date style: controls whether Chinese entries appear before (`true`, default) or after (`false`) non-Chinese entries in the bibliography
- `pinyin-override` parameter: passes through to `auto-pinyin`'s `to-pinyin(..., override: ...)` for polyphone disambiguation (e.g., `(重: "chong2")`)
- Dependency on `auto-pinyin` 0.1.0
- Preprint/arXiv auto-detection: `@misc` with `archivePrefix = {arXiv}` or journal containing "arxiv" is now identified as preprint (`[PP/OL]` in 2025, `[A/OL]` in 2015). Also supports `entrysubtype`/`note` = `"preprint"` and `@unpublished` with arXiv fields.

### Changed

- Author-date bibliography sorting now groups entries by language (Chinese vs. non-Chinese) and sorts Chinese authors by pinyin (via `auto-pinyin`, style `tone-num-end`)

### Fixed

- `order` field reassignment after author-date sorting was a no-op due to Typst value-type semantics in `for` loops; fixed in both `get-cited-entries` and `get-all-entries`
- Hidden bibliography no longer affects layout positioning and page breaks (wrap `bibliography()` in `place()` before `hide()` so it occupies zero flow space)

## [0.2.2] - 2026-02-22

### Added

- `full` parameter to `gb7714-bibliography()` for displaying all entries (even uncited)
- `get-all-entries()` function for retrieving all bibliography entries
- `multicite` now accepts content body with `@key` references: `#multicite[@smith2020 @jones2021]`. Supports supplements via `@key[p. 42]` syntax. Existing string/dict API remains fully supported.

### Changed

- `title: auto` now uses `text.lang` (document body language) instead of checking bibliography sources' language field, matching Typst's native behavior
- Sort key now considers year for entries with the same author name

### Fixed

- URL and DOI now render as clickable hyperlinks in PDF (using `link()` function)
- Fixed sorting for `@collection` type: now uses editor as fallback when author is missing
- Fixed sorting for anonymous entries: now considers language ("Anonymous" vs "佚 名")

## [0.2.1] - 2026-01-24

### Added

- `usera` field support as biblatex-recommended alias for `mark`
- `entrysubtype` and `note` field detection for type disambiguation (biblatex-gb7714 compatibility)
  - `@book` + `entrysubtype/note = "standard"` → `[S]`
  - `@article` + `entrysubtype/note = "news"/"newspaper"` → `[N]`
- `medium` field support for custom carrier types (e.g., `medium = {MT}` → `[DB/MT]`)
- `bookauthor` field support for analytic entries (source document authors)
- `editor` field fallback for source authors when `bookauthor` is missing

### Fixed

- `@inbook` type identifier position: now correctly placed after analytic title
  - Before: `章节标题//主书名[M]`
  - After: `章节标题[M]//主书名`
- Name suffix formatting: removed comma before suffix (per GB/T 7714-2025 examples)
  - Before: `King M L, Jr.`
  - After: `King M L Jr.`
- Year suffix disambiguation now uses citation order instead of title alphabetical order (per GB/T 7714-2025 9.3.1.3)（[#6](https://github.com/pku-typst/gb7714-bilingual/pull/6)）
  - Before: suffixes assigned by title sort (could produce a, c, b)
  - After: suffixes assigned by citation order (always a, b, c in order of appearance)
- Invisible hidden bibliography title no longer triggers unexpected page break with `pagebreak(weak: true)` ([#4](https://github.com/pku-typst/gb7714-bilingual/pull/4) by [@Coekjan](https://github.com/Coekjan))
- Numeric style no longer incorrectly displays year suffixes (a, b, c) in bibliography （[#7](https://github.com/pku-typst/gb7714-bilingual/pull/7)）

## [0.2.0] - 2026-01-21

### Added

- `mark` field support for manual type declaration (S, N, G, etc.)
- Analytic entries (`@inbook`, `@incollection`) now include `//` separator
- `@collection` type support for compilations (`[G]`)
- `@periodical` type support for serials
- Automatic `@standard` detection via `number` field prefix (GB, ISO, IEEE, etc.)

### Changed

- **Breaking**: `init-gb7714` now accepts file content (bytes) instead of file path
  - Old: `init-gb7714.with("ref.bib", ...)`
  - New: `init-gb7714.with(read("ref.bib"), ...)`
  - Reason: Published packages cannot access user project files
- Hidden `bibliography()` is now automatically included; no manual `#hide(bibliography(...))` needed

## [0.1.0] - 2026-01-12

### Added

- Initial release
- Support for GB/T 7714—2015 and GB/T 7714—2025
- Numeric (顺序编码制) and author-date (著者-出版年制) citation styles
- Automatic Chinese/English language detection
- Author formatting with proper handling of prefixes, suffixes, and hyphenated names
- Same-author-same-year disambiguation (a, b, c suffixes)
- Multi-citation merging with `multicite` function
  - Dictionary arguments with `supplement` for page numbers
- Citation form control (`form` parameter): `prose`, `author`, `year`
- Citation supplement (`supplement` parameter) for page numbers
- Click-to-jump from citations to bibliography
- Complete entry type support (article, book, thesis, conference, report, patent, standard, webpage, etc.)
- Multiple BibTeX file support
