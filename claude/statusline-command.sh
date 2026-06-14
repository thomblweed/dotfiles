#!/usr/bin/env bash
# Claude Code status line script

input=$(cat)

# ANSI color codes — Catppuccin Mocha palette
RESET="\033[0m"
GREEN="\033[38;5;150m"           # green     #a6e3a1
YELLOW="\033[38;5;229m"          # yellow    #f9e2af
RED="\033[38;5;211m"             # red       #f38ba8
DIM="\033[38;5;103m"             # overlay1  #7f849c
SALMON_LIGHT="\033[38;5;183m"    # mauve     #cba6f7 — model name
CORAL_DARK="\033[38;5;216m"      # peach     #fab387 — effort level

SEP=$(printf "${DIM}|${RESET}")

# --- Model & Effort ---
model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')

model_part=""
if [ -n "$model" ]; then
    if [ -n "$effort" ]; then
        model_part=$(printf "${SALMON_LIGHT}%s${RESET} ${CORAL_DARK}[%s]${RESET}" "$model" "$effort")
    else
        model_part=$(printf "${SALMON_LIGHT}%s${RESET}" "$model")
    fi
fi

# --- Usage (ctx + rate limits) ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

usage_part=""
if [ -n "$used_pct" ]; then
    used_int=$(printf '%.0f' "$used_pct")
    if [ "$used_int" -ge 90 ]; then ctx_color="$RED"
    elif [ "$used_int" -ge 75 ]; then ctx_color="$YELLOW"
    else ctx_color="$GREEN"
    fi
    usage_part=$(printf "${DIM}ctx:${RESET}${ctx_color}%d%%${RESET}" "$used_int")
fi
if [ -n "$five_pct" ]; then
    five_int=$(printf '%.0f' "$five_pct")
    if [ "$five_int" -ge 90 ]; then five_color="$RED"
    elif [ "$five_int" -ge 75 ]; then five_color="$YELLOW"
    else five_color="$GREEN"
    fi
    usage_part="${usage_part:+$usage_part }$(printf "${DIM}5h:${RESET}${five_color}%d%%${RESET}" "$five_int")"
fi
if [ -n "$week_pct" ]; then
    week_int=$(printf '%.0f' "$week_pct")
    if [ "$week_int" -ge 90 ]; then week_color="$RED"
    elif [ "$week_int" -ge 75 ]; then week_color="$YELLOW"
    else week_color="$GREEN"
    fi
    usage_part="${usage_part:+$usage_part }$(printf "${DIM}7d:${RESET}${week_color}%d%%${RESET}" "$week_int")"
fi

# --- CWD (always shown) ---
cwd_label=$( [ "$PWD" = "$HOME" ] && echo "~" || basename "$PWD" )
cwd_part=$(printf "${DIM}cwd:${RESET}%s" "$cwd_label")

# --- Git info ---
gb=$(git branch --show-current 2>/dev/null)
if [ -n "$gb" ]; then
    git_dir=$(git rev-parse --git-dir 2>/dev/null)
    git_part=$(printf "${DIM}gb:${RESET}%s" "$gb")
    if [[ "$git_dir" == *"/worktrees/"* ]]; then
        git_part="$git_part $(printf "${DIM}gwt:${RESET}%s" "$(basename "$git_dir")")"
    fi
else
    git_part=$(printf "${DIM}(no-git)${RESET}")
fi

# --- Context-mode stats ---
cm_part=""
stats_file=$(ls -t ~/.claude/context-mode/sessions/stats-*.json 2>/dev/null | head -1)
if [ -n "$stats_file" ]; then
    reduction=$(jq -r '.reduction_pct // empty' "$stats_file" 2>/dev/null)
    uptime_ms=$(jq -r '.uptime_ms // empty' "$stats_file" 2>/dev/null)
    if [ -n "$reduction" ] && [ -n "$uptime_ms" ]; then
        uptime_s=$((uptime_ms / 1000))
        if [ "$uptime_s" -ge 3600 ]; then
            up_str=$(printf "%dh%dm" $((uptime_s / 3600)) $(( (uptime_s % 3600) / 60 )))
        elif [ "$uptime_s" -ge 60 ]; then
            up_str=$(printf "%dm" $((uptime_s / 60)))
        else
            up_str=$(printf "%ds" $uptime_s)
        fi
        cm_part=$(printf "${DIM}cm%%:${RESET}%s ${DIM}up:${RESET}%s" "$reduction" "$up_str")
    fi
fi
[ -z "$cm_part" ] && cm_part=$(printf "${DIM}(no-ctx)${RESET}")

# --- Assemble: model | usage | cwd | git | ctx-mode ---
parts=()
[ -n "$model_part" ] && parts+=("$model_part")
[ -n "$usage_part" ] && parts+=("$usage_part")
parts+=("$cwd_part")
parts+=("$git_part")
parts+=("$cm_part")

output=""
for part in "${parts[@]}"; do
    if [ -z "$output" ]; then
        output="$part"
    else
        output="$output $SEP $part"
    fi
done

printf "%b" "$output"
