CHANGELOG_BAK=/tmp/mythtv_changelog
CONTROL_BAK=/tmp/mythtv_control
mkchangelog() {
  cat >debian/changelog<<EOF
mythfrontend-qml ($1) $2; urgency=medium

  * Upstream update

 -- Paul Harrison <pharrison@mythtv.org>  $(LANG=C date -R)

`cat $CHANGELOG_BAK`
EOF
}

DISTRIBUTIONS=(bionic cosmic disco)
DATE=`date -d @$(git log -n1 --format="%at") +%Y%m%d`
idx=0
for D in ${DISTRIBUTIONS[@]}; do
  git checkout -- debian/changelog debian/control
  cp -avf debian/control $CONTROL_BAK
  cp -avf debian/changelog $CHANGELOG_BAK
  VER=2:31.0~master.`git log -1 --pretty=format:"${DATE}.%h~${D}" 2> /dev/null`
  mkchangelog $VER $D
  #debuild -S -sa
  #dput -f ppa:mythtv-paulh/mythtv-qml ../mythfrontend-qml_${VER}_source.changes
  dpkg-buildpackage -b
  cp -avf $CHANGELOG_BAK debian/changelog
  cp -avf $CONTROL_BAK debian/control
  idx=$((idx+1))
done
