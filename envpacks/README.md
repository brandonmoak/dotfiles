# Env Packs

`ep` is a small shell helper for loading encrypted, machine-local environment
variable packs.

The tooling lives in this dotfiles repo. Real secrets live outside the repo in:

```text
~/.config/envpacks/
  .sops.yaml
  packs/
  files/
```

## Setup

Install `sops` and `age`, then initialize the local store. On macOS, the
`age` Homebrew package provides both `age` and `age-keygen`.

```bash
ep init
```

`ep init` creates the local directories, generates an age identity if needed,
and writes a local `.sops.yaml` that encrypts pack files for this machine.

## Commands

```bash
ep list
ep show <pack>
ep edit <pack>
ep load <pack>
ep status
ep off
```

`ep load` exports variables into the current shell. `ep off` unsets the
variables owned by the active pack.

## Pack Schema

Packs are encrypted YAML files under `~/.config/envpacks/packs`. A pack can
inherit from another pack with `extends`; parent values load first and child
values override them.

```yaml
name: cloud/gcp-project-a
description: GCP credentials for project A
extends: cloud/gcp-base
env:
  CLOUDSDK_CORE_PROJECT: project-a
  GOOGLE_APPLICATION_CREDENTIALS: ~/.config/envpacks/files/gcp-project-a.json
```

Use simple scalar YAML values in v1. Advanced YAML features like anchors,
multi-line strings, and nested structures are intentionally unsupported.

## Prompt

When a pack is active, the prompt includes `ep:<pack>` in the existing prefix:

```text
[main ep:cloud/gcp-project-a venv] host:repo$
```
