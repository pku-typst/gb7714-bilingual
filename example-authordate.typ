// GB/T 7714 双语参考文献示例 - 著者-出版年制
// 编译：typst compile example-authordate.typ --font-path fonts
// 指定版本：typst compile example-authordate.typ --font-path fonts --input version=2015

#import "lib.typ": gb7714-bibliography, init-gb7714, multicite

// 从命令行获取版本，默认 2025
#let version = sys.inputs.at("version", default: "2025")

#set page(margin: (x: 2.5cm, y: 2cm))
#set text(
  font: ("Times New Roman", "SimSun"),
  size: 12pt,
)
#set par(justify: true, leading: 1em, first-line-indent: (
  amount: 2em,
  all: true,
))
#set heading(numbering: "1.")

#show heading.where(level: 1): it => {
  set text(size: 16pt, weight: "bold")
  set block(spacing: 1.5em)
  it
}

#show heading.where(level: 2): it => {
  set text(size: 14pt, weight: "bold")
  set block(spacing: 1.2em)
  it
}

// 使用指定版本的著者-出版年制
#show: init-gb7714.with("/example.bib", style: "author-date", version: version)

#align(center)[
  #text(size: 18pt, weight: "bold")[GB/T 7714—#version 著者-出版年制示例]
  #v(0.5em)
  #text(size: 12pt, fill: gray)[gb7714-bilingual Typst 库]
]

#v(1em)

= 引言

著者-出版年制是人文社科领域常用的参考文献著录方式。与顺序编码制不同，著者-出版年制在正文中直接标注作者姓名和出版年份，便于读者快速了解文献来源。本文档展示了 gb7714-bilingual 库对著者-出版年制的支持。

= 文献引用示例

== 基本引用

在正文中引用文献时，作者姓名和年份会以括号形式呈现。例如，关于科技论文写作的研究@wang2010guide 提供了重要指导。国际学者的研究@smith2020climate 也具有重要参考价值。

著者-出版年制的优势在于读者可以直接看到文献的作者和年份信息，无需翻到文末查看参考文献列表。

== 同作者同年消歧

当同一作者在同一年发表多篇文献时，系统会自动添加字母后缀进行消歧。例如，Smith 等人在 2020 年发表了两篇重要文章：一篇关于气候变化@smith2020climate，另一篇关于政策分析@smith2020policy。系统会自动为这两篇文献添加 a、b 后缀。

== 多文献合并引用

使用 `multicite` 函数可以将多个引用合并在一个括号内。例如，近年来多位学者对相关领域进行了深入研究#multicite("smith2020climate", "smith2020policy", "jones2019conference")。也可以在合并引用中添加页码#multicite((key: "smith2020climate", supplement: [260]), "smith2020policy", (key: "jones2019conference", supplement: [Table 2]))。

合并引用时，同一作者的多个文献会自动归组，年份用逗号分隔；不同作者之间用分号分隔。

== 专著与学位论文

专著引用同样遵循著者-出版年制格式。刘明和李华@liu2015method 的著作系统论述了科学研究方法，而 Kopka 和 Daly @kopka2004guide 的 LaTeX 指南则是排版领域的权威参考。de Gaulle @gaulle1970memoirs 的回忆录记录了二战历史。

学位论文的引用格式与专著类似，例如张伟@zhang2018thesis 的博士论文。

== 姓名特殊格式示例

本库正确处理西文姓名中的前缀（如 van, de）和后缀（如 Jr., III）。van Beethoven 等@beethoven2020music 探讨了音乐表达的本质，King Jr. @king1963dream 的经典演讲被广泛研究。Gates 等@gates2021life 讨论了气候问题的解决方案。

连字符名的处理也符合标准：2015 版展开为空格分隔（J P），2025 版保留连字符（J-P）。Sartre @sartre1946existentialism 的存在主义思想影响深远。

== 在线资源与其他类型

在线资源@webpage2024 和预印本@online_article2023 在现代学术研究中越来越重要。专利文献@patent2020 和标准@gb7714 也是重要的参考来源。

== 引用形式与页码

本库支持多种引用形式和带页码引用。

*括号与散文形式共存：*
- 默认形式（带括号）：关于气候变化的研究@smith2020climate 具有重要意义
- 散文形式：根据#cite(<smith2020climate>, form: "prose")的研究结果
- 仅作者：#cite(<smith2020climate>, form: "author")的研究表明
- 仅年份：该成果发表于#cite(<smith2020climate>, form: "year")

*带页码引用：*
- 默认带页码：关于方法论的讨论@liu2015method[第 3 章]
- 散文形式带页码：详见#cite(<kopka2004guide>, form: "prose", supplement: [第 5.2 节])
- 多页引用：实验步骤见@liu2015method[126--129]

= 结论

著者-出版年制适合人文社科领域的学术写作。gb7714-bilingual 库完整支持 GB/T 7714—2025 的著者-出版年制规则，包括自动消歧、多文献合并、中英文自动识别等功能。

#gb7714-bibliography()
