# GB/T 7714 实现说明

本文档记录 `gb7714-bilingual` 库的实现细节、CSL 规范对照和边界情况处理。

## 目录

1. [CSL 规范对照](#1-csl-规范对照)
2. [版本差异](#2-版本差异)
3. [作者格式化规则](#3-作者格式化规则)
4. [排序规则](#4-排序规则)
5. [引用功能](#5-引用功能)
6. [边界情况处理](#6-边界情况处理)
7. [公共函数](#7-公共函数)
8. [测试命令](#8-测试命令)

---

## 1. CSL 规范对照

本库参考以下 CSL 文件实现：

- `references/GB-T-7714—2015-author-year.csl`
- `references/GB-T-7714—2015-numeric.csl`
- `references/GB-T-7714—2025-author-year.csl`
- `references/GB-T-7714—2025-numeric.csl`

关键 CSL 全局属性：

```xml
demote-non-dropping-particle="never"  <!-- prefix 不降级，参与排序 -->
name-as-sort-order="all"              <!-- 所有作者都使用 "姓, 名" 格式 -->
initialize-with=" "                   <!-- 名缩写后的分隔符 -->
```

---

## 2. 版本差异

### 2.1 标点符号

| 标点类型     | 2015 | 2025   |
| ------------ | ---- | ------ |
| 作者分隔符   | `, ` | `，`   |
| 字段分隔符   | `, ` | `，`   |
| 冒号         | `: ` | `：`   |
| 期号括号     | `()` | `（）` |
| 发布日期括号 | `()` | `（）` |
| 访问日期括号 | `[]` | `[]`   |
| 句号         | `.`  | `.`    |

### 2.2 作者姓名格式

| 规则             | 2015         | 2025         |
| ---------------- | ------------ | ------------ |
| 姓氏大小写       | 大写 `SMITH` | 原样 `Smith` |
| 连字符名缩写     | 展开 `J P`   | 保留 `J-P`   |
| prefix（如 van） | 保持原样     | 保持原样     |
| suffix（如 Jr.） | 保持原样     | 保持原样     |

### 2.3 条目类型规则

| 规则           | 2015   | 2025   |
| -------------- | ------ | ------ |
| 标准文献作者   | 显示   | 不显示 |
| 卷号前缀（EN） | `Vol.` | `v.`   |

---

## 3. 作者格式化规则

### 3.1 基本结构

```
[prefix] FAMILY given-initials, suffix
```

示例：

- `de Gaulle C` → prefix="de", family="Gaulle", given="Charles"
- `King M L, Jr.` → family="King", given="Martin Luther", suffix="Jr."
- `van Beethoven L` → prefix="van", family="Beethoven", given="Ludwig"

### 3.2 CSL 相关属性

```xml
<name-part name="family" text-case="uppercase"/>  <!-- 仅 2015 -->
```

- 2015：`family` 大写，但 `prefix` 和 `suffix` 保持原样
- 2025：所有部分保持原样

### 3.3 连字符处理

CSL 未明确定义，根据实际 CSL 输出推断：

- 2015：`Jean-Pierre` → `J P`（展开为空格分隔）
- 2025：`Jean-Pierre` → `J-P`（保留连字符）

---

## 4. 排序规则

### 4.1 Numeric 模式

按引用出现顺序排序（`order` 字段）。

### 4.2 Author-Date 模式

**排序键**：

1. 第一作者姓氏（含 prefix）
2. 年份

**CSL 规范**：

```xml
<sort>
  <key macro="author"/>
  <key macro="date-intext"/>
</sort>
```

**关键属性**：

```xml
demote-non-dropping-particle="never"
```

这意味着 **prefix 参与排序**：

- `de Gaulle` 排在 D 区
- `van Beethoven` 排在 V 区

**大小写敏感性**：

CSL 规范未明确定义排序的大小写敏感性。本库采用**大小写不敏感**排序（即 `lower(sort-key)`），这是学术文献系统的常见实践。

**排序示例**：

| 作者          | 排序键（小写） | 位置 |
| ------------- | -------------- | ---- |
| Brown         | brown          | B    |
| de Gaulle     | de gaulle      | D    |
| Gates         | gates          | G    |
| van Beethoven | van beethoven  | V    |

---

## 5. 引用功能

### 5.1 引用形式（form 参数）

支持 Typst 标准的 `form` 参数，控制引用显示形式：

| form 值  | Numeric 模式          | Author-Date 模式      |
| -------- | --------------------- | --------------------- |
| `none`   | 上标 `[1]`            | 括号 `(Smith, 2020)`  |
| `normal` | 同上                  | 同上                  |
| `prose`  | 非上标 `[1]`          | 散文 `Smith (2020)`   |
| `full`   | 非上标 `[1]`          | 同 normal             |
| `author` | 仅作者 `Smith et al.` | 仅作者 `Smith et al.` |
| `year`   | 仅年份 `2020`         | 仅年份 `(2020)`       |

**用法示例**：

```typst
// 上标形式（默认）
孔乙己提到#super[@smith2020]的重要发现

// 非上标形式
另见#cite(<smith2020>, form: "prose")的详细分析

// 仅作者
研究由#cite(<smith2020>, form: "author")完成

// 仅年份
该研究发表于#cite(<smith2020>, form: "year")年
```

### 5.2 带页码引用（supplement 参数）

使用 `supplement` 参数添加页码或其他附加信息：

**简写形式**：

```typst
@smith2020[260]           // → [1, 260]
@smith2020[126--129]      // → [1, 126–129]
```

**函数形式**：

```typst
#cite(<smith2020>, form: "prose", supplement: [第 5.2 节])
// → [1, 第 5.2 节]（非上标）
```

### 5.3 多引用合并（multicite）

`multicite` 函数支持两种参数形式：

**字符串形式**（原有功能）：

```typst
#multicite("smith2020a", "smith2020b", "jones2019")
// Numeric: [1-3]
// Author-date: (Smith, 2020a, 2020b; Jones, 2019)
```

**字典形式**（带 supplement）：

```typst
#multicite(
  (key: "smith2020a", supplement: [260]),
  "smith2020b",
  (key: "jones2019", supplement: [Table 2]),
)
// Numeric: [1: 260, 2, 3: Table 2]（2025 用中文冒号）
// Author-date: (Smith, 2020a: 260, 2020b; Jones, 2019: Table 2)
// 注：页码用冒号分隔（2015 用 `: `，2025 用 `：`）
```

**非上标形式**：

```typst
#multicite("smith2020a", "smith2020b", form: "prose")
// Numeric: [1-2]（非上标）
// Author-date: Smith (2020a, 2020b)

#multicite((key: "a", supplement: [260]), "b", form: "prose")
// Numeric: [1]260[2]（非上标）
```

**参数说明**：

| 参数 | 类型          | 说明                                                 |
| ---- | ------------- | ---------------------------------------------------- |
| keys | str \| dict   | 引用键列表，字典形式支持 `key` 和 `supplement`       |
| form | string (命名) | 引用形式：`none`/`"normal"` 默认，`"prose"` 散文形式 |

**`form` 参数效果**：

| form 值           | 顺序编码制     | 著者-出版年制                                     |
| ----------------- | -------------- | ------------------------------------------------- |
| `none`/`"normal"` | 上标 `[1-3]`   | 整体括号 `（Smith，2020a，2020b；Jones，2019）`   |
| `"prose"`         | 非上标 `[1-3]` | 仅年份括号 `Smith（2020a，2020b）；Jones（2019）` |

**行为说明**：

- 保持原始引用顺序
- 连续无 supplement 的引用会压缩（如 `[2-4]`）
- 带 supplement 的引用单独显示（如 `[1, 260]`）

---

## 6. 边界情况处理

### 6.1 作者相关

#### 作者为空（佚名）

- **场景**：BibTeX 中无 `author` 字段
- **预期**：
  - numeric：显示"佚名"或"Anon"（根据语言）
  - author-date：年份放入出版信息，不丢失

#### 组织名作者（无 given name）

- **场景**：`author = {Typst Team}`
- **预期**：不产生多余空格：`Typst Team.` 而非 `Typst Team .`

#### 多作者（超过 3 个）

- **场景**：4 个或更多作者
- **预期**：显示前 3 个 + "等" 或 "et al."

### 6.2 出版信息缺失

#### address 有值，publisher 为空

- **预期**：`北京，2015.` 而非 `北京：，2015.`

#### address 为空，publisher 有值

- **预期**：`中国标准出版社，2015.`

#### year 为空

- **预期**：`北京：出版社.` 而非 `北京：出版社，.`

### 6.3 期刊文章

#### journal 为空

- **预期**：不以逗号开头

#### volume/number/pages 为空

- **预期**：智能省略对应部分及其前导标点

### 6.4 会议论文（2015）

#### address 有值，publisher 为空

- **预期**：`Florence, Italy, 2019: 100–110`（不产生双冒号）

### 6.5 标准文献

#### 2025 版本

- **预期**：不显示作者，标准号在最前

### 6.6 连续引用压缩

- **规则**：2 个及以上连续编号压缩为范围
- **示例**：`[1,2,3,5]` → `[1-3,5]`

---

## 7. 公共函数

位于 `src/core/utils.typ`：

| 函数                                              | 功能                     |
| ------------------------------------------------- | ------------------------ |
| `join-non-empty(items, sep)`                      | 跳过空字段拼接           |
| `build-pub-info(address, publisher, year, punct)` | 构建出版信息（处理缺失） |
| `build-author-year(authors, year, punct)`         | 处理作者-年份组合        |
| `build-journal-info(...)`                         | 构建期刊信息             |
| `append-access-info(result, entry, config)`       | 添加 URL/DOI/访问日期    |
| `append-pages(result, pages, punct)`              | 添加页码                 |
| `format-citation-numbers(nums)`                   | 压缩连续引用编号         |

---

## 8. 测试命令

```bash
# 编译所有 4 个版本
typst compile example.typ build/2025-numeric.pdf --font-path fonts --input version=2025
typst compile example.typ build/2015-numeric.pdf --font-path fonts --input version=2015
typst compile example-authordate.typ build/2025-authordate.pdf --font-path fonts --input version=2025
typst compile example-authordate.typ build/2015-authordate.pdf --font-path fonts --input version=2015

# 检查输出
pdftotext build/2025-numeric.pdf - | grep -A 30 "^参考文献$"
pdftotext build/2015-numeric.pdf - | grep -A 30 "^参考文献$"
pdftotext build/2025-authordate.pdf - | grep -A 30 "^参考文献$"
pdftotext build/2015-authordate.pdf - | grep -A 30 "^参考文献$"
```

---

## 更新日志

- **2026-01-13**：添加引用形式（form）支持：prose, author, year 等
- **2026-01-13**：添加带页码引用（supplement）支持
- **2026-01-13**：`multicite` 支持字典参数形式，可为单个引用添加页码
- **2026-01-12**：添加排序规则说明（prefix 参与、大小写不敏感）
- **2026-01-12**：添加页码处理函数 `append-pages`
- **2026-01-12**：完善边界情况文档
