# External Tools

chmod -R 0755 $INSTALLER/addon/Volume-Key-Selector/tools
cp -R $INSTALLER/addon/Volume-Key-Selector/tools $INSTALLER/common/unityfiles 2>/dev/null

keytest() {
  ui_print " - Vol Key Test -"
  ui_print "   Press a Vol Key:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
  # Original idea by chainfire @xda-developers, improved on by ianmacd @xda-developers
  while true; do
    /system/bin/getevent -lqc 1 | awk '{ print $(NF-1) }' | grep "KEY_VOLUME" > $INSTALLER/events
    [ -s $INSTALLER/events ] && break
  done
  if (grep KEY_VOLUMEUP $INSTALLER/events >/dev/null); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  keycheck
  keycheck
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "   Vol key not detected!"
    abort "   Use name change method in TWRP"
  fi
}

if keytest; then
  VKSEL=chooseport
else
  VKSEL=chooseportold
  ui_print "   ! Legacy device detected! Using old keycheck method"
  [ "$ARCH32" == "arm" ] || { ui_print "   ! Non-arm device detected!"; abort "   ! Keycheck binary only compatible with arm/arm64 devices!"; }
  ui_print " "
  ui_print "- Vol Key Programming -"
  ui_print "   Press Vol Up Again:"
  $VKSEL "UP"
  ui_print "   Press Vol Down"
  $VKSEL "DOWN"
fi
