#!/usr/bin/env bash

REMOTE_UPLOAD_TORRENT_FILES="/volume3/temporary/torrents/"
REMOTE_DOWNLOADED_FILES="/var/services/homes/admin/downloaded/"
LOCAL_DOWNLOADED="/home/jehon/Desktop/downloaded/"

jh-rsync.sh /home/jehon/Downloads/ "synology:$REMOTE_UPLOAD_TORRENT_FILES" \
	"--rsync-path=/bin/rsync" \
	--no-perms --remove-source-files \
	--include "*.torrent" --exclude "*"

mkdir -p "$LOCAL_DOWNLOADED"
jh-rsync.sh "synology:$REMOTE_DOWNLOADED_FILES" "$LOCAL_DOWNLOADED/" \
	"--rsync-path=/bin/rsync" \
	--prune-empty-dirs --remove-source-files

/bin/chown jehon -R "$LOCAL_DOWNLOADED/"

ssh "synology" "find '$REMOTE_DOWNLOADED_FILES' -depth -type d -mindepth 1 -delete" 
