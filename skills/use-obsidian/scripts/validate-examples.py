#!/usr/bin/env python3
"""Validate use-obsidian Markdown examples against the installed obsidian CLI."""

from __future__ import annotations

import pathlib
import re
import shlex
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]


def obsidian_commands() -> set[str]:
    if not shutil.which("obsidian"):
        raise RuntimeError("obsidian CLI not found on PATH")

    help_text = subprocess.check_output(["obsidian", "help"], text=True)
    commands: set[str] = set()
    for line in help_text.splitlines():
        match = re.match(r"^  ([a-z][a-z0-9:_-]+)\s{2,}", line)
        if match:
            commands.add(match.group(1))
    return commands


def markdown_example_lines() -> list[tuple[pathlib.Path, int, str]]:
    lines: list[tuple[pathlib.Path, int, str]] = []
    for path in ROOT.rglob("*.md"):
        in_code = False
        for line_number, line in enumerate(path.read_text().splitlines(), 1):
            if line.startswith("```"):
                in_code = not in_code
                continue
            if in_code and line.strip().startswith("obsidian "):
                lines.append((path, line_number, line))
    return lines


def command_from_example(line: str) -> str:
    parts = shlex.split(line, comments=True)
    if len(parts) < 2 or parts[0] != "obsidian":
        raise ValueError("not an obsidian command")

    candidate = parts[1]
    if "=" in candidate:
        if len(parts) < 3:
            raise ValueError("vault prefix without command")
        candidate = parts[2]
    return candidate


def referenced_files() -> list[tuple[pathlib.Path, str]]:
    refs: list[tuple[pathlib.Path, str]] = []
    for path in ROOT.rglob("*.md"):
        for match in re.finditer(r"`(references/[^`]+)`", path.read_text()):
            refs.append((path, match.group(1)))
    return refs


def main() -> int:
    commands = obsidian_commands()
    failures: list[str] = []

    for path, line_number, line in markdown_example_lines():
        try:
            command = command_from_example(line)
        except ValueError as error:
            failures.append(f"{path}:{line_number}: {error}: {line}")
            continue

        tokens = shlex.split(line, comments=True)
        dash_flags = [token for token in tokens if token.startswith("--")]
        if dash_flags:
            failures.append(f"{path}:{line_number}: GNU-style flags are invalid: {', '.join(dash_flags)}")
        if command not in commands:
            failures.append(f"{path}:{line_number}: unknown command {command!r}: {line}")

    for path, ref in referenced_files():
        if not (ROOT / ref).exists():
            failures.append(f"{path}: broken reference {ref}")

    if failures:
        print("Validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("Validated obsidian examples: commands exist, no GNU-style flags, references resolve")
    return 0


if __name__ == "__main__":
    sys.exit(main())
