#!/usr/bin/env bash
# Sleezwave Tmux Plugin
# A synthwave-inspired tmux colorscheme and status bar

# Sleezwave color palette
SLEEZ_BG="#1a0d2e"
SLEEZ_FG="#c9a9dd"
SLEEZ_HOT_PINK="#ff6bcb"
SLEEZ_ELECTRIC_BLUE="#3d5afe"
SLEEZ_ELECTRIC_CYAN="#00e5ff"
SLEEZ_ELECTRIC_GREEN="#69ff94"
SLEEZ_NEON_YELLOW="#ffeb3b"
SLEEZ_PURPLE="#ab47bc"
SLEEZ_MUTED_PINK="#ff8fab"
SLEEZ_MUTED_BLUE="#5c6bc0"
SLEEZ_MUTED_CYAN="#4dd0e1"
SLEEZ_MUTED_GREEN="#7dffb3"
SLEEZ_MUTED_YELLOW="#fff176"
SLEEZ_MUTED_PURPLE="#ce93d8"
SLEEZ_DARK_PURPLE="#352040"
SLEEZ_DARKER_PURPLE="#2d1b3d"
SLEEZ_LIGHT_PURPLE="#e1c4f7"

# Unicode symbols
ARROW_RIGHT="❯"
ARROW_LEFT="❮"
SEPARATOR="▏"
DOT="●"
TRIANGLE="▲"
DIAMOND="◆"
STAR="⭐"
LIGHTNING="⚡"
FOLDER="📁"
BRANCH="⎇"
CLOCK="🕐"
BATTERY="🔋"
CPU="💻"
WIFI="📶"

# Function to get battery status (works on macOS and Linux)
get_battery() {
    if command -v pmset >/dev/null 2>&1; then
        # macOS
        battery_info=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
        if [ -n "$battery_info" ]; then
            if [ "$battery_info" -gt 75 ]; then
                echo "${BATTERY}${battery_info}%"
            elif [ "$battery_info" -gt 50 ]; then
                echo "🔋${battery_info}%"
            elif [ "$battery_info" -gt 25 ]; then
                echo "🪫${battery_info}%"
            else
                echo "🔴${battery_info}%"
            fi
        fi
    elif [ -f /sys/class/power_supply/BAT0/capacity ]; then
        # Linux
        battery_info=$(cat /sys/class/power_supply/BAT0/capacity)
        if [ "$battery_info" -gt 75 ]; then
            echo "${BATTERY}${battery_info}%"
        elif [ "$battery_info" -gt 50 ]; then
            echo "🔋${battery_info}%"
        elif [ "$battery_info" -gt 25 ]; then
            echo "🪫${battery_info}%"
        else
            echo "🔴${battery_info}%"
        fi
    fi
}

# Function to get git branch
get_git_branch() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        branch=$(git branch --show-current 2>/dev/null)
        if [ -n "$branch" ]; then
            echo "${BRANCH} ${branch}"
        fi
    fi
}

# Function to get CPU usage
get_cpu() {
    if command -v top >/dev/null 2>&1; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | cut -d% -f1)
        else
            # Linux
            cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d% -f1)
        fi
        if [ -n "$cpu" ]; then
            echo "${CPU}${cpu}%"
        fi
    fi
}

# Function to get memory usage
get_memory() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        mem=$(ps -A -o %mem | awk '{s+=$1} END {printf "%.0f", s}')
    else
        # Linux
        mem=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    fi
    if [ -n "$mem" ]; then
        echo "🧠${mem}%"
    fi
}

# Set tmux options
setup_colors() {
    # Basic colors
    tmux set-option -g default-terminal "screen-256color"
    tmux set-option -sa terminal-overrides ",*256col*:Tc"
    
    # Pane borders
    tmux set-option -g pane-border-style "fg=${SLEEZ_DARK_PURPLE}"
    tmux set-option -g pane-active-border-style "fg=${SLEEZ_ELECTRIC_CYAN}"
    
    # Message style
    tmux set-option -g message-style "bg=${SLEEZ_ELECTRIC_CYAN},fg=${SLEEZ_BG}"
    tmux set-option -g message-command-style "bg=${SLEEZ_HOT_PINK},fg=${SLEEZ_BG}"
    
    # Mode style (copy mode, etc.)
    tmux set-option -g mode-style "bg=${SLEEZ_ELECTRIC_CYAN},fg=${SLEEZ_BG}"
    
    # Clock mode
    tmux set-option -g clock-mode-colour "${SLEEZ_ELECTRIC_CYAN}"
    tmux set-option -g clock-mode-style 24
}

