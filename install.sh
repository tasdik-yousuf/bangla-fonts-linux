#!/usr/bin/env bash
#
# install.sh — Install Bengali (Bangla) fonts on Linux
#
# Usage:
#   ./install.sh                     Interactive mode (asks user vs system, uses ./fonts)
#   ./install.sh --user              Install for current user only (no sudo needed)
#   ./install.sh --system            Install system-wide (requires sudo)
#   ./install.sh --user  /path/dir   Install fonts from a custom directory
#   ./install.sh --system /path/dir
#   ./install.sh --uninstall --user     Remove fonts installed by this tool (user)
#   ./install.sh --uninstall --system   Remove fonts installed by this tool (system)
#
# Supported font formats: .ttf .otf .ttc .otc .woff .woff2 (woff kept but not
# typically used for desktop rendering — included for completeness)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_FONT_DIR="${SCRIPT_DIR}/fonts"

USER_DEST="${HOME}/.local/share/fonts/bengali-fonts"
SYSTEM_DEST="/usr/local/share/fonts/bengali-fonts"

MODE=""            # "user" | "system"
FONT_DIR=""
UNINSTALL=0

# ---------- helpers ----------

color() { # color "31" "text"
  printf "\033[%sm%s\033[0m\n" "$1" "$2"
}
info()  { color "36" "==> $1"; }
ok()    { color "32" "✓ $1"; }
warn()  { color "33" "! $1"; }
err()   { color "31" "✗ $1"; }

usage() {
  sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 1
}

check_fc_tools() {
  if ! command -v fc-cache >/dev/null 2>&1; then
    warn "fontconfig (fc-cache) not found. Attempting to note this — please install"
    warn "the 'fontconfig' package for your distro (e.g. 'sudo apt install fontconfig')."
    return 1
  fi
  return 0
}

count_fonts() {
  local dir="$1"
  find "$dir" -maxdepth 5 -type f \
    \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' -o -iname '*.otc' \
       -o -iname '*.woff' -o -iname '*.woff2' \) 2>/dev/null | wc -l | tr -d ' '
}

# ---------- arg parsing ----------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)      MODE="user"; shift ;;
    --system)    MODE="system"; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help)   usage ;;
    *)
      if [[ -z "${FONT_DIR}" ]]; then
        FONT_DIR="$1"
        shift
      else
        err "Unknown argument: $1"
        usage
      fi
      ;;
  esac
done

[[ -z "${FONT_DIR}" ]] && FONT_DIR="${DEFAULT_FONT_DIR}"

# ---------- interactive mode ----------

if [[ -z "${MODE}" && "${UNINSTALL}" -eq 0 ]]; then
  echo
  color "1" "Bengali Font Installer"
  echo "Where would you like to install the fonts?"
  echo "  1) Just for me (current user, no sudo needed)"
  echo "  2) System-wide (all users, requires sudo)"
  read -rp "Choose [1/2]: " choice
  case "$choice" in
    1) MODE="user" ;;
    2) MODE="system" ;;
    *) err "Invalid choice."; exit 1 ;;
  esac
fi

if [[ -z "${MODE}" && "${UNINSTALL}" -eq 1 ]]; then
  echo "Uninstall from where?"
  echo "  1) User install"
  echo "  2) System install"
  read -rp "Choose [1/2]: " choice
  case "$choice" in
    1) MODE="user" ;;
    2) MODE="system" ;;
    *) err "Invalid choice."; exit 1 ;;
  esac
fi

if [[ "${MODE}" == "user" ]]; then
  DEST="${USER_DEST}"
  SUDO=""
else
  DEST="${SYSTEM_DEST}"
  SUDO="sudo"
fi

# ---------- uninstall path ----------

if [[ "${UNINSTALL}" -eq 1 ]]; then
  if [[ ! -d "${DEST}" ]]; then
    warn "Nothing installed at ${DEST}"
    exit 0
  fi
  info "Removing ${DEST}"
  ${SUDO} rm -rf "${DEST}"
  info "Refreshing font cache"
  fc-cache -f >/dev/null 2>&1 || true
  ok "Uninstalled Bengali fonts (${MODE})."
  exit 0
fi

# ---------- install path ----------

if [[ ! -d "${FONT_DIR}" ]]; then
  err "Font directory not found: ${FONT_DIR}"
  echo "Place your .ttf/.otf files in '${DEFAULT_FONT_DIR}' or pass a path:"
  echo "  ./install.sh --user /path/to/your/fonts"
  exit 1
fi

N="$(count_fonts "${FONT_DIR}")"
if [[ "${N}" -eq 0 ]]; then
  err "No font files (.ttf/.otf/.ttc/.otc/.woff/.woff2) found in ${FONT_DIR}"
  exit 1
fi

info "Found ${N} font file(s) in ${FONT_DIR}"
info "Installing to: ${DEST} (${MODE})"

${SUDO} mkdir -p "${DEST}"

# Copy while preserving subfolder structure (some font families ship in subdirs)
# and skipping non-font files (READMEs, licenses, images, etc).
COPIED=0
while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  ${SUDO} cp -f "$f" "${DEST}/${base}"
  COPIED=$((COPIED + 1))
done < <(find "${FONT_DIR}" -maxdepth 5 -type f \
    \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' -o -iname '*.otc' \
       -o -iname '*.woff' -o -iname '*.woff2' \) -print0)

ok "Copied ${COPIED} font file(s) to ${DEST}"

if [[ "${MODE}" == "system" ]]; then
  ${SUDO} chmod -R a+rX "${DEST}"
fi

info "Rebuilding font cache"
if check_fc_tools; then
  if [[ "${MODE}" == "system" ]]; then
    ${SUDO} fc-cache -f "${DEST}" >/dev/null 2>&1
  else
    fc-cache -f "${DEST}" >/dev/null 2>&1
  fi
  ok "Font cache updated."
else
  warn "Skipped fc-cache (not found)."
fi

echo
ok "Done! Verifying installed fonts recognized by fontconfig:"
echo
fc-list | grep -i -F -f <(find "${FONT_DIR}" -maxdepth 5 -type f \
    \( -iname '*.ttf' -o -iname '*.otf' \) -exec basename {} \; \
    | sed -E 's/\.[Tt][Tt][Ff]$//; s/\.[Oo][Tt][Ff]$//' \
    | sort -u) 2>/dev/null | sort | uniq || true

echo
info "You may need to restart open applications (or log out/in) for the"
info "new fonts to appear in font pickers (LibreOffice, GIMP, browsers, etc)."
