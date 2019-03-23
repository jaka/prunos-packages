#!/bin/sh

URL_ICONS="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/master.zip"
GIT_ICONS="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git"
LN="ln -sf"

[ -n "$1" ] && DIR="$1" || DIR="."

SRC="$DIR/src"
DEST="$DIR/usr/share/icons"
mkdir -p "$SRC"
mkdir -p "$DEST"

git clone --depth 1 "$GIT_ICONS" "$SRC"

#if ! wget --no-check-certificate -c -P "$SRC" "$URL_ICONS"; then
#  echo "Could not download package"
#  exit 1
#fi
#unzip "$SRC/master.zip" -d "$SRC"
#rm -f "$SRC/master.zip"
	
mv "$SRC/Papirus" "$DEST"
rm -fr "$SRC"

DIR="$DEST/Papirus"

del_icons() {
  [ -n "$1" ] && subdir="$1" || return
  [ -n "$2" ] && icons="$2" || return

  for folder in `find $DIR -mindepth 1 -maxdepth 1 -type d`; do
    subfolder="$folder/$subdir"
    [ -d "$subfolder" ] || continue
    for icon in $icons; do
      find $subfolder -name "$icon*" -exec rm {} \;
    done
  done
}

echo "Removing icons ..."

ACTIONS="atmosphere. hypnotoad. im-google kt- labplot- redhat-home. fcitx- kdenlive- kstars_ rabbitvcs-"
del_icons "actions" "$ACTIONS"

APPS="luakit. apachedirectorystudio. tetzle. qbrowser. openra-d2k. minecraft. atom-beta. Othman. space.fips.Fips. the-cave. com.bladecoder.adventure-editor. \
osmscout-server. grid-autosport. razercommander. l4d2. bluegriffon. trinity-desktop. cockos-reaper. badland. kimagemapeditor. karbon. rygel. eternallands. \
harbour-pure-maps. tremulous. trine3. windstille-0.2. gdevilspie. gahshomar. gcstar. glippy. gnome-glchess. redhat- steam. steamvr. org.kde. sakura-dungeon. \
fofix. com.github. assaultcube. zim. viber. youtube. youtube-dl. yandex- box. google- sun-javaws- caja-dropbox. dropbox. kdepim- appimagekit-odrive. \
amazonclouddrive. amazon-store. amazon. com.abagames. fbmessenger."
del_icons "apps" "$APPS"

PLACES="folder-yandex-disk folder-meocloud folder-steam folder-blue-dropbox."
del_icons "places" "$PLACES"

PANEL="obs-tray. obs-tray-active. deluge-panel. crow-translate-tray. signal-unread-1. signal-tray. pomodoro-indicator- youtube-indicator- yum-indicator- \
dropboxstatus- odrive-tray viber-"
del_icons "panel" "$PANEL"

DEVICES="multimedia-player-ipod-"
del_icons "devices" "$DEVICES"

EMBLEM="emblem-dropbox-"
del_icons "emblems" "$EMBLEM"

#distributor-logo
distributor=debian
iconname="distributor-logo-$distributor"

for folder in `find $DIR -mindepth 1 -maxdepth 1 -type d`; do
  subfolder="$folder/apps"
  [ -d "$subfolder" ] || continue
  $LN "./$iconname.svg" "$subfolder/distributor-logo.svg"
  for f in `find "$subfolder" -type f -name "distributor-logo-*"`; do
    [ "`basename $f`" = "$iconname.svg" ] && continue
    find -L "$subfolder" -xtype l -samefile "$f" -exec rm {} \;
    rm -f "$f"
  done
done

#folders
for color in black bluegrey brown custom cyan green grey indigo magenta orange pink red teal violet white yellow; do
  find "$DIR" -name "folder-$color-*.svg" -exec rm {} \;
  find "$DIR" -name "user-$color-*.svg" -exec rm {} \;
done

# xfce
find "$DIR" -type l -name "xfce-*" -exec rm {} \;
find "$DIR" -name "xfce4-*" -exec rm {} \;

# yast
find "$DIR" -type l -name "yast-*" -exec rm {} \;

# chrome
find "$DIR" -name "chrome-*-Default.svg" -exec rm {} \;

# steam
for file in `find "$DIR" -name "steam_icon_*" -type l -exec readlink -f {} \; -exec rm {} \;`; do
  [ -f "$file" ] && rm -f "$file"
done

# io.github.
for file in `find "$DIR" -name "io.github.*" -type l -exec readlink -f {} \; -exec rm {} \;`; do
  [ -f "$file" ] && rm -f "$file"
done

echo "Removing broken links ..."

# Delete broken links
find "$DIR" -type l ! -exec test -e {} \; -exec rm {} \;
