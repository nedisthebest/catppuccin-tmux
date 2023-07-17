#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_STATUS_LINE_FILE=src/default.conf

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

set() {
  local option=$1
  local value=$2
  tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
  local option=$1
  local value=$2
  tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
  local theme
  theme="$(get_tmux_option "@catppuccin_flavour" "mocha")"

  # Aggregate all commands in one array
  local tmux_commands=()

  # NOTE: Pulling in the selected theme by the theme that's being set as local
  # variables.
  # shellcheck source=catppuccin-frappe.tmuxtheme
  source /dev/stdin <<<"$(sed -e "/^[^#].*=/s/^/local /" "${PLUGIN_DIR}/catppuccin-${theme}.tmuxtheme")"

  # status
  set status "on"
  set status-bg "${thm_bg}"
  set status-justify "left"
  set status-left-length "100"
  set status-right-length "100"

  # messages
  set message-style "fg=${thm_cyan},bg=${thm_gray},align=centre"
  set message-command-style "fg=${thm_cyan},bg=${thm_gray},align=centre"

  # panes
  set pane-border-style "fg=${thm_gray}"
  set pane-active-border-style "fg=${thm_blue}"

  # windows
  setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
  setw window-status-separator ""
  setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

  # --------=== Statusline

  # Separators for the left status / window list
  local l_left_separator
  l_left_separator=""
  readonly l_left_separator

  local l_right_separator
  l_right_separator=""
  readonly l_right_separator

  # Separators for the right status
  local r_left_separator
  r_left_separator=""
  readonly r_left_separator

  local r_right_separator
  r_right_separator=""
  readonly r_right_separator
  #
  local user
  user="$(get_tmux_option "@catppuccin_user" "off")"
  readonly user

  local host
  host="$(get_tmux_option "@catppuccin_host" "off")"
  readonly host

  local date_time
  date_time="$(get_tmux_option "@catppuccin_date_time" "off")"
  readonly date_time


  # Icons
  local directory_icon
  directory_icon="$(get_tmux_option "@catppuccin_directory_icon" "")"
  readonly directory_icon

  # Icons
  local directory_icon
  directory_icon="$(get_tmux_option "@catppuccin_directory_icon" "")"
  readonly directory_icon

  local window_icon
  window_icon="$(get_tmux_option "@catppuccin_window_icon" "")"
  readonly window_icon

  local session_icon
  session_icon="$(get_tmux_option "@catppuccin_session_icon" "")"
  readonly session_icon

  local user_icon
  user_icon="$(get_tmux_option "@catppuccin_user_icon" "")"
  readonly user_icon

  local host_icon
  host_icon="$(get_tmux_option "@catppuccin_host_icon" "󰒋")"
  readonly host_icon

  local datetime_icon
  datetime_icon="$(get_tmux_option "@catppuccin_datetime_icon" "")"
  readonly datetime_icon

  local battery_icon
  battery_icon="$(get_tmux_option "@catppuccin_battery_icon" "")"
  readonly battery_icon

  local battery_charging_icon
  battery_charging_icon="$(get_tmux_option "@catppuccin_battery_charging_icon" "")"
  readonly battery_charging_icon


  # Source status line themes
  source "$PLUGIN_DIR/$DEFAULT_STATUS_LINE_FILE"

  # Right column 1 by default shows the Window name.
  local right_column1=$show_window

  # Right column 2 by default shows the current Session name.
  local right_column2=$show_session
  #local right_column2=$show_battery

  # Window status by default shows the current directory basename.
  local window_status_format=$show_directory_in_window_status
  local window_status_current_format=$show_directory_in_window_status_current

  # NOTE: With the @catppuccin_window_tabs_enabled set to on, we're going to
  # update the right_column1 and the window_status_* variables.

  set status-left ""
  set status-right "${show_user}${right_column1}${right_column2}"

  setw window-status-format "${window_status_format}"
  setw window-status-current-format "${window_status_current_format}"


  tmux "${tmux_commands[@]}"
}

main "$@"
