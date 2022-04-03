# The main `sway` configuration file in ~/.config/sway/config calls this
# script. Changes to the status bar should appear immediately after saving this
# script. If they do not, execute "killall swaybar" and reload the main
# configuration file.

# Time indicating how long the system has been running.
uptime=$(uptime | awk '{ gsub(",", "", $3); print $3 }')

# The abbreviated weekday name, followed by the abbreviated month name, day of
# month, and finally the time (24-hour clock). For example,
#	Thu Mar 24 09:09
date=$(date "+%a %b %d %H:%M")

# The battery percentage, estimated time remaining, and state in the following
# format:
#	78% (5.0h); discharging
batinfo=$(upower --show-info $(upower --enumerate | grep BAT))
batprcnt=$(echo "$batinfo" | sed -En 's,^\s*percentage:\s*,,p')
batstate=$(echo "$batinfo" | sed -En 's,^\s*state:\s*,,p')
battime=$(echo "$batinfo" | sed -En 's,^\s*time to (empty|full):\s*,\1 in ,p' \
	| awk 'END { print (NF) ? $0 : "calculating..." }')
batstat="$batprcnt ($battime); $batstate"

# Primary display brightness rounded to the nearest whole number.
brightness=$(light -G | awk '{ printf "%.0f", $0 }')

# Playback volume and capture percentages. If the devices are disabled, returns
# "off".
vol=$(amixer get Master | sed -En '${ s,[^[]*(\[.*$),\1,; s,[][],,gp }' \
	| awk '{ print ($2 == "off") ? $2 : $1 }')
capture=$(amixer get Capture | sed -En '${ s,[^[]*(\[.*$),\1,; s,[][],,gp }' \
	| awk '{ print ($2 == "off") ? $2 : $1 }')

# Wi-Fi status: shows this device's IP address and the name of the current
# active connection. Returns "na" if the IP address cannot be obtained and
# "off" if an active connection does not exist.
ip=$(ip --oneline route | sed -En 's/.*src ([0-9.]+).*/\1/p' \
	| awk 'END { print (NF) ? $0 : "na" }')
conname=$(nmcli connection show --active | awk '
	BEGIN	{ name = "off" }
	NR == 2	{ sub("  .*", ""); name = $0 }
	END	{ print name }')
wifi="$conname ($ip)"

# Average CPU temperature in Celsius.
cputemp=$(paste <(cat /sys/class/thermal/thermal_zone*/type) \
		<(cat /sys/class/thermal/thermal_zone*/temp) \
	| awk '/x86_pkg_temp/ { print gensub("(.)..$", ".\\1°C", "1", $NF) }')

echo "Up: $uptime | Lit: $brightness | Mix/Mic: $vol/$capture | Wi-Fi: $wifi \
| Bat: $batstat | CPU: $cputemp | $date"
