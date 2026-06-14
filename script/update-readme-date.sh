#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readme_path="${repo_root}/README.md"
current_date="${1:-$(date +'%Y-%m-%d')}"
badge_date="${current_date//-/--}"

if [[ ! -f "${readme_path}" ]]; then
  echo "README.md not found at ${readme_path}" >&2
  exit 1
fi

python3 - "$readme_path" "$badge_date" <<'PY'
import re
import sys
from pathlib import Path

readme_path = Path(sys.argv[1])
badge_date = sys.argv[2]
content = readme_path.read_text(encoding="utf-8")
updated, replacements = re.subn(
    r"!\[Last Updated\]\(https://img\.shields\.io/badge/last%20updated-[^)]*\)",
    f"![Last Updated](https://img.shields.io/badge/last%20updated-{badge_date}-blue)",
    content,
    count=1,
)

if replacements == 0:
    raise SystemExit("Last Updated badge not found in README.md")

readme_path.write_text(updated, encoding="utf-8")
PY

grep "Last Updated" "${readme_path}"
