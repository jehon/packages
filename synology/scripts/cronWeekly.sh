#!/bin/sh

# This script should sent its output to email

SWD="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

# Clean up picture folder
chown -R admin /volume3/photo/
chgrp -R users /volume3/photo/
chmod -R a+rwX /volume3/photo/

# Clean-up some
/volume3/scripts/synology/remove-empty-eadirs.sh /volume3/homes/download/
/volume3/scripts/synology/remove-empty-eadirs.sh /volume3/music/
/volume3/scripts/synology/remove-empty-eadirs.sh /volume3/video/

# Remove old backups
(
	cd /volume3/Backups/snapshots/ || exit 255
	"$SWD"/jh-remove-old-backups.sh 30
)

# Check if a movie is not in the correct form for other media players
# "$SWD"/jh-movies-normalize.sh
