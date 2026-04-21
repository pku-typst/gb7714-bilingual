set shell := ["bash", "-euo", "pipefail", "-c"]

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #

# Typst — https://typst.app
typst := require("typst")

# tytanic — https://github.com/typst-community/tytanic
tt := require("tt")

# typstyle — https://github.com/Enter-tainer/typstyle
typstyle := require("typstyle")

# ---------------------------------------------------------------------------- #
#                                  CONSTANTS                                   #
# ---------------------------------------------------------------------------- #

FONT_PATH := "fonts"
BUILD_DIR := "build"

# ---------------------------------------------------------------------------- #
#                                   DEFAULT                                    #
# ---------------------------------------------------------------------------- #

# Show available commands
default:
    @just --list --unsorted

# ---------------------------------------------------------------------------- #
#                                   RECIPES                                    #
# ---------------------------------------------------------------------------- #

# Compile all four example PDFs (2015/2025 × numeric/author-date)
[group("build")]
build:
    mkdir -p {{ BUILD_DIR }}
    {{ typst }} compile example.typ --font-path {{ FONT_PATH }} --input version=2015 {{ BUILD_DIR }}/example-2015-numeric.pdf
    {{ typst }} compile example.typ --font-path {{ FONT_PATH }} --input version=2025 {{ BUILD_DIR }}/example-2025-numeric.pdf
    {{ typst }} compile example-authordate.typ --font-path {{ FONT_PATH }} --input version=2015 {{ BUILD_DIR }}/example-2015-authordate.pdf
    {{ typst }} compile example-authordate.typ --font-path {{ FONT_PATH }} --input version=2025 {{ BUILD_DIR }}/example-2025-authordate.pdf
alias b := build

# Remove generated build and test artifacts
[group("build")]
clean:
    rm -rf {{ BUILD_DIR }}
    find tests -type d \( -name diff -o -name out \) -exec rm -rf {} +

# ---------------------------------------------------------------------------- #
#                                    TESTS                                    #
# ---------------------------------------------------------------------------- #

# Run the tytanic test suite
[group("tests")]
test *filter:
    {{ tt }} run --font-path {{ FONT_PATH }} {{ filter }}
alias t := test

# Regenerate reference snapshots for persistent tests
[group("tests")]
test-update *filter:
    {{ tt }} update --font-path {{ FONT_PATH }} {{ filter }}
alias tu := test-update

# ---------------------------------------------------------------------------- #
#                                    CHECKS                                    #
# ---------------------------------------------------------------------------- #

# Check Typst formatting (read-only)
[group("checks")]
typstyle-check:
    {{ typstyle }} --check src lib.typ example.typ example-authordate.typ tests
alias tc := typstyle-check

# Apply Typst formatting in-place
[group("checks")]
typstyle-write:
    {{ typstyle }} -i src lib.typ example.typ example-authordate.typ tests
alias tw := typstyle-write

# Run pre-commit (prefer prek when available, fallback to pre-commit).
# Uses the global bash shell; if prek is present we always run prek and let
# any failure propagate — only the absence of prek falls back to pre-commit.
# Works on any platform that has bash (macOS / Linux / Windows + Git Bash).
[group("checks")]
pre-commit:
    if command -v prek > /dev/null 2>&1; then \
      prek run --all-files; \
    else \
      pre-commit run --all-files; \
    fi

# Run every check: tests + formatter + pre-commit hooks
[group("checks")]
@full-check:
    just _run-with-status typstyle-check
    just _run-with-status test
    just _run-with-status pre-commit
    echo ""
    echo -e '{{ GREEN }}All checks passed!{{ NORMAL }}'
alias fc := full-check

# Auto-apply all formatters / fixers
[group("checks")]
@full-write:
    just _run-with-status typstyle-write
    echo ""
    echo -e '{{ GREEN }}All fixes applied!{{ NORMAL }}'
alias fw := full-write

# ---------------------------------------------------------------------------- #
#                              INTERNAL HELPERS                                #
# ---------------------------------------------------------------------------- #

@_run-with-status recipe *args:
    echo ""
    echo -e '{{ CYAN }}→ Running {{ recipe }}...{{ NORMAL }}'
    just {{ recipe }} {{ args }}
    echo -e '{{ GREEN }}✓ {{ recipe }} completed{{ NORMAL }}'
