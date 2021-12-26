# Ungoogled Chromium in Docker optimized for Unraid
Ungoogled-Chromium is a lightweight approach to removing Google web service dependency from the Chromium project web browser.
- Ungoogled Chromium is Google Chromium, sans dependency on Google web services.
- Ungoogled Chromium retains the default Chromium experience as closely as possible. Unlike other Chromium forks that have their own visions of a web browser, Ungoogled Chromium is essentially a drop-in replacement for Chromium.
- Ungoogled Chromium features tweaks to enhance privacy, control, and transparency. However, almost all of these features must be manually activated or enabled. For more details, see Feature Overview.

You can find the full source code here: https://github.com/Eloston/ungoogled-chromium

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for Chrome | /ungoogledchromium |
| UG_CHROMIUM_V | You can find a full list of availabel versions here if you don't want to install the latest version: https://ungoogled-software.github.io/ungoogled-chromium-binaries/releases/linux_portable/64bit/ | latest |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value | 000 |
| DATA_PERM | Data permissions for /ungoogledchromium folder | 770 |

## Run example
```
docker run --name Ungoogled-Chromium -d \
	-p 8080:8080 \
    --env 'UG_CHROMIUM_V=latest' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=000' \
	--env 'DATA_PERM=770' \
	--volume /path/to/ungoogledchromium:/ungoogledchromium \
    --restart=unless-stopped --shm-size=2G \
	ich777/ungoogled-chromium
```
### Webgui address: http://[IP]:[PORT:8080]/vnc.html?autoconnect=true

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/