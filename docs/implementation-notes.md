# GB/T 7714 实现说明

本文档记录 `gb7714-bilingual` 库的实现细节、CSL 规范对照和边界情况处理。

## 目录

1. [CSL 规范对照](#1-csl-规范对照)
2. [版本差异](#2-版本差异)
3. [作者格式化规则](#3-作者格式化规则)
4. [排序规则](#4-排序规则)
5. [边界情况处理](#5-边界情况处理)
6. [公共函数](#6-公共函数)
7. [测试命令](#7-测试命令)

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

## 5. 边界情况处理

### 5.1 作者相关

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

### 5.2 出版信息缺失

#### address 有值，publisher 为空

- **预期**：`北京，2015.` 而非 `北京：，2015.`

#### address 为空，publisher 有值

- **预期**：`中国标准出版社，2015.`

#### year 为空

- **预期**：`北京：出版社.` 而非 `北京：出版社，.`

### 5.3 期刊文章

#### journal 为空

- **预期**：不以逗号开头

#### volume/number/pages 为空

- **预期**：智能省略对应部分及其前导标点

### 5.4 会议论文（2015）

#### address 有值，publisher 为空

- **预期**：`Florence, Italy, 2019: 100–110`（不产生双冒号）

### 5.5 标准文献

#### 2025 版本

- **预期**：不显示作者，标准号在最前

### 5.6 连续引用压缩

- **规则**：2 个及以上连续编号压缩为范围
- **示例**：`[1,2,3,5]` → `[1-3,5]`

---

## 6. 公共函数

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

## 7. 测试命令

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

- **2026-01-12**：添加排序规则说明（prefix 参与、大小写不敏感）
- **2026-01-12**：添加页码处理函数 `append-pages`
- **2026-01-12**：完善边界情况文档
