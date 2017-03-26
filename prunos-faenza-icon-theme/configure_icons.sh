#!/bin/sh

[ -n "$1" ] && DIR="$1" || DIR="."

LN="ln -sf"

mkdir -p "$DIR/usr/share/icons"
cd "$DIR/usr/share/icons"

if ! wget --no-check-certificate -c https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/faenza-icon-theme/faenza-icon-theme_1.3.zip; then
  echo "Could not download package"
  exit 1
fi

wget -c http://http.debian.net/debian/pool/main/a/adwaita-icon-theme/adwaita-icon-theme_3.22.0.orig.tar.xz

unzip faenza-icon-theme_1.3.zip
rm faenza-icon-theme_1.3.zip

tar -zxf Faenza.tar.gz
rm *.tar.gz
iconfolder=Faenza

sed -i 's/Faenza/Faenza\nExample=distributor-logo/g' "${iconfolder}/index.theme"
sed -i -r "/\/scalable\]/{n;s/(Size=)96/\116/}" "${iconfolder}/index.theme"

distributor=debian
iconname="distributor-logo-$distributor"
$LN ./$iconname.svg "${iconfolder}/places/scalable/distributor-logo.svg"
for size in 48 32 24 22; do
  $LN ./$iconname.png "${iconfolder}/places/${size}/distributor-logo.png"
done

iconname="start-here-gnome"
$LN ./$iconname.svg "${iconfolder}/places/scalable/start-here.svg"
$LN ./$iconname-symbolic.svg "${iconfolder}/places/scalable/start-here-symbolic.svg"
for size in 48 32 24 22; do
  $LN ./$iconname.png "${iconfolder}/places/${size}/start-here.png"
done

for _file in novell-button.*; do
  find . -name $_file -print0 | xargs -0 rm
done

find . -type f -exec chmod 644 '{}' \;

# Delete broken links
find . -type l ! -exec test -e {} \; -exec rm {} \;

# iconfolder type NAMES
linknewnames() {

  ([ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]) || return 1

  for size in 16 22 24 32 48 64 96 scalable; do

    [ -d "$1/$2/${size}" ] || continue

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

[ -f "adwaita-icon-theme_3.22.0.orig.tar.xz" ] && {
  tar -xJf adwaita-icon-theme_3.22.0.orig.tar.xz
  rm adwaita-icon-theme_3.22.0.orig.tar.xz
}

ADD="scalable/actions/pan-down-symbolic.svg \
     scalable/actions/pan-end-symbolic.svg \
     scalable/actions/pan-start-symbolic.svg \
     scalable/actions/pan-up-symbolic.svg"

for icon in $ADD; do
  x="${icon%/*}"
  [ -e "Faenza/${x#*/}/${x%/*}/${icon##*/}" ] || mv "adwaita-icon-theme-3.22.0/Adwaita/$icon" "Faenza/${x#*/}/${x%/*}/${icon##*/}"
done

for icon in 16/actions/go-down.png 16/actions/go-up.png; do
  x="${icon%/*}"
  mv "adwaita-icon-theme-3.22.0/Adwaita/${x%/*}x${icon}" "Faenza/${x#*/}/${x%/*}/${icon##*/}"
done

rm -fr adwaita-icon-theme-3.22.0
