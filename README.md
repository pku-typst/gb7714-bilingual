# gb7714-bilingual

GB/T 7714 双语参考文献系统，支持中英文术语自动切换。

> 同时支持 **GB/T 7714—2015** 和 **GB/T 7714—2025**（2026-07-01 实施）两个版本

## 特性

- ✅ **双版本支持**：可选择 2015 或 2025 版本标准
- ✅ 自动检测文献语言（通过 `language` 字段、正则匹配汉字）
- ✅ 中英文术语自动切换（第X卷/v.X、期/no.、等/et al.）
- ✅ 支持顺序编码制（numeric）和著者-出版年制（author-date）
- ✅ 正确处理作者格式化（中文连写、英文姓大写+名首字母）
- ✅ 支持同作者同年文献消歧（a, b, c 后缀）
- ✅ 支持多引用合并（`multicite` 函数）
- ✅ 支持点击引用跳转到参考文献列表
- ✅ 完整的文献类型标识
- ✅ 支持多个 BibTeX 文件

## 安装

```typst
#import "@preview/gb7714-bilingual:0.1.0": init-gb7714, gb7714-bibliography, multicite
```

## 使用方法

### 基本用法

```typst
#import "@preview/gb7714-bilingual:0.1.0": init-gb7714, gb7714-bibliography, multicite

// 使用 2025 版本（默认）
#show: init-gb7714.with("/ref.bib", style: "numeric", version: "2025")

正文中使用 @wang2010guide 引用文献。

#gb7714-bibliography()
```

> **注意**：`bib-file` 路径必须以 `/` 开头，表示基于项目根目录的绝对路径。

### 选择标准版本

```typst
// 使用 GB/T 7714—2015
#show: init-gb7714.with("/ref.bib", style: "numeric", version: "2015")

// 使用 GB/T 7714—2025（默认）
#show: init-gb7714.with("/ref.bib", style: "numeric", version: "2025")
```

### 著者-出版年制

```typst
#show: init-gb7714.with("/ref.bib", style: "author-date", version: "2025")

这是一个引用 @smith2020。

#gb7714-bibliography()
```

### 多个 BibTeX 文件

```typst
// 使用多个 bib 文件
#show: init-gb7714.with(("/main.bib", "/extra.bib"), style: "numeric")
```

### 多引用合并

```typst
// 同一作者的多篇文献会自动合并年份
#multicite("smith2020a", "smith2020b", "jones2019")
// 输出：（Smith，2020a，2020b；Jones，2019）
```

### 自定义渲染（高级）

```typst
// 使用 full-control 完全控制输出格式
#gb7714-bibliography(full-control: entries => {
  for e in entries [
    // 自定义编号格式
    (#e.order)#h(1em)
    // 使用默认渲染结果
    #e.rendered
    #parbreak()
  ]
})

// 或者完全自定义，访问原始字段
#gb7714-bibliography(full-control: entries => {
  for e in entries {
    let f = e.fields
    [
      [#e.order]
      #f.at("author", default: "").
      #emph(f.at("title", default: "")).
      #f.at("journal", default: ""),
      #f.at("year", default: "").
    ]
    parbreak()
  }
})
```

## 2015 与 2025 版本差异

| 差异点                    | GB/T 7714—2015    | GB/T 7714—2025    |
| ------------------------- | ----------------- | ----------------- |
| 预印本类型标识            | `[A]`（档案）     | `[PP]`（预印本）  |
| 著者-出版年制正文引用括号 | 英文 `()`         | 统一中文 `（）`   |
| 正文引用分隔符            | 英文 `; ` 和 `, ` | 中文 `；` 和 `，` |

## BibTeX 文件格式

为获得最佳效果，建议在 BibTeX 条目中添加 `language` 字段：

```bibtex
@article{wang2010guide,
  title   = {科技论文中文摘要写作要点分析},
  author  = {王晓华 and 闫其涛 and 程智强 and 张睿},
  journal = {编辑学报},
  year    = {2010},
  language = {chinese}
}

@book{kopka2004guide,
  title     = {Guide to LATEX},
  author    = {Kopka, Helmut and Daly, Patrick W},
  publisher = {Addison-Wesley},
  year      = {2004},
  language = {english}
}
```

