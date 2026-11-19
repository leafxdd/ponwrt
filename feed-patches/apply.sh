#!/bin/sh
# Apply feed-patches/<feed>/*.patch to feeds/<feed>. Run it after
# ./scripts/feeds update and before building. A patch that is already
# applied is skipped; one that does not apply stops the script.

set -e
cd "$(dirname "$0")/.."

for dir in feed-patches/*/; do
	feed=$(basename "$dir")
	for patch in "$dir"*.patch; do
		[ -e "$patch" ] || continue
		if patch -d "feeds/$feed" -p1 -R -f -s --dry-run < "$patch" >/dev/null 2>&1; then
			echo "already applied: $patch"
			continue
		fi
		echo "applying: $patch"
		patch -d "feeds/$feed" -p1 -N -s < "$patch"
	done
done
