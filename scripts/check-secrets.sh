#!/usr/bin/env bash
# Pre-commit check: refuse to publish anything that looks like device state.
#
# Written after almost committing an OpenWrt config backup. A backup of
# /etc/config contains the Wi-Fi key, the admin password hash, the PPPoE
# credentials, static leases with MAC addresses, and any VPN or proxy node
# in cleartext. None of that belongs in a public repository, and .gitignore
# only helps if you remember it exists.
#
# Usage: ./scripts/check-secrets.sh [dir]      exit 1 on findings.

set -uo pipefail
TARGET="${1:-.}"
fail=0

scan() {
  local label="$1" pattern="$2"
  local hits
  hits=$(grep -rIniE "$pattern" "$TARGET" \
          --exclude-dir=.git --exclude="check-secrets.sh" 2>/dev/null || true)
  if [ -n "$hits" ]; then
    echo "FAIL  $label"
    echo "$hits" | sed 's/^/      /'
    fail=1
  else
    echo "ok    $label"
  fi
}

echo "Scanning: $TARGET"
echo

scan "IPv4 address"      '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'
scan "MAC address"       '\b([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b'
# Only flag assignments, not prose. "the admin password hash" in a paragraph is
# documentation; "password: hunter2" is a leak.
scan "credential value"  '(password|passwd|pwd|secret|psk|ssid|token|api[_-]?key|private[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]]'
scan "phone number (CN)" '\b1[3-9][0-9]{9}\b'
scan "email address"     '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
# UCI wireless uses `option key 'passphrase'`; `key` is too generic to put in the
# credential word list, so match the UCI line shape instead.
scan "uci wireless key"  "option[[:space:]]+key[[:space:]]+[^[:space:]]"
scan "device backup"     '(backup-[A-Za-z0-9._-]+\.tar\.gz|/etc/config/(network|wireless|dhcp|firewall))'

echo
if [ "$fail" -ne 0 ]; then
  echo "Refusing to publish. Remove the values above, or move the file out of the tree."
  exit 1
fi
echo "Clean."