如果没有 `language` 字段，系统会通过检测标题/作者中的汉字自动判断语言。

## API 参考

### `init-gb7714(bib-files, style: "numeric", version: "2025", doc)`

初始化 GB/T 7714 双语参考文献系统。

- `bib-files`: BibTeX 文件路径或路径数组（**路径必须以 `/` 开头**）
  - 单文件：`"/ref.bib"`
  - 多文件：`("/main.bib", "/extra.bib")`
- `show-url`: 是否显示 URL（默认 `true`）
- `show-doi`: 是否显示 DOI（默认 `true`）
- `show-accessed`: 是否显示访问日期（默认 `true`）
- `style`: 引用风格
  - `"numeric"`: 顺序编码制，如 [1]
  - `"author-date"`: 著者-出版年制，如（王，2020）
- `version`: 标准版本
  - `"2015"`: GB/T 7714—2015
  - `"2025"`: GB/T 7714—2025（默认）

### `gb7714-bibliography(title: auto, full-control: none)`

渲染参考文献列表。

- `title`: 参考文献标题
  - `auto`（默认）：根据文献语言自动选择（"参考文献" 或 "References"），一级标题
  - `none`：不显示标题
  - 自定义内容：如 `heading(level: 2)[References]`
- `full-control`: 完全控制渲染的回调函数（高级用法）
  - 签名：`(entries) => content`
  - 使用此参数时，用户完全控制输出格式

### `get-cited-entries()`

获取被引用的条目列表（低层 API，需在 `context` 中使用）。

返回数组，每个元素包含：

- `key`: 引用键
- `order`: 引用顺序
- `year-suffix`: 消歧后缀（如 "a", "b"）
- `lang`: 语言（"zh" 或 "en"）
- `entry-type`: 条目类型
- `fields`: 原始字段字典
- `parsed-names`: 解析后的作者名
- `rendered`: 默认渲染结果
- `ref-label`: 用于跳转的 label 对象
- `labeled-rendered`: 已附加 label 的渲染结果（推荐）

### `multicite(..keys)`

多引用合并函数。

- `keys`: 引用键列表

## 支持的条目类型

| BibTeX 类型                | 2015 标识 | 2025 标识 | 说明            |
| -------------------------- | --------- | --------- | --------------- |
| article                    | [J]       | [J]       | 期刊文章        |
| preprint                   | [A]       | [PP]      | 预印本          |
| newspaper                  | [N]       | [N]       | 报纸文章        |
| book, inbook, incollection | [M]       | [M]       | 图书            |
| inproceedings, conference  | [C]       | [C]       | 会议论文        |
| phdthesis, mastersthesis   | [D]       | [D]       | 学位论文        |
| techreport, report         | [R]       | [R]       | 报告            |
| standard                   | [S]       | [S]       | 标准            |
| patent                     | [P]       | [P]       | 专利            |
| dataset                    | [DS]      | [DS]      | 数据集          |
| map                        | [CM]      | [CM]      | 地图            |
| software                   | [CP]      | [CP]      | 软件/计算机程序 |
| online, webpage            | [EB/OL]   | [EB/OL]   | 网页/电子公告   |
| archive                    | [A]       | [A]       | 档案            |
| misc                       | [Z]       | [Z]       | 其他            |

带 URL 或 DOI 的条目会自动添加 `/OL` 载体标识，如 `[J/OL]`。

## 项目结构

```bash
src/
├── core/           # 核心模块（状态、工具、语言检测）
├── versions/       # 版本配置（2015、2025）
├── renderers/      # 渲染器（期刊、书籍、会议等）
├── authors.typ     # 作者格式化
├── types.typ       # 文献类型标识
└── api.typ         # 公共 API
lib.typ             # 主入口
```

## 许可证

MIT
