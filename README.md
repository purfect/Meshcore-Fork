> **Hinweis zu diesem Fork:** Die Firmware ist als reguläre MeshCore-Companion-Firmware
> für unterstützte Endgeräte gedacht. Hinweise zum Build für das Seeed XIAO ESP32-S3
> mit Wio-SX1262 sowie zum autonomen Auto-Pong/Auto-Reply ohne verbundene App
> stehen in [FORK.md](./FORK.md).
>
> Aktuelle Fork-Version: `v1.0.2`

## Windows 11: Firmware auf den Seeed XIAO ESP32-S3 flashen

Diese Anleitung gilt für den **Seeed XIAO ESP32-S3 mit Wio-SX1262**. Benötigt
werden ein USB-Datenkabel, ein freier USB-Anschluss und Windows 11.

### 1. Das richtige Firmware-Paket herunterladen

Unter **GitHub → Actions → Build End-Device Companion Firmwares** den neuesten
erfolgreichen Lauf öffnen und unten unter **Artifacts** das gewünschte Paket
herunterladen:

- `Xiao_S3_WIO_companion_radio_usb`: Verbindung zur App über USB
- `Xiao_S3_WIO_companion_radio_ble`: Verbindung zur App über Bluetooth LE

Das ZIP-Artifact entpacken. Für ESP32-Geräte enthält es normalerweise zwei
Dateien:

- `*-merged.bin`: vollständige Erstinstallation oder Wiederherstellung
- `*.bin` ohne `-merged`: Update unter Beibehaltung der Einstellungen

Die lokal gebauten Dateien liegen entsprechend unter `out/`.

### 2. Mit dem MeshCore Web-Flasher flashen (empfohlen)

Der Web-Flasher benötigt keine Python-Installation. Er unterstützt beim ESP32
lokale `.bin`-Dateien und beim nRF52 lokale OTA-`.zip`-Dateien.

