#!/bin/bash
# System monitor for the cpu/ram popup of the status bar (tmux2k popup_handler).
# btop refuses to run under 80 columns ("Terminal size too small") and the popup on a phone
# has ~40, so pick by the popup's width: btop when it fits, htop otherwise, top as last resort.
cols=$(tput cols 2>/dev/null || echo 0)
if [ "${cols:-0}" -ge 80 ] && command -v btop >/dev/null 2>&1; then exec btop; fi
if command -v htop >/dev/null 2>&1; then exec htop; fi
exec top
