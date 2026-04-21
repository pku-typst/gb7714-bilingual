// Compile-only test for language detection (issue #16).
// Asserts:
//   1. Explicit `language` field wins over content heuristics.
//   2. An entry with two+ consecutive Han chars in a scanned field is "zh",
//      even without a language field.
//   3. A single stray Han char (transliteration, surname) does NOT flip an
//      otherwise-English entry — the `{2,}` threshold is preserved.
//   4. Chinese publisher / address on an entry without title/author flips "zh"
//      via the expanded field set.
//
// A clean compile = pass; any assert.eq failure panics and marks the test failed.

#import "/src/core/language.typ": detect-language

// 1. Explicit language field takes priority (even if title is Han)
#let e1 = (fields: (language: "english", title: "中文标题"))
#assert.eq(detect-language(e1), "en")

#let e2 = (fields: (langid: "zh", title: "An English Title"))
#assert.eq(detect-language(e2), "zh")

// Substring-match false positive regression: "french" / "japanese" / "korean"
// contain "en" as a substring and must NOT be classified as English.
#let e1b = (fields: (language: "french"))
#assert.eq(detect-language(e1b), "en") // defaults to en (no Han, no zh tag)
// More importantly — not mistakenly classified via the explicit branch.
// Add a Han character in the title to ensure heuristic wins over a bogus
// "en" substring match in a non-English language tag.
#let e1c = (fields: (language: "french", title: "论文写作指南"))
#assert.eq(detect-language(e1c), "zh")

// BCP-47 regional tags are recognized
#let e1d = (fields: (language: "en-US"))
#assert.eq(detect-language(e1d), "en")
#let e1e = (fields: (langid: "zh-Hans-CN"))
#assert.eq(detect-language(e1e), "zh")

// 2. Pure Chinese content, no language field → detected as zh
#let e3 = (fields: (title: "信息与文献", author: "张伟"))
#assert.eq(detect-language(e3), "zh")

// 3. Single stray Han char in English entry → stays en
//    (e.g., a Chinese surname with no other Han chars anywhere)
#let e4 = (fields: (title: "A Study of the Nile", author: "Zhou Y and Smith J"))
#assert.eq(detect-language(e4), "en")

// Single Han char embedded in title of otherwise-English entry → stays en
#let e5 = (fields: (title: "Translating 周 into modern English"))
#assert.eq(detect-language(e5), "en")

// 4. Expanded field coverage: Chinese publisher on an entry whose
//    title/author are empty — picked up via `publisher` field.
#let e6 = (fields: (publisher: "中国标准出版社"))
#assert.eq(detect-language(e6), "zh")

// Chinese address also counted
#let e7 = (fields: (title: "Foo", author: "Bar", address: "北京市"))
#assert.eq(detect-language(e7), "zh")

// 5. Empty entry defaults to en
#let e8 = (fields: (:))
#assert.eq(detect-language(e8), "en")

// 6. Missing `fields` key handled gracefully
#assert.eq(detect-language((:)), "en")