setup_status_bar() {
    # Status bar settings
    tmux set-option -g status on
    tmux set-option -g status-interval 5
    tmux set-option -g status-position bottom
    tmux set-option -g status-justify left
    tmux set-option -g status-style "bg=${SLEEZ_BG},fg=${SLEEZ_FG}"
    
    # Status left (session info)
    local session_style="bg=${SLEEZ_ELECTRIC_CYAN},fg=${SLEEZ_BG},bold"
    local session_arrow="bg=${SLEEZ_BG},fg=${SLEEZ_ELECTRIC_CYAN}"
    tmux set-option -g status-left-length 50
    tmux set-option -g status-left "#[${session_style}] ${STAR} #S #[${session_arrow}]${ARROW_RIGHT}#[default]"
    
    # Window status
    local window_style="bg=${SLEEZ_DARK_PURPLE},fg=${SLEEZ_MUTED_PURPLE}"
    local window_current_style="bg=${SLEEZ_HOT_PINK},fg=${SLEEZ_BG},bold"
    local window_activity_style="bg=${SLEEZ_NEON_YELLOW},fg=${SLEEZ_BG}"
    
    tmux set-option -g window-status-format "#[${window_style}] #I${SEPARATOR}#W "
    tmux set-option -g window-status-current-format "#[${window_current_style}] #I${SEPARATOR}#W "
    tmux set-option -g window-status-activity-style "${window_activity_style}"
    tmux set-option -g window-status-bell-style "${window_activity_style}"
    
    # Status right (system info and time)
    local cpu_style="bg=${SLEEZ_PURPLE},fg=${SLEEZ_BG}"
    local battery_style="bg=${SLEEZ_ELECTRIC_GREEN},fg=${SLEEZ_BG}"
    local git_style="bg=${SLEEZ_MUTED_BLUE},fg=${SLEEZ_BG}"
    local time_style="bg=${SLEEZ_HOT_PINK},fg=${SLEEZ_BG},bold"
    local date_style="bg=${SLEEZ_ELECTRIC_CYAN},fg=${SLEEZ_BG},bold"
    
    # Arrows for right side
    local cpu_arrow="bg=${SLEEZ_PURPLE},fg=${SLEEZ_BG}"
    local battery_arrow="bg=${SLEEZ_ELECTRIC_GREEN},fg=${SLEEZ_PURPLE}"
    local git_arrow="bg=${SLEEZ_MUTED_BLUE},fg=${SLEEZ_ELECTRIC_GREEN}"
    local time_arrow="bg=${SLEEZ_HOT_PINK},fg=${SLEEZ_MUTED_BLUE}"
    local date_arrow="bg=${SLEEZ_ELECTRIC_CYAN},fg=${SLEEZ_HOT_PINK}"
    
    tmux set-option -g status-right-length 150
    
    # Build status right with conditional segments
    local status_right=""
    
    # CPU segment
    status_right+="#[fg=${SLEEZ_PURPLE}]${ARROW_LEFT}#[${cpu_style}]"
    status_right+="#(echo '$(get_cpu)' | sed 's/^$/💻/')"
    
    # Battery segment (only if battery exists)
    status_right+="#[${battery_arrow}]${ARROW_LEFT}#[${battery_style}]"
    status_right+="#(get_battery 2>/dev/null || echo '')"
    
    # Git segment (only if in git repo)
    status_right+="#[${git_arrow}]${ARROW_LEFT}#[${git_style}]"
    status_right+="#(get_git_branch 2>/dev/null || echo '')"
    
    # Time segment
    status_right+="#[${time_arrow}]${ARROW_LEFT}#[${time_style}] ${CLOCK} %H:%M "
    
    # Date segment
    status_right+="#[${date_arrow}]${ARROW_LEFT}#[${date_style}] %d %b "
    
    tmux set-option -g status-right "${status_right}"
}

setup_other_options() {
    # Enable mouse support
    tmux set-option -g mouse on
    
    # Start window and pane numbering at 1
    tmux set-option -g base-index 1
    tmux set-option -g pane-base-index 1
    
    # Renumber windows when one is closed
    tmux set-option -g renumber-windows on
    
    # Enable activity monitoring
    tmux set-option -g monitor-activity on
    tmux set-option -g visual-activity off
    
    # Set window notifications
    tmux set-option -g window-status-activity-style "bg=${SLEEZ_NEON_YELLOW},fg=${SLEEZ_BG}"
    
    # Copy mode colors
    tmux set-option -g mode-style "bg=${SLEEZ_ELECTRIC_CYAN},fg=${SLEEZ_BG}"
}

# Export functions for tmux to use
export -f get_battery
export -f get_git_branch
export -f get_cpu
export -f get_memory

# Main setup function
main() {
    setup_colors
    setup_status_bar
    setup_other_options
    
    echo "Sleezwave tmux theme loaded! ${LIGHTNING}"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
