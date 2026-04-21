// GB/T 7714 双语参考文献系统 - 预印本渲染器
//
// GB/T 7714—2025 预印本模板（[PP/OL]）：
//   主要责任者. 题名[PP/OL]. 版本. 预印本出版平台（创建或修改日期）[引用日期]. 获取和访问路径. 永久标识符.
//
// 关键规则（与普通在线期刊文章不同）：
//   1. 平台名（如 arXiv、bioRxiv、SSRN）与创建日期相邻，`（YYYY-MM-DD）` 紧跟平台，中间不加逗号/句点；
//   2. 创建日期与引用日期相邻：`（创建日期）[引用日期]`，之间无分隔符；
//   3. 创建日期取自 `date`（优先，通常为完整 ISO 日期），缺失时退回 `year`；
//   4. 平台字段来源优先级：`journal` > `journaltitle` > `howpublished` > `publisher`
//      > `archiveprefix` / `eprinttype`；不将 `eprint` 标识与平台拼接成 `平台:ID`
//      （ID 已在 URL 中体现，标准不要求重复）；
//   5. GB/T 7714—2015 没有专门的预印本类型，沿用 `archive` → `[A/OL]` 的约定。

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-punctuation
#import "../core/utils.typ": append-access-info, smart-join

/// 读取预印本出版平台字段
/// 按优先级返回第一个非空字符串；全部缺失或为空时退回 archiveprefix/eprinttype
#let _preprint-source(f) = {
  for key in ("journal", "journaltitle", "howpublished", "publisher") {
    let v = str(f.at(key, default: ""))
    if v != "" { return v }
  }
  for key in ("archiveprefix", "eprinttype") {
    let v = str(f.at(key, default: ""))
    if v != "" { return v }
  }
  ""
}

/// 创建日期：优先 `date`，其次 `year`（不含消歧后缀）
/// year-suffix (a/b/c) 仅用于 author-date 书目条目中的年份消歧，
/// 不应出现在 `（发布日期）` 里（例如不能输出 `（2023a）`）
#let _preprint-created-date(f, plain-year) = {
  let raw-date = str(f.at("date", default: ""))
  if raw-date != "" { return raw-date }
  plain-year
}

/// 预印本通用渲染
#let render-preprint(
  entry,
  lang,
  year-suffix: "",
  style: "numeric",
  version: "2025",
  config: (show-url: true, show-doi: true, show-accessed: true),
) = {
  let f = entry.fields
  let authors = format-authors(entry.parsed_names, lang, version: version)
  let title = f.at("title", default: "")
  // plain-year: bare bib year, used for the （创建日期）fallback and for the
  // `created != plain-year` guard below.
  // year: what the bibliography entry prints; year-suffix (a/b/c) appended
  // only in author-date mode to disambiguate same-author same-year entries.
  let plain-year = str(f.at("year", default: ""))
  let year = plain-year + year-suffix
  let edition = str(f.at("edition", default: ""))
  let source = _preprint-source(f)
  let created = _preprint-created-date(f, plain-year)

  let url = f.at("url", default: "")
  let doi = f.at("doi", default: "")
  let mark = f.at("_resolved_mark", default: none)
  let medium = f.at("_resolved_medium", default: none)

  let type-id = render-type-id(
    "preprint",
    has-url: url != "" or doi != "",
    version: version,
    mark: mark,
    medium: medium,
  )
  let punct = get-punctuation(version, lang)

  let parts = ()

  // 作者 / 标题
  if style == "author-date" {
    if authors != "" {
      parts.push(authors + punct.comma + year)
    }
  } else if authors != "" {
    parts.push(authors)
  }
  parts.push(title + type-id)

  // 版本（如有）
  if edition != "" {
    parts.push(edition)
  }

  // 平台 + 创建日期：`<source>（<date>）`，中间不加标点
  // author-date 模式下年份已在作者块；若 `date` 含完整日期（与仅年份不同）仍保留在括号内
  // 无 source 时跳过整段：避免单独出现 `（2023）` 这样没有归属的日期
  // 注：与 plain-year 比较（不含消歧后缀），否则 year="2023a" 会让 created="2023" 仍然通过判断
  let include-date = (
    style == "numeric" or (created != "" and created != plain-year)
  )
  if source != "" {
    let source-part = source
    if include-date and created != "" {
      source-part += punct.lparen + created + punct.rparen
    }
    parts.push(source-part)
  }

  let result = smart-join(parts)
  append-access-info(result, entry, config: config)
}
