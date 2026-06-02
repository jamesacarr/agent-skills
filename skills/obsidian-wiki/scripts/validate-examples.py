#!/usr/bin/env python3
"""Validate obsidian-wiki examples and references."""

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


def obsidian_example_lines() -> list[tuple[pathlib.Path, int, str]]:
    examples: list[tuple[pathlib.Path, int, str]] = []
    for path in ROOT.rglob("*.md"):
        in_code = False
        for line_number, line in enumerate(path.read_text().splitlines(), 1):
            if line.startswith("```"):
                in_code = not in_code
                continue
            if in_code and line.strip().startswith("obsidian "):
                examples.append((path, line_number, line))
    return examples


def command_from_example(line: str) -> tuple[str, list[str]]:
    parts = shlex.split(line, comments=True)
    if len(parts) < 2 or parts[0] != "obsidian":
        raise ValueError("not an obsidian command")

    command = parts[1]
    if "=" in command:
        if len(parts) < 3:
            raise ValueError("vault prefix without command")
        command = parts[2]
    return command, parts


def referenced_files() -> list[tuple[pathlib.Path, str]]:
    refs: list[tuple[pathlib.Path, str]] = []
    for path in ROOT.rglob("*.md"):
        for match in re.finditer(r"`((?:references|workflows)/[^`]+)`", path.read_text()):
            refs.append((path, match.group(1)))
    return refs


def main() -> int:
    commands = obsidian_commands()
    failures: list[str] = []
    all_text = "\n".join(path.read_text() for path in ROOT.rglob("*.md"))

    if "\u2014" in all_text:
        failures.append("Use spaced hyphens instead of em dash characters")

    for path, line_number, line in obsidian_example_lines():
        try:
            command, parts = command_from_example(line)
        except ValueError as error:
            failures.append(f"{path}:{line_number}: {error}: {line}")
            continue

        dash_flags = [part for part in parts if part.startswith("--")]
        if dash_flags:
            failures.append(f"{path}:{line_number}: GNU-style flags are invalid for obsidian CLI: {', '.join(dash_flags)}")
        if command not in commands:
            failures.append(f"{path}:{line_number}: unknown obsidian command {command!r}: {line}")
        if not any(part == "vault=wiki" for part in parts[1:]):
            failures.append(f"{path}:{line_number}: wiki command missing vault=wiki: {line}")

    for path, ref in referenced_files():
        if not (ROOT / ref).exists():
            failures.append(f"{path}: broken reference {ref}")

    if failures:
        print("Validation failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("Validated obsidian-wiki examples: commands exist, vault prefix present, no GNU-style flags, references resolve")
    return 0


if __name__ == "__main__":
    sys.exit(main())
