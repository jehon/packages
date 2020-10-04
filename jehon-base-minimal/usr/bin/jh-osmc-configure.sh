#!/usr/bin/env bash

# shellcheck disable=SC1091
. /etc/jehon/restricted/jehon.env

if [ -z "$SYNOLOGY_USERNAME" ]; then
    echo "Need a SYNOLOGY_USERNAME in /etc/jehon/restricted/jehon.env" >&2
    exit 255
fi

if [ -z "$SYNOLOGY_PASSWORD" ]; then
    echo "Need a SYNOLOGY_PASSWORD in /etc/jehon/restricted/jehon.env" >&2
    exit 255
fi

cat > /home/osmc/.kodi/userdata/sources.xml <<EOC
<sources>
    <video>
        <default pathversion="1"></default>
        <source>
            <name>Auto-mounted drives</name>
            <path pathversion="1">/media/</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>videos (synology)</name>
            <path>smb://$SYNOLOGY_USERNAME:$SYNOLOGY_PASSWORD@192.168.1.9/video/</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>transfert (synology)</name>
            <path>smb://$SYNOLOGY_USERNAME:$SYNOLOGY_PASSWORD@192.168.1.9/transferts/videos/</path>
            <allowsharing>true</allowsharing>
        </source>
    </video>
    <music>
        <default pathversion="1"></default>
        <source>
            <name>Auto-mounted drives</name>
            <path pathversion="1">/media/</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>music (synology)</name>
            <path>smb://$SYNOLOGY_USERNAME:$SYNOLOGY_PASSWORD@192.168.1.9/music/</path>
            <allowsharing>true</allowsharing>
        </source>
    </music>
    <files>
        <default pathversion="1"></default>
    </files>
</sources>
EOC

cat > /home/osmc/.kodi/userdata/keymaps/zKeymap.xml <<EOC
<keymap>
	<!-- https://kodi.wiki/view/Window_IDs -->
	<!-- https://github.com/xbmc/xbmc/blob/master/system/keymaps/keyboard.xml -->
	<FullscreenVideo>
		<remote>
			<!-- https://kodi.wiki/view/CEC -->
			<!-- https://github.com/xbmc/xbmc/blob/master/system/keymaps/remote.xml -->
			<red>AudioNextLanguage</red>
			<green>ShowSubtitles</green>
			<yellow>NextSubtitle</yellow>
			<blue></blue>
		</remote>
	</FullscreenVideo>
</keymap>
EOC

# envsubst < "$SWD"/../lib/jehon/src/sources.xml > /home/osmc/.kodi/userdata/sources.xml
chown osmc.osmc /home/osmc/.kodi/userdata/sources.xml
