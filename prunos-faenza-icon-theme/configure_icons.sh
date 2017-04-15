#!/bin/sh

URL_ICONS1="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/faenza-icon-theme/faenza-icon-theme_1.3.zip"
URL_ICONS2="http://http.debian.net/debian/pool/main/a/adwaita-icon-theme/adwaita-icon-theme_3.22.0.orig.tar.xz"
LN="ln -sf"

[ -n "$1" ] && DIR="$1" || DIR="."

DIR="$DIR/usr/share/icons"
mkdir -p "$DIR"

if ! wget --no-check-certificate -c -P "$DIR" "$URL_ICONS1"; then
  echo "Could not download package"
  exit 1
fi

wget -c -P "$DIR" "$URL_ICONS2"

unzip "$DIR/faenza-icon-theme_1.3.zip" -d "$DIR"
rm -f "$DIR/faenza-icon-theme_1.3.zip"

tar -C "$DIR" -zxf "$DIR/Faenza.tar.gz"
find $DIR -maxdepth 1 -type f -name "*.tar.gz" -exec rm {} \;

iconfolder="$DIR/Faenza"

sed -i "s/Faenza/Faenza\nExample=distributor-logo/g" "$iconfolder/index.theme"
sed -i -r "/\/scalable\]/{n;s/(Size=)96/\116/}" "$iconfolder/index.theme"

rm -fr "$iconfolder/extras/"

distributor=debian
iconname="distributor-logo-$distributor"

$LN ./$iconname.svg "$iconfolder/places/scalable/distributor-logo.svg"
for f in `find "$iconfolder/places/scalable/" -type f -name "distributor-logo-*"`; do
  [ "`basename $f`" = "$iconname.svg" ] && continue
  find -L "$iconfolder/places/scalable/" -xtype l -samefile "$f" -exec rm -f {} \;
  rm -f $f
done

for size in 48 32 24 22; do
  $LN ./$iconname.png "$iconfolder/places/$size/distributor-logo.png"
  for f in `find "$iconfolder/places/$size/" -type f -name "distributor-logo-*"`; do
    [ "`basename $f`" = "$iconname.png" ] && continue
    find -L "$iconfolder/places/$size/" -xtype l -samefile "$f" -exec rm -f {} \;
    rm -f $f
  done
done

iconname="start-here-gnome"

$LN ./$iconname.svg "$iconfolder/places/scalable/start-here.svg"
for f in `find "$iconfolder/places/scalable/" -type f -name "start-here-*" ! -name "*-symbolic.svg"`; do
  [ "`basename $f`" = "$iconname.svg" ] && continue
  rm -f $f
done
for size in 48 32 24 22; do
  $LN ./$iconname.png "$iconfolder/places/$size/start-here.png"
  for f in `find "$iconfolder/places/$size/" -type f -name "start-here-*"`; do
    [ "`basename $f`" = "$iconname.png" ] && continue
    rm -f $f
  done
done

$LN ./$iconname-symbolic.svg "$iconfolder/places/scalable/start-here-symbolic.svg"
for f in `find "$iconfolder/places/scalable/" -type f -name "start-here-*-symbolic.svg"`; do
  [ "`basename $f`" = "$iconname-symbolic.svg" ] && continue
  rm -f $f
done

for f in novell-button.*; do
  find "$DIR" -name $f -exec rm {} \;
done

# Delete broken links
find "$DIR" -type l ! -exec test -e {} \; -exec rm {} \;

find "$DIR" -type f -exec chmod 644 '{}' \;

# iconfolder type NAMES
linknewnames() {

  ([ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]) || return 1

  for size in 16 22 24 32 48 64 96 scalable; do

    [ -d "$1/$2/$size" ] || continue

    if [ "$size" = "scalable" ]; then
      EXT=svg
    else
      EXT=png
    fi

    for i in $3; do

      oldname=`echo $i | cut -d: -f1`
      newname=`echo $i | cut -d: -f2`

      if [ -e "$1/$2/${size}/${oldname}.$EXT" ]; then
        [ -e "$1/$2/${size}/${newname}.$EXT" ] || $LN "${oldname}.$EXT" "$1/$2/${size}/${newname}.$EXT"
      fi

    done

  done
}

NAMES="baobab:mate-disk-usage-analyzer \
       eog:eom \
       evince:atril \
       file-roller:engrampa \
       gnome-display-properties:mate-preferences-desktop-display \
       gnome-network-properties:mate-network-properties \
       gnome-power-manager:mate-power-statistics \
       gtk-info:hook-notifier \
       gtk-info:mate-notification-properties \
       menu-editor:mozo \
       openjdk-6:javaws"

linknewnames "$iconfolder" apps "$NAMES"

linknewnames "$iconfolder" devices "battery:mate-power-manager"
linknewnames "$iconfolder" categories "preferences-desktop:mateconf-editor preferences-desktop:mate-session-properties"
linknewnames "$iconfolder" actions "system-shutdown-panel:system-shutdown-symbolic document-open:document-open-symbolic"
linknewnames "$iconfolder" status "microphone-sensitivity-high-symbolic:audio-input-microphone-high microphone-sensitivity-low-symbolic:audio-input-microphone-low"

[ -f "$DIR/adwaita-icon-theme_3.22.0.orig.tar.xz" ] && {
  tar -C "$DIR" -xJf "$DIR/adwaita-icon-theme_3.22.0.orig.tar.xz"
  rm -f "$DIR/adwaita-icon-theme_3.22.0.orig.tar.xz"
}

ADD="scalable/actions/pan-down-symbolic.svg \
     scalable/actions/pan-end-symbolic.svg \
     scalable/actions/pan-start-symbolic.svg \
     scalable/actions/pan-up-symbolic.svg"

for icon in $ADD; do
  x="${icon%/*}"
  [ -e "$iconfolder/${x#*/}/${x%/*}/${icon##*/}" ] || mv "$DIR/adwaita-icon-theme-3.22.0/Adwaita/$icon" "$iconfolder/${x#*/}/${x%/*}/${icon##*/}"
done

for icon in 16/actions/go-down.png 16/actions/go-up.png; do
  x="${icon%/*}"
  mv "$DIR/adwaita-icon-theme-3.22.0/Adwaita/${x%/*}x${icon}" "$iconfolder/${x#*/}/${x%/*}/${icon##*/}"
done

rm -fr "$DIR/adwaita-icon-theme-3.22.0"
