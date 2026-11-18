#!/bin/sh
CCUSAGE="$(dirname "$0")/statusline/node_modules/.bin/ccusage"
[ -x "$CCUSAGE" ] || CCUSAGE=ccusage
TMP=$(mktemp "${TMPDIR:-/tmp}/ccstatusline.XXXXXX")
trap 'rm -f "$TMP"' EXIT
cat > "$TMP"

CC=$("$CCUSAGE" statusline --cost-source ccusage --offline < "$TMP" 2>/dev/null)
SID=$(jq -r '.session_id // empty' < "$TMP" 2>/dev/null)
KA=$(jq -c 'select(.count >= 1)' "/tmp/claude-keepalive/$SID.json" 2>/dev/null)
PROFILE=${CLAUDE_CONFIG_DIR:-personal}
PROFILE=${PROFILE##*/.claude-}

jq -r --arg cc "$CC" --arg profile "$PROFILE" --argjson ka "${KA:-null}" --arg columns "${COLUMNS:-}" '
  def dur: if . >= 60 then "\(. / 60 | floor)h\(. % 60 | if . < 10 then "0\(.)" else "\(.)" end)m" else "\(.)m" end;
  def usd($suffix): [$cc | capture("\\$(?<v>[0-9.]+)" + $suffix) | .v | tonumber | ceil] | first;
  def cache:
    (if .warm and .expires_at != null then (.expires_at - now) / 60 | ceil else 0 end
     | if . <= 0 then "🧊 cold" elif . <= 10 then "\u001b[33m⏳ \(.)m\u001b[0m" else "⏳ \(.)m" end)
    + (if $ka == null then "" else " (\($ka.count)/\($ka.max))" end);
  def cells: gsub("\u001b\\[[0-9;]*m"; "") | length + ([scan("[👤📊⏳🧊💰🔥🧠]")] | length);
  def footer_padding_x: 2;
  def fit: ($columns | tonumber? // 0) as $width
    | select(length > 0)
    | if $width > 0 then first(.[] | select(cells <= $width - 2 * footer_padding_x)) // last else first end;
  def until_reset: (.resets_at // 0) - now | if . > 0 then " (\(. / 60 | ceil | dur))" else "" end;
  def quota($reset; $week):
    [ (.rate_limits.five_hour | select(.used_percentage != null)
       | "5h \(.used_percentage | ceil)%" + (if $reset then until_reset else "" end)),
      (select($week) | .rate_limits.seven_day | select(.used_percentage != null) | "7d \(.used_percentage | ceil)%")
    ] | select(length > 0) | "📊 " + join(" · ");
  def line1($name; $reset; $week):
    ["👤 " + $name] + [quota($reset; $week)] + [.prompt_cache | select(. != null) | cache] | join(" | ");
  def line2($today):
    [ (usd(" session") as $s | usd(" today") as $t | select($s != null and $t != null)
       | "💰 $\($s)" + (if $today then " · 24h $\($t)" else "" end)),
      (usd("/hr") | select(. != null) | "🔥 $\(.)/hr"),
      (.context_window | select(.used_percentage != null) | "🧠 \((.total_input_tokens // 0) / 1000 | ceil)k (\(.used_percentage | ceil)%)")
    ] | select(any(.[]; startswith("🔥") | not)) | join(" | ");

  ([line1($profile; true; true), line1($profile[:4]; true; true), line1($profile[:4]; false; true), line1($profile[:4]; false; false)] | fit),
  ([line2(true), line2(false)] | fit)
' < "$TMP" 2>/dev/null
