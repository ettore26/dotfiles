#!/usr/bin/env bash

# Wrapper around `bws` that reads a non-standard `project_id` key from the
# profile section of the bws config file. bws itself ignores the extra key.
#
#   [profiles.wm]
#   server-base = "https://vault.bitwarden.com/identity"
#   project_id  = "23fa4a80-68de-4b98-94be-b482000faf72"
#
# With `bws -p wm`, the project id is injected into the underlying command.

PROFILE=""
CONFIG_FILE="${BWS_CONFIG_FILE:-$HOME/.config/bws/config}"
PASSTHRU_ARGS=()

# 1. Sniff --profile/--config-file while preserving every arg for bws itself.
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--profile)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: Argument required for $1 flag." >&2
                exit 1
            fi
            PROFILE="$2"
            PASSTHRU_ARGS+=("$1" "$2")
            shift 2
            ;;
        --profile=*)
            PROFILE="${1#*=}"
            PASSTHRU_ARGS+=("$1")
            shift
            ;;
        -f|--config-file)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: Argument required for $1 flag." >&2
                exit 1
            fi
            CONFIG_FILE="$2"
            PASSTHRU_ARGS+=("$1" "$2")
            shift 2
            ;;
        --config-file=*)
            CONFIG_FILE="${1#*=}"
            PASSTHRU_ARGS+=("$1")
            shift
            ;;
        *)
            PASSTHRU_ARGS+=("$1")
            shift
            ;;
    esac
done

# 2. Pull `project_id` out of the [profiles.<name>] section of the TOML config.
get_project_id() {
    local file="$1" profile="$2"
    [[ -r "$file" ]] || return 0
    awk -v want="[profiles.$profile]" '
        { line = $0; sub(/^[[:space:]]+/, "", line); sub(/[[:space:]]+$/, "", line) }
        line ~ /^#/ { next }
        line ~ /^\[/ {
            sub(/[[:space:]]*#.*$/, "", line)
            in_section = (line == want)
            next
        }
        in_section && line ~ /^project_id[[:space:]]*=/ {
            sub(/^project_id[[:space:]]*=[[:space:]]*/, "", line)
            if (match(line, /^"[^"]*"/) || match(line, /^'\''[^'\'']*'\''/))
                line = substr(line, 2, RLENGTH - 2)
            else
                sub(/[[:space:]]*#.*$/, "", line)
            print line
            exit
        }
    ' "$file"
}

# 3. Inject the project id into whichever subcommand is being run.
if [[ -n "$PROFILE" ]]; then
    PROJECT_ID=$(get_project_id "$CONFIG_FILE" "$PROFILE")

    if [[ -n "$PROJECT_ID" ]]; then
        ARGS_STR=" ${PASSTHRU_ARGS[*]} "
        if [[ "$ARGS_STR" == *" run "* ]]; then
            # `bws run` takes an explicit --project-id flag.
            if [[ "$ARGS_STR" != *" --project-id "* ]]; then
                INJECTED=()
                DONE=0
                for arg in "${PASSTHRU_ARGS[@]}"; do
                    INJECTED+=("$arg")
                    if [[ $DONE -eq 0 && "$arg" == "run" ]]; then
                        INJECTED+=("--project-id" "$PROJECT_ID")
                        DONE=1
                    fi
                done
                PASSTHRU_ARGS=("${INJECTED[@]}")
            fi
        elif [[ "$ARGS_STR" == *" secret list "* || "$ARGS_STR" == *" project get "* ]]; then
            # Both take the project id as a positional argument.
            PASSTHRU_ARGS+=("$PROJECT_ID")
        else
            # Default behavior: list the profile's secrets.
            PASSTHRU_ARGS=("secret" "list" "$PROJECT_ID" "${PASSTHRU_ARGS[@]}")
        fi
    fi
fi

# 4. Execute the real bws binary with preserved spacing.
exec bws "${PASSTHRU_ARGS[@]}"
