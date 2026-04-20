// GB/T 7714 双语参考文献系统 - 语言检测模块

// 参与语言自动判断的字段（包含人类可读的文本）
#let _LANG_DETECT_FIELDS = (
  "title",
  "author",
  "editor",
  "translator",
  "journal",
  "journaltitle",
  "booktitle",
  "publisher",
  "organization",
  "institution",
  "school",
  "address",
  "location",
  "series",
  "note",
  "howpublished",
)

/// 从条目字段中拼接文本用于语言探测
#let _collect-detect-text(fields) = {
  _LANG_DETECT_FIELDS
    .map(k => str(fields.at(k, default: "")))
    .filter(x => x != "")
    .join(" ")
}

/// 从显式字段（language / langid）读取语言；未显式声明返回 none
/// 防御性地将字段值强制为字符串，避免 bib 解析器偶尔返回 content/int 等类型时抛错
#let _explicit-language(fields) = {
  for key in ("language", "langid") {
    let v = lower(str(fields.at(key, default: "")))
    if v == "" { continue }
    if "zh" in v or "chinese" in v or "中" in v {
      return "zh"
    }
    if "en" in v or "english" in v {
      return "en"
    }
  }
  none
}

/// 检测文献条目的语言
/// 优先级：显式 language/langid > 字段文本中的汉字检测 > 默认英文
/// - 显式字段：language/langid 中含 "zh"/"chinese"/"中" 判为中文，含 "en"/"english" 判为英文
/// - 汉字检测：扫描 `_LANG_DETECT_FIELDS` 列出的字段，出现两个及以上连续汉字时判为中文；
///   偶发单字（英文条目中出现的译音、地名等）不会触发中文判定
/// - 其他情况默认英文
#let detect-language(entry) = {
  let fields = entry.at("fields", default: (:))

  let explicit = _explicit-language(fields)
  if explicit != none {
    return explicit
  }

  let text-to-check = _collect-detect-text(fields)

  if text-to-check.find(regex("\p{Han}{2,}")) != none {
    return "zh"
  }

  return "en"
}
