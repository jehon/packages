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
            <name>Films (Français)</name>
            <path>smb://192.168.1.9/video/films</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>Movies (English)</name>
            <path>smb://192.168.1.9/video/movies</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>Compositions</name>
            <path>smb://192.168.1.9/photo/films/</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>Temporary</name>
            <path>smb://192.168.1.9/transferts/videos/</path>
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
            <path>smb://192.168.1.9/music/</path>
            <allowsharing>true</allowsharing>
        </source>
    </music>
    <files>
        <default pathversion="1"></default>
    </files>
</sources>
EOC

cat > /home/osmc/.kodi/userdata/passwords.xml <<EOC
<passwords>
    <path>
        <from pathversion="1">smb://192.168.1.9/transferts</from>
        <to pathversion="1">smb://$SYNOLOGY_USERNAME:$SYNOLOGY_PASSWORD/transferts/videos/</to>
    </path>
    <path>
        <from pathversion="1">smb://192.168.1.9/video</from>
        <to pathversion="1">smb://$SYNOLOGY_USERNAME:$SYNOLOGY_PASSWORD/video/</to>
    </path>
    <path>
        <from pathversion="1">smb://192.168.1.9/music</from>
        <to pathversion="1">smb://$SYNOLOGY_USERNAME:$SYNOLOGY_PASSWORD/music/</to>
    </path>
</passwords>
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
chown osmc.osmc /home/osmc/.kodi/userdata/passwords.xml
chown osmc.osmc /home/osmc/.kodi/userdata/keymaps/zKeymap.xml
