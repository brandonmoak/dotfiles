#!/usr/bin/env python3
"""Helper for the `ep` shell function.

The shell function owns the user-facing CLI because it needs to export into the
current shell. This helper handles pack discovery, SOPS decryption, inheritance,
and safe shell code generation.
"""

import json
import os
import shlex
import subprocess
import sys
from pathlib import Path


EP_HOME = Path(os.environ.get("EP_HOME", "~/.config/envpacks")).expanduser()
PACK_DIR = EP_HOME / "packs"
STATE_DIR = Path(os.environ.get("XDG_CACHE_HOME", "~/.cache")).expanduser() / "envpacks"
STATE_FILE = Path(os.environ.get("EP_STATE_FILE", str(STATE_DIR / "state.json"))).expanduser()
AGE_KEY_FILE = Path(os.environ.get("SOPS_AGE_KEY_FILE", "~/.config/sops/age/keys.txt")).expanduser()


class EpError(Exception):
    pass


def die(message, code=1):
    print(f"ep: {message}", file=sys.stderr)
    raise SystemExit(code)


def validate_pack_name(name):
    if not name:
        raise EpError("pack name is required")
    path = Path(name)
    if path.is_absolute() or ".." in path.parts:
        raise EpError(f"invalid pack name: {name}")
    allowed = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._/-")
    if any(ch not in allowed for ch in name):
        raise EpError(f"invalid pack name: {name}")


def validate_env_name(name):
    if not name:
        raise EpError("empty env key")
    first = name[0]
    rest = name[1:]
    if first not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_":
        raise EpError(f"invalid env key: {name}")
    allowed = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
    if any(ch not in allowed for ch in rest):
        raise EpError(f"invalid env key: {name}")


def pack_path(name):
    validate_pack_name(name)
    base = PACK_DIR / name
    candidates = []
    if base.suffix in (".yaml", ".yml"):
        candidates.append(base)
    else:
        candidates.extend([base.with_suffix(".yaml"), base.with_suffix(".yml")])
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise EpError(f"pack not found: {name}")


def pack_name_from_path(path):
    rel = path.relative_to(PACK_DIR)
    if rel.suffix in (".yaml", ".yml"):
        rel = rel.with_suffix("")
    return rel.as_posix()


def list_pack_names():
    if not PACK_DIR.exists():
        return []
    names = []
    for suffix in ("*.yaml", "*.yml"):
        for path in PACK_DIR.rglob(suffix):
            if any(part.startswith(".") for part in path.relative_to(PACK_DIR).parts):
                continue
            names.append(pack_name_from_path(path))
    return sorted(set(names))


def decrypt_pack(name):
    path = pack_path(name)
    env = os.environ.copy()
    env.setdefault("SOPS_AGE_KEY_FILE", str(AGE_KEY_FILE))
    try:
        result = subprocess.run(
            ["sops", "-d", str(path)],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
        )
    except FileNotFoundError as exc:
        raise EpError("sops is not installed or not on PATH") from exc
    except subprocess.CalledProcessError as exc:
        stderr = exc.stderr.strip()
        detail = f": {stderr}" if stderr else ""
        raise EpError(f"failed to decrypt {name}{detail}") from exc
    return parse_pack(result.stdout, name)


def unquote_scalar(value):
    value = value.strip()
    if not value:
        return ""
    if (value[0], value[-1:]) in (("'", "'"), ('"', '"')):
        return value[1:-1]
    return value


def parse_inline_list(value):
    value = value.strip()
    if not (value.startswith("[") and value.endswith("]")):
        return [unquote_scalar(value)] if value else []
    inner = value[1:-1].strip()
    if not inner:
        return []
    return [unquote_scalar(item.strip()) for item in inner.split(",") if item.strip()]


