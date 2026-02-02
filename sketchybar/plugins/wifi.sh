#!/usr/bin/env sh

IFACE="$(networksetup -listallhardwareports 2>/dev/null | awk '
  BEGIN{hit=0}
  /^Hardware Port: /{
    name=$0; gsub(/^Hardware Port: /,"",name)
    if (name ~ /Wi[[:punct:][:space:]]*Fi/) hit=1; else hit=0
  }
  hit && /^Device: /{print $2; exit}
')"
[ -n "$IFACE" ] || IFACE="en0"

CONNECTED_ICON="󰤨"
DISCONNECTED_ICON="󰤭"

SSID=""
CURR_TX=""
SHOW_IP=0

IP="$(ipconfig getifaddr "$IFACE" 2>/dev/null || true)"

if command -v wdutil >/dev/null 2>&1; then
  if sudo -n wdutil info >/dev/null 2>&1; then
    WD_LINK="$(sudo -n wdutil link "$IFACE" 2>/dev/null)"
    WD_INFO="$(sudo -n wdutil info "$IFACE" 2>/dev/null)"
    WD_ALL="$WD_LINK
$WD_INFO"

    SSID="$(printf "%s\n" "$WD_ALL" \
      | awk -F': ' 'tolower($0) ~ /^[[:space:]]*ssid[[:space:]]*:/ {gsub(/[[:space:]]+$/,"",$2); print $2; exit}')"
    CURR_TX="$(printf "%s\n" "$WD_ALL" \
      | awk -F': ' 'tolower($0) ~ /tx rate|lasttxrate/ {gsub(/ Mbps/,"",$2); gsub(/[[:space:]]+$/,"",$2); print $2; exit}')"
  fi
fi

if [ -z "$SSID" ] && [ -x "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport" ]; then
  AP="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
  AINFO="$("$AP" -I 2>/dev/null)"
  SSID="$(printf "%s\n" "$AINFO" | awk -F': ' '/ SSID/ {print $2; exit}')"
  CURR_TX="$(printf "%s\n" "$AINFO" | awk -F': ' '/ lastTxRate/ {print $2; exit}')"
fi

if [ -z "$SSID" ]; then
  SP="$(system_profiler SPAirPortDataType 2>/dev/null)"
  SSID="$(printf "%s\n" "$SP" | awk -F': ' '/ SSID: /{print $2; exit}')"
fi

if [ -z "$SSID" ]; then
  CUR="$(networksetup -getairportnetwork "$IFACE" 2>/dev/null)"
  case "$CUR" in
    *:* )
      SSID="$(printf "%s" "$CUR" | sed 's/^[^:]*:[[:space:]]*//')"
      case "$SSID" in
        ""|"You are not associated with an AirPort network."|\
        "You are not associated with a Wi-Fi network."|\
        "Not Associated" )
          SSID=""
          ;;
      esac
      ;;
  esac
fi

if [ -z "$SSID" ] && [ -n "$IP" ]; then
  SSID="Connected"
  SHOW_IP=1
fi

if [ -z "$SSID" ]; then
  sketchybar --set "$NAME" label="Disconnected" icon="$DISCONNECTED_ICON"
else
  if [ "$SHOW_IP" -eq 1 ]; then
    sketchybar --set "$NAME" label="Connected ($IP)" icon="$CONNECTED_ICON"
  elif [ -n "$CURR_TX" ]; then
    sketchybar --set "$NAME" label="$SSID (${CURR_TX}Mbps)" icon="$CONNECTED_ICON"
  else
    sketchybar --set "$NAME" label="$SSID" icon="$CONNECTED_ICON"
  fi
fi
