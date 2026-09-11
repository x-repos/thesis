#!/usr/bin/env bash
# Build the thesis PDF and remove all LaTeX intermediate files.
# Usage: ./compile.sh [file.tex]   (default: dissertation.tex)
set -u

cd "$(dirname "$0")"

TEX="${1:-dissertation.tex}"
NAME="$(basename "$TEX" .tex)"

if [ ! -f "$TEX" ]; then
    echo "No such file: $TEX" >&2
    exit 1
fi

# Build in a temporary folder (not a dot-folder: TeX refuses to write there).
TMP="$(mktemp -d ./build-tmp-XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

if latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir="$TMP" "$TEX" >/dev/null 2>&1; then
    mv -f "$TMP/$NAME.pdf" "./$NAME.pdf"
    PAGES="$(grep -o 'Output written.*(\([0-9]*\) pages' "$TMP/$NAME.log" | grep -o '[0-9]* pages')"
    echo "Built $NAME.pdf ($PAGES)"
else
    echo "Build failed. Errors:" >&2
    grep -A4 '^!' "$TMP/$NAME.log" >&2 || tail -20 "$TMP/$NAME.log" >&2
    exit 1
fi
