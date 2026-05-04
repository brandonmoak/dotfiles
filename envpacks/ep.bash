# shell wrapper for encrypted environment packs

_ep_home() {
    echo "${EP_HOME:-$HOME/.config/envpacks}"
}

_ep_dir() {
    cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd
}

_ep_helper() {
    local helper="$(_ep_dir)/ep.py"
    if [[ ! -f "$helper" ]]; then
        echo "ep: helper not found: $helper" >&2
        return 1
    fi
    EP_STATE_FILE="$(_ep_state_file)" SOPS_AGE_KEY_FILE="$(_ep_age_key_file)" python3 "$helper" "$@"
}

_ep_state_file() {
    echo "${XDG_CACHE_HOME:-$HOME/.cache}/envpacks/state-$$.json"
}

_ep_age_key_file() {
    echo "$HOME/.config/sops/age/keys.txt"
}

_ep_validate_pack_name() {
    local name="$1"
    if [[ -z "$name" || "$name" == /* || "$name" == *".."* || "$name" =~ [^a-zA-Z0-9._/-] ]]; then
        echo "ep: invalid pack name: $name" >&2
        return 1
    fi
}

_ep_pack_path() {
    local name="$1"
    local home="$(_ep_home)"
    _ep_validate_pack_name "$name" || return 1
    if [[ "$name" == *.yaml || "$name" == *.yml ]]; then
        echo "$home/packs/$name"
    else
        echo "$home/packs/$name.yaml"
    fi
}

_ep_create_pack_template() {
    local pack="$1"
    local path="$2"

    SOPS_CONFIG="$(_ep_home)/.sops.yaml" SOPS_AGE_KEY_FILE="$(_ep_age_key_file)" sops --encrypt --filename-override "$path" /dev/stdin > "$path" <<EOF
name: $pack
description:
env:
  EXAMPLE_KEY: replace-me
EOF
}

_ep_usage() {
    cat <<'EOF'
Usage: ep <command> [args]

Commands:
  init           create local directories, age key, and sops config
  list           list available env packs
  show <pack>    show inheritance and env variable names
  edit <pack>    create or edit an encrypted env pack
  load <pack>    export env vars from an env pack
  off            unset env variables loaded by the active env pack
  status         show the active env pack
  help           show this help
EOF
}

_ep_init() {
    local home="$(_ep_home)"
    local age_dir="$HOME/.config/sops/age"
    local age_key="$age_dir/keys.txt"
    local sops_config="$home/.sops.yaml"

    mkdir -p "$home/packs" "$home/files" "$age_dir" "${XDG_CACHE_HOME:-$HOME/.cache}/envpacks"
    chmod 700 "$home" "$home/packs" "$home/files" "$age_dir" 2>/dev/null

    if ! command -v sops >/dev/null 2>&1; then
        echo "ep: sops is not installed or not on PATH" >&2
        return 1
    fi
    if ! command -v age-keygen >/dev/null 2>&1; then
        echo "ep: age-keygen is not on PATH; install the age package first" >&2
        return 1
    fi

    if [[ ! -f "$age_key" ]]; then
        age-keygen -o "$age_key" || return 1
        chmod 600 "$age_key" 2>/dev/null
    fi

    local recipient
    recipient="$(sed -n 's/^# public key: //p' "$age_key" | sed -n '1p')"
    if [[ -z "$recipient" ]]; then
        echo "ep: could not read age public key from $age_key" >&2
        return 1
    fi

    if [[ ! -f "$sops_config" ]]; then
        cat > "$sops_config" <<EOF
creation_rules:
  - path_regex: packs/.*\\.ya?ml$
    age: $recipient
EOF
        chmod 600 "$sops_config" 2>/dev/null
    fi

    echo "ep: initialized $home"
}

ep() {
    local command="$1"
    shift || true

    case "$command" in
        init)
            _ep_init "$@"
            ;;
        list|ls)
            _ep_helper list
            ;;
        show)
            [[ $# -eq 1 ]] || { echo "Usage: ep show <pack>" >&2; return 1; }
            _ep_helper show "$1"
            ;;
        edit)
            [[ $# -eq 1 ]] || { echo "Usage: ep edit <pack>" >&2; return 1; }
            local path
            path="$(_ep_pack_path "$1")" || return 1
            local home="$(_ep_home)"
            if [[ ! -f "$home/.sops.yaml" ]]; then
                echo "ep: $home/.sops.yaml not found; run 'ep init' first" >&2
                return 1
            fi
            mkdir -p "$(dirname "$path")"
            if [[ ! -f "$path" ]]; then
                _ep_create_pack_template "$1" "$path" || return 1
            fi
            SOPS_CONFIG="$home/.sops.yaml" SOPS_AGE_KEY_FILE="$(_ep_age_key_file)" sops "$path"
            ;;
        load)
            [[ $# -eq 1 ]] || { echo "Usage: ep load <pack>" >&2; return 1; }
            if [[ -n "${ENVPACK_ACTIVE-}" ]]; then
                echo "ep: '$ENVPACK_ACTIVE' is already loaded; run 'ep off' first" >&2
                return 1
            fi
            local output
            output="$(_ep_helper load "$1")" || return 1
            eval "$output"
            ;;
        off|unload)
            local output
            output="$(_ep_helper unload)" || return 1
            eval "$output"
            ;;
        status)
            _ep_helper status
            ;;
        help|-h|--help|"")
            _ep_usage
            ;;
        *)
            echo "ep: unknown command: $command" >&2
            _ep_usage >&2
            return 1
            ;;
    esac
}

_ep_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local sub="${COMP_WORDS[1]}"
    local commands="init list show edit load off status help"

    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return 0
    fi

    case "$sub" in
        show|edit|load)
            COMPREPLY=( $(compgen -W "$(_ep_helper complete-packs 2>/dev/null)" -- "$cur") )
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}
complete -F _ep_complete ep
