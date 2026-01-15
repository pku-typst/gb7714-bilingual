// GB/T 7714 双语参考文献示例 - 顺序编码制
// 编译：typst compile example.typ --font-path fonts
// 指定版本：typst compile example.typ --font-path fonts --input version=2015

#import "lib.typ": gb7714-bibliography, init-gb7714, multicite

// 从命令行获取版本和风格
#let version = sys.inputs.at("version", default: "2025")
#let style = sys.inputs.at("style", default: "numeric")

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

// 使用指定版本的顺序编码制
#show: init-gb7714.with("/example.bib", style: "numeric", version: version)

#align(center)[
  #text(size: 18pt, weight: "bold")[GB/T 7714—#version 顺序编码制示例]
  #v(0.5em)
  #text(size: 12pt, fill: gray)[gb7714-bilingual Typst 库]
]

#v(1em)

= 引言

随着科学研究的不断深入，规范的参考文献著录变得尤为重要。我国于 2015 年发布了 GB/T 7714—2015《信息与文献 参考文献著录规则》@gb7714，并于 2025 年进行了修订。本文档展示了使用 gb7714-bilingual 库进行参考文献管理的效果。

= 文献引用示例

== 期刊文章

科技论文写作是科研工作的重要组成部分。王晓华等@wang2010guide 对中文摘要的写作要点进行了系统分析。在国际期刊方面，Smith 等@smith2020climate 发表了关于气候变化的重要研究成果。

当需要同时引用多篇文献时，可以使用 `multicite` 函数将引用合并为连续编号#multicite("wang2010guide", "smith2020climate", "kopka2004guide")。也可以在合并引用中添加页码#multicite((key: "wang2010guide", supplement: [53]), "smith2020climate", (key: "kopka2004guide", supplement: [Ch. 5]))。

== 专著与学位论文

在学术写作中，专著是重要的参考来源。刘明和李华@liu2015method 系统论述了科学研究方法论，而 Kopka 和 Daly@kopka2004guide 的 LaTeX 指南则是排版领域的经典著作。de Gaulle@gaulle1970memoirs 的回忆录记录了二战历史，Gates 等@gates2021life 则讨论了气候问题。

学位论文同样是重要的学术资源。张伟@zhang2018thesis 在其博士论文中深入探讨了深度学习在自然语言处理中的应用。

== 姓名特殊格式示例

本库正确处理西文姓名中的前缀（如 van, de）和后缀（如 Jr., III）。van Beethoven 和 Mozart@beethoven2020music 探讨了音乐表达的本质，King Jr.@king1963dream 的经典演讲被广泛研究。

连字符名的处理也符合标准：2015 版展开为空格分隔（J P），2025 版保留连字符（J-P）。Sartre@sartre1946existentialism 的存在主义思想影响深远。

== 会议论文与报告

学术会议是知识交流的重要平台。Jones@jones2019conference 在 ACL 2019 上发表了关于文本分类的研究成果。

技术报告则提供了更详尽的研究内容。中国科学院@report2022 发布的人工智能发展报告对行业发展具有重要参考价值。

== 在线资源

随着互联网的普及，在线文献成为重要的信息来源。Typst 官方文档@webpage2024 提供了完整的使用指南，Typst 0.10 发布公告@webpage_with_date 展示了带发布日期的网页格式。预印本平台也成为学术交流的重要渠道，Brown 和 Smith@online_article2023 在 arXiv 上发表了大语言模型综述。

== 专利与标准

专利文献记录了技术创新成果。李四和王五@patent2020 申请的图像识别专利展示了深度学习的应用。标准文献则为行业提供规范指导@gb7714。

== 引用形式与页码

本库支持多种引用形式和带页码引用。

*上标与非上标共存：*
- 上标形式（默认）：孔乙己提到@smith2020climate 的重要发现
- 非上标形式：另见#cite(<smith2020climate>, form: "prose")的详细分析
- 仅作者：研究由#cite(<smith2020climate>, form: "author")完成
- 仅年份：该研究发表于#cite(<smith2020climate>, form: "year")年

*带页码引用：*
- 初次引用并指定页码：关于方法论的讨论见@liu2015method[第 3 章]
- 再次引用不同页码：具体实验步骤见@liu2015method[126--129]
- 非上标带页码：详见#cite(<kopka2004guide>, form: "prose", supplement: [第 5.2 节])

= 结论

本文档展示了 gb7714-bilingual 库对各类文献的支持，包括期刊文章、专著、学位论文、会议论文、报告、网页、专利和标准等。该库完整实现了 GB/T 7714—2025 的著录规则，支持中英文文献的自动识别和格式化。

#gb7714-bibliography()