1. In **Chrome oder Edge auf einem Desktop-PC**
   [meshcore.co.uk/flasher.html](https://meshcore.co.uk/flasher.html) öffnen.
2. **Custom Firmware** auswählen und die zuvor aus dem GitHub-Artifact
   entpackte Datei angeben.
3. Für eine Erstinstallation oder Wiederherstellung auf dem XIAO die
   `*-merged.bin` auswählen. Für ein Update einer vorhandenen Installation die
   normale `.bin` **ohne** `-merged` auswählen.
4. Das XIAO per USB anschließen. Falls es nicht erkannt wird, wie im nächsten
   Abschnitt beschrieben in den Bootloader-Modus versetzen.
5. Im Web-Flasher verbinden, den angezeigten seriellen Port auswählen und den
   Flash-Vorgang vollständig durchlaufen lassen.

Den Dateinamen nicht ändern: Der Zusatz `-merged.bin` kennzeichnet für den
Flasher das vollständige ESP32-Abbild. Eine vollständige Installation kann die
bisherige Geräteidentität, Kanäle, Einstellungen und Auto-Reply-Regeln löschen.

### 3. XIAO in den Bootloader-Modus versetzen

1. Das XIAO mit einem **USB-Datenkabel** am PC anschließen.
2. Die Taste **BOOT** gedrückt halten.
3. Die Taste **RESET** kurz drücken und wieder loslassen.
4. Anschließend **BOOT** loslassen.

Im Web-Flasher beziehungsweise im Geräte-Manager unter **Anschlüsse (COM &
LPT)** erscheint nun ein COM-Port. Wenn Windows lediglich einen Ton ausgibt,
aber kein Port erscheint, zuerst ein anderes USB-Datenkabel und einen direkten
USB-Anschluss am PC testen.

### Alternative: manuell mit esptool flashen

Die folgenden Schritte sind nur erforderlich, wenn der Web-Flasher nicht
verwendet werden soll oder nicht funktioniert.

#### Python und esptool installieren

Falls der Befehl `py` noch nicht vorhanden ist, Python von
[python.org](https://www.python.org/downloads/windows/) installieren. Danach ein
neues PowerShell-Fenster öffnen und esptool installieren:

```powershell
py -m pip install --upgrade esptool
```

Die verfügbaren Ports lassen sich in PowerShell anzeigen:

```powershell
[System.IO.Ports.SerialPort]::GetPortNames()
```

In den folgenden Beispielen muss `COM7` durch diesen Port und der Dateiname durch
den tatsächlich heruntergeladenen Namen ersetzt werden.

#### Vollständige Erstinstallation

Die `-merged.bin` wird ab Adresse `0x0` geschrieben:

```powershell
py -m esptool --chip esp32s3 --port COM7 --baud 460800 write_flash 0x0 .\Xiao_S3_WIO_companion_radio_usb-firmware-merged.bin
```

Falls das Gerät vorher eine andere Firmware hatte oder nicht mehr sauber startet,
kann der Flash zuerst vollständig gelöscht werden:

```powershell
py -m esptool --chip esp32s3 --port COM7 erase_flash
```

**Achtung:** `erase_flash` löscht Identität, Kanäle, Einstellungen und vorhandene
Auto-Reply-Regeln. Danach erneut die `-merged.bin` flashen.

#### Vorhandene Installation aktualisieren

Für ein normales Update die Datei **ohne** `-merged` bei Adresse `0x10000`
schreiben. Vorher nicht `erase_flash` ausführen:

```powershell
py -m esptool --chip esp32s3 --port COM7 --baud 460800 write_flash 0x10000 .\Xiao_S3_WIO_companion_radio_usb-firmware.bin
```

Nach `Hash of data verified` das XIAO einmal mit **RESET** neu starten. Falls der
Port nicht geöffnet werden kann, alle seriellen Monitore, Browser-Tabs und Apps
schließen, die den COM-Port verwenden, und den Bootloader-Modus erneut aktivieren.

### 4. App verbinden und Auto-Antworten konfigurieren

- Bei der USB-Firmware das Gerät im MeshCore-Dashboard über den seriellen
  USB-Port verbinden.
- Bei der BLE-Firmware das Gerät in der MeshCore-App über Bluetooth verbinden.

Auto-Pong und Auto-Reply laufen anschließend auch ohne verbundene App. Zum
Konfigurieren innerhalb der ersten acht Sekunden nach dem Start den Benutzerknopf
lange drücken und eine serielle Konsole mit **115200 Baud** öffnen. Die Konsole
muss beim Drücken von Enter ein Wagenrücklaufzeichen (`CR`) senden.

```text
autopong on
autopong off
autopong location 12345
autoreply set 1 public hallo Hallo, ich bin gerade nicht erreichbar.
autoreply list
reboot
```

Alle Befehle und deren genaue Syntax stehen in [FORK.md](./FORK.md).

### Andere Geräte und Dateiformate

Die GitHub Action erzeugt pro Gerät nur die tatsächlich flashbaren Dateien:

| Datei | Typische Plattform | Installation unter Windows 11 |
| --- | --- | --- |
| `-merged.bin` | ESP32 | MeshCore Web-Flasher für Erstinstallation/Wiederherstellung; alternativ esptool ab `0x0` |
| `.bin` | ESP32/STM32/RP2040 | Beim ESP32 Web-Flasher-Update; alternativ bei diesem XIAO esptool ab `0x10000` |
| `.uf2` | nRF52/RP2040 | Gerät in den UF2-Bootloader versetzen und auf das USB-Laufwerk kopieren; nicht für „Custom Firmware“ im Web-Flasher |
| `.zip` | nRF52 | MeshCore Web-Flasher oder kompatibler nRF52-DFU-Updater |
| `.hex` | STM32 | Mit STM32CubeProgrammer und den Vorgaben des Geräteherstellers flashen |

Immer nur das Artifact verwenden, dessen Gerätename exakt zur vorhandenen
Hardware passt. Eine Firmware für ein ähnlich aussehendes Board kann andere
GPIOs oder einen anderen Funkchip ansprechen.

## About MeshCore

MeshCore is a lightweight, portable C++ library that enables multi-hop packet routing for embedded projects using LoRa and other packet radios. It is designed for developers who want to create resilient, decentralized communication networks that work without the internet.

## 🔍 What is MeshCore?

MeshCore now supports a range of LoRa devices, allowing for easy flashing without the need to compile firmware manually. Users can flash a pre-built binary using tools like Adafruit ESPTool and interact with the network through a serial console.
MeshCore provides the ability to create wireless mesh networks, similar to Meshtastic and Reticulum but with a focus on lightweight multi-hop packet routing for embedded projects. Unlike Meshtastic, which is tailored for casual LoRa communication, or Reticulum, which offers advanced networking, MeshCore balances simplicity with scalability, making it ideal for custom embedded solutions, where devices (nodes) can communicate over long distances by relaying messages through intermediate nodes. This is especially useful in off-grid, emergency, or tactical situations where traditional communication infrastructure is unavailable.

## ⚡ Key Features

* Multi-Hop Packet Routing
  * Devices can forward messages across multiple nodes, extending range beyond a single radio's reach.
  * Supports up to a configurable number of hops to balance network efficiency and prevent excessive traffic.
  * Nodes use fixed roles where "Companion" nodes are not repeating messages at all to prevent adverse routing paths from being used.
* Supports LoRa Radios – Works with Heltec, RAK Wireless, and other LoRa-based hardware.
* Decentralized & Resilient – No central server or internet required; the network is self-healing.
* Low Power Consumption – Ideal for battery-powered or solar-powered devices.
* Simple to Deploy – Pre-built example applications make it easy to get started.

## 🎯 What Can You Use MeshCore For?

* Off-Grid Communication: Stay connected even in remote areas.
* Emergency Response & Disaster Recovery: Set up instant networks where infrastructure is down.
* Outdoor Activities: Hiking, camping, and adventure racing communication.
* Tactical & Security Applications: Military, law enforcement, and private security use cases.
* IoT & Sensor Networks: Collect data from remote sensors and relay it back to a central location.

## 🚀 How to Get Started

- Watch the [MeshCore QuickStart Playlist](https://www.youtube.com/watch?v=iaFltojJrAc&list=PLshzThxhw4O4WU_iZo3NmNZOv6KMrUuF9) by The Comms Channel
- Watch the [MeshCore Technical Presentation](https://www.youtube.com/watch?v=OwmkVkZQTf4) by Liam Cottle.
- Read through our [Frequently Asked Questions](./docs/faq.md) and [Documentation](https://docs.meshcore.io).
- Flash the MeshCore firmware on a supported device.
- Connect with a supported client.

For developers:

- Install [PlatformIO](https://docs.platformio.org) in [Visual Studio Code](https://code.visualstudio.com).
- Clone and open the MeshCore repository in Visual Studio Code.
- See the example applications you can modify and run:
  - [Companion Radio](./examples/companion_radio) - For use with an external chat app, over BLE, USB or Wi-Fi.
  - [KISS Modem](./examples/kiss_modem) - Serial KISS protocol bridge for host applications. ([protocol docs](./docs/kiss_modem_protocol.md))
  - [Simple Repeater](./examples/simple_repeater) - Extends network coverage by relaying messages.
  - [Simple Room Server](./examples/simple_room_server) - A simple BBS server for shared Posts.
  - [Simple Secure Chat](./examples/simple_secure_chat) - Secure terminal based text communication between devices.
  - [Simple Sensor](./examples/simple_sensor) - Remote sensor node with telemetry and alerting.

The Simple Secure Chat example can be interacted with through the Serial Monitor in Visual Studio Code, or with a Serial USB Terminal on Android.

## ⚡️ MeshCore Flasher

We have prebuilt firmware ready to flash on supported devices.

- Launch https://meshcore.io/flasher
- Select a supported device
- Flash one of the firmware types:
  - Companion, Repeater or Room Server
- Once flashing is complete, you can connect with one of the MeshCore clients below.

## 📱 MeshCore Clients

**Companion Firmware**

The companion firmware can be connected to via BLE, USB or Wi-Fi depending on the firmware type you flashed.

- Web: https://app.meshcore.nz
- Android: https://play.google.com/store/apps/details?id=com.liamcottle.meshcore.android
- iOS: https://apps.apple.com/us/app/meshcore/id6742354151?platform=iphone
- NodeJS: https://github.com/liamcottle/meshcore.js
- Python: https://github.com/fdlamotte/meshcore-cli

**Repeater and Room Server Firmware**

The repeater and room server firmware can be set up via USB in the web config tool.

- https://config.meshcore.io

They can also be managed via LoRa in the mobile app by using the Remote Management feature.

## 🛠 Hardware Compatibility

MeshCore is designed for devices listed in the [MeshCore Flasher](https://meshcore.io/flasher)

## 📜 License

MeshCore is open-source software released under the MIT License. You are free to use, modify, and distribute it for personal and commercial projects.

## Contributing

Please submit PR's using 'dev' as the base branch!
For minor changes just submit your PR and we'll try to review it, but for anything more 'impactful' please open an Issue first and start a discussion. It is better to sound out what it is you want to achieve first, and try to come to a consensus on what the best approach is, especially when it impacts the structure or architecture of this codebase.

Here are some general principles you should try to adhere to:
* Keep it simple. Please, don't think like a high-level lang programmer. Think embedded, and keep code concise, without any unnecessary layers.
* No dynamic memory allocation, except during setup/begin functions.
* Use the same brace and indenting style that's in the core source modules. (A .clang-format is probably going to be added soon, but please do NOT retroactively re-format existing code. This just creates unnecessary diffs that make finding problems harder)

Help us prioritize! Please react with thumbs-up to issues/PRs you care about most. We look at reaction counts when planning work.

### Running unit tests

To run unit tests, run the following command:

```bash
pio test --environment native --verbose
```

## Road-Map / To-Do

There are a number of fairly major features in the pipeline, with no particular time-frames attached yet. In very rough chronological order:
- [X] Companion radio: UI redesign
- [X] Repeater + Room Server: add ACL's (like Sensor Node has)
- [X] Standardise Bridge mode for repeaters
- [ ] Repeater/Bridge: Standardise the Transport Codes for zoning/filtering
- [X] Core + Repeater: enhanced zero-hop neighbour discovery
- [ ] Core: round-trip manual path support
- [ ] Companion + Apps: support for multiple sub-meshes (and 'off-grid' client repeat mode)
- [ ] Core + Apps: support for LZW message compression
- [ ] Core: dynamic CR (Coding Rate) for weak vs strong hops
- [ ] Core: new framework for hosting multiple virtual nodes on one physical device
- [ ] V2 protocol spec: discussion and consensus around V2 packet protocol, including path hashes, new encryption specs, etc

## 📞 Get Support

- Report bugs and request features on the [GitHub Issues](https://github.com/ripplebiz/MeshCore/issues) page.
- Find additional guides and components on [my site](https://buymeacoffee.com/ripplebiz).
- Join [MeshCore Discord](https://meshcore.gg) to chat with the developers and get help from the community.