def parse_pack(text, fallback_name):
    pack = {"name": fallback_name, "description": "", "extends": [], "env": {}}
    section = None

    for raw_line in text.splitlines():
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue
        indent = len(raw_line) - len(raw_line.lstrip(" "))
        line = raw_line.strip()

        if indent == 0:
            if ":" not in line:
                raise EpError(f"invalid top-level line in {fallback_name}: {line}")
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip()
            section = key

            if key in ("name", "description"):
                pack[key] = unquote_scalar(value)
            elif key == "extends":
                pack["extends"] = parse_inline_list(value)
            elif key == "env":
                pack["env"] = {}
            else:
                # Ignore unknown metadata so the schema can grow later.
                section = None
            continue

        if section == "extends":
            if not line.startswith("- "):
                raise EpError(f"invalid extends entry in {fallback_name}: {line}")
            pack["extends"].append(unquote_scalar(line[2:]))
        elif section == "env":
            if ":" not in line:
                raise EpError(f"invalid env entry in {fallback_name}: {line}")
            key, value = line.split(":", 1)
            key = key.strip()
            validate_env_name(key)
            pack["env"][key] = unquote_scalar(value)

    if isinstance(pack["extends"], str):
        pack["extends"] = [pack["extends"]]
    pack["extends"] = [parent for parent in pack["extends"] if parent]
    return pack


def resolve_pack(name, seen=None):
    validate_pack_name(name)
    seen = seen or []
    if name in seen:
        raise EpError(f"circular extends chain: {' -> '.join(seen + [name])}")

    pack = decrypt_pack(name)
    env = {}
    chain = []

    for parent in pack["extends"]:
        resolved_parent = resolve_pack(parent, seen + [name])
        env.update(resolved_parent["env"])
        chain.extend(resolved_parent["chain"])

    env.update(pack["env"])
    chain.append(pack["name"] or name)
    return {
        "name": pack["name"] or name,
        "description": pack["description"],
        "extends": pack["extends"],
        "env": env,
        "chain": chain,
    }


def shell_quote(value):
    return shlex.quote("" if value is None else str(value))


def shell_export(name, value):
    return f"export {name}={shell_quote(value)}"


def load_pack(name):
    resolved = resolve_pack(name)
    previous = {}
    for key in resolved["env"]:
        if key in os.environ:
            previous[key] = {"set": True, "value": os.environ[key]}
        else:
            previous[key] = {"set": False, "value": ""}

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(
        json.dumps(
            {
                "active": resolved["name"],
                "requested": name,
                "vars": sorted(resolved["env"].keys()),
                "previous": previous,
            },
            indent=2,
            sort_keys=True,
        )
    )

    print(shell_export("ENVPACK_ACTIVE", resolved["name"]))
    for key, value in resolved["env"].items():
        print(shell_export(key, value))


def unload_pack():
    if not STATE_FILE.exists():
        print("unset ENVPACK_ACTIVE")
        return

    state = json.loads(STATE_FILE.read_text())
    for key in state.get("vars", []):
        print(f"unset {key}")
    print("unset ENVPACK_ACTIVE")
    STATE_FILE.unlink()


def show_pack(name):
    resolved = resolve_pack(name)
    print(f"name: {resolved['name']}")
    if resolved["description"]:
        print(f"description: {resolved['description']}")
    if resolved["chain"]:
        print("chain:")
        for item in resolved["chain"]:
            print(f"  - {item}")
    print("env:")
    for key in sorted(resolved["env"]):
        print(f"  - {key}")


def status():
    active = os.environ.get("ENVPACK_ACTIVE")
    if not active:
        print("No env pack loaded.")
        return
    print(f"Active env pack: {active}")
    if STATE_FILE.exists():
        state = json.loads(STATE_FILE.read_text())
        vars_ = state.get("vars", [])
        if vars_:
            print("Variables:")
            for key in vars_:
                print(f"  - {key}")


def main(argv):
    if len(argv) < 2:
        die("helper subcommand required")
    command = argv[1]

    try:
        if command == "list":
            for name in list_pack_names():
                print(name)
        elif command == "complete-packs":
            for name in list_pack_names():
                print(name)
        elif command == "show":
            if len(argv) != 3:
                die("usage: ep show <pack>")
            show_pack(argv[2])
        elif command == "load":
            if len(argv) != 3:
                die("usage: ep load <pack>")
            load_pack(argv[2])
        elif command == "unload":
            unload_pack()
        elif command == "status":
            status()
        else:
            die(f"unknown helper subcommand: {command}")
    except EpError as exc:
        die(str(exc))


if __name__ == "__main__":
    main(sys.argv)
