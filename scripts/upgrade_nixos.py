#!/usr/bin/env python3

from datetime import datetime, timedelta
from pathlib import Path
import re
import subprocess
import sys

config_path = Path(sys.argv[1])


with config_path.open(encoding="utf8") as f:
    contents = f.read()


lines = contents.splitlines()
for i, line in enumerate(lines):
    if re.match(r'^\s*owner = "nixos";$', line):
        owner_lineno = i
        break

assert re.match(r'^\s*repo = "nixpkgs";$', lines[owner_lineno + 1])
rev_regex = r'^\s*rev = "(\w+)";  # ((\d{4})-(\d{2})-(\d{2})) nixos-unstable branch$'
rev_match = re.match(rev_regex, lines[owner_lineno + 2])
assert rev_match
rev, date_s, year_s, month_s, day_s = rev_match.groups()

sha_match = re.match(r"^\s*sha256 = (\S+);$", lines[owner_lineno + 3])
assert sha_match
sha256 = sha_match.groups()[0]

nixpkgs_path = Path("~/repositories/github.com/NixOS/nixpkgs--nixos-unstable").expanduser()

subprocess.run(["git", "fetch"], cwd=nixpkgs_path, check=True)
subprocess.run(["git", "merge", "--ff-only"], cwd=nixpkgs_path, check=True)

before = datetime.now() - timedelta(days=3)
print(before)

result = subprocess.run(
    ["git", "rev-list", "-n", "1", f"--before={before}", "nixos-unstable"],
    cwd=nixpkgs_path,
    check=True,
    capture_output=True,
    text=True,
)

new_rev = result.stdout.strip()

new_commit_date_s = subprocess.run(
    ["git", "show", "-s", "--format=%ci", new_rev], cwd=nixpkgs_path, capture_output=True, text=True, check=True
).stdout.strip()

new_date = datetime.strptime(new_commit_date_s, "%Y-%m-%d %H:%M:%S %z")
print(new_date)


new_sha = subprocess.run(
    ["nix-prefetch-url", "--unpack", f"https://github.com/nixos/nixpkgs/archive/{new_rev}.tar.gz"],
    capture_output=True,
    text=True,
    check=True,
).stdout.strip()


new_contents = (
    contents.replace(rev, new_rev).replace(sha256, f'"{new_sha}"').replace(date_s, new_date.strftime("%Y-%m-%d"))
)


with config_path.open("w", encoding="utf8") as f:
    f.write(new_contents)
