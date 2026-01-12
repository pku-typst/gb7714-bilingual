# Run pre-commit hooks (prefer prek, fallback to pre-commit)
[unix]
pre-commit:
  @if command -v prek > /dev/null 2>&1; then prek run --all-files; else pre-commit run --all-files; fi

[windows]
pre-commit:
  @where prek >nul 2>&1 && prek run --all-files || pre-commit run --all-files

build:
  typst compile example.typ --font-path fonts --input version=2015 build/example-2015-numeric.pdf
  typst compile example.typ --font-path fonts --input version=2025 build/example-2025-numeric.pdf
  typst compile example-authordate.typ --font-path fonts --input version=2015 build/example-2015-authordate.pdf
  typst compile example-authordate.typ --font-path fonts --input version=2025 build/example-2025-authordate.pdf
