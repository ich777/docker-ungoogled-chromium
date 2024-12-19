#!/bin/bash
export DISPLAY=:99
export XAUTHORITY=${DATA_DIR}/.Xauthority
CUR_V="$(${DATA_DIR}/Ungoogled/chrome --version 2>/dev/null | awk '{print $2}')"
if [ "${UG_CHROMIUM_V}" == "latest" ]; then
  LAT_V="$(wget -qO- https://ungoogled-software.github.io/ungoogled-chromium-binaries/releases/linux_portable/64bit/ | grep -w "ungoogled-chromium-binaries/releases" | cut -d '>' -f3- | cut -d '<' -f1 | grep '^[0-9]' | sort -V | tail -1)"
  if [ -z "$LAT_V" ]; then
    if [ ! -z "$CUR_V" ]; then
      echo "---Can't get latest version of Ungoogled-Chromium falling back to v$CUR_V---"
      LAT_V="$CUR_V"
    else
      echo "---Something went wrong, can't get latest version of Ungoogled-Chromium, putting container into sleep mode---"
      sleep infinity
    fi
  fi
else
  LAT_V="${UG_CHROMIUM_V}"
fi

rm -rf ${DATA_DIR}/UG-Chromium-*.tar.xz 2>/dev/null

echo "---Version Check---"
if [ -z "$CUR_V" ]; then
  echo "---Ungoogled-Chromium not installed, installing---"
  DL_URL="$(wget -qO- https://ungoogled-software.github.io/ungoogled-chromium-binaries/releases/linux_portable/64bit/${LAT_V} | grep -w "${LAT_V}" | cut -d '"' -f2 | tail -1)"
  cd ${DATA_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/UG-Chromium-${LAT_V}.tar.xz "${DL_URL}" ; then
    echo "---Sucessfully downloaded Ungoogled-Chromium---"
  else
    echo "---Something went wrong, can't download Ungoogled-Chromium, putting container in sleep mode---"
    sleep infinity
  fi
  mkdir -p ${DATA_DIR}/Ungoogled
  tar -C ${DATA_DIR}/Ungoogled --strip-components=1 -xf ${DATA_DIR}/UG-Chromium-${LAT_V}.tar.xz
  rm -R ${DATA_DIR}/UG-Chromium-${LAT_V}.tar.xz
elif [ "$CUR_V" != "${LAT_V%%-*}" ]; then
  echo "---Version missmatch, installed v$CUR_V, downloading and installing latest v${LAT_V%%-*}...---"
  DL_URL="$(wget -qO- https://ungoogled-software.github.io/ungoogled-chromium-binaries/releases/linux_portable/64bit/${LAT_V} | grep -w "${LAT_V}" | cut -d '"' -f2 | tail -1)"
  cd ${DATA_DIR}
  rm -rf ${DATA_DIR}/Ungoogled
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/UG-Chromium-${LAT_V}.tar.xz "${DL_URL}" ; then
    echo "---Sucessfully downloaded Ungoogled-Chromium---"
  else
    echo "---Something went wrong, can't download Ungoogled-Chromium, putting container in sleep mode---"
    sleep infinity
  fi
  mkdir -p ${DATA_DIR}/Ungoogled
  tar -C ${DATA_DIR}/Ungoogled --strip-components=1 -xf ${DATA_DIR}/UG-Chromium-${LAT_V}.tar.xz
  rm -R ${DATA_DIR}/UG-Chromium-${LAT_V}.tar.xz
elif [ "$CUR_V" == "${LAT_V%%-*}" ]; then
	echo "---Ungoogled-Chromium v$CUR_V up-to-date---"
fi

echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W}" ]; then
	CUSTOM_RES_W=1024
fi
if [ -z "${CUSTOM_RES_H}" ]; then
	CUSTOM_RES_H=768
fi

if [ "${CUSTOM_RES_W}" -le 1023 ]; then
	echo "---Width to low must be a minimal of 1024 pixels, correcting to 1024...---"
    CUSTOM_RES_W=1024
fi
if [ "${CUSTOM_RES_H}" -le 767 ]; then
	echo "---Height to low must be a minimal of 768 pixels, correcting to 768...---"
    CUSTOM_RES_H=768
fi
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid ${DATA_DIR}/Singleton*
chmod -R ${DATA_PERM} ${DATA_DIR}
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup -noserverkeymap ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting Ungoogled-Chromium---"
cd ${DATA_DIR}
${DATA_DIR}/Ungoogled/chrome --user-data-dir=${DATA_DIR} --disable-accelerated-video --disable-gpu --window-size=${CUSTOM_RES_W},${CUSTOM_RES_H} --no-sandbox --test-type --dbus-stub ${EXTRA_PARAMETERS} 2>/dev/null